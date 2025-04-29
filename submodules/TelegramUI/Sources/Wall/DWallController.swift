import Foundation
import UIKit
import Display
import TelegramCore
import SwiftSignalKit
import TelegramPresentationData
import TelegramBaseController
import AccountContext
import ChatListUI
import Postbox
import ListMessageItem
import AnimationCache
import MultiAnimationRenderer
import SettingsUI
import TPUI
import PresentationDataUtils
import AsyncDisplayKit
import DAnalytics

public final class DWallController: TelegramBaseController {
    
    private let queue = Queue()
    
    private let context: AccountContext
    private var hasAppearedBefore = false

    private var scrollDisposable: Disposable?
    private var filterDisposable: Disposable?

    private(set) var presentationData: PresentationData
    private var presentationDataDisposable: Disposable?
    
    private var unreadCountDisposable: Disposable?
    
    private let animationCache: AnimationCache
    private let animationRenderer: MultiAnimationRenderer
    private var loadingActionDisposable: Disposable?
    
    private var overlayStatusController: ViewController?
    private var isShowingOverlay = false
    
    private var loadingNode: DWallLoadingNode?
    private var peersLoadingMonitorDisposable: Disposable?
    private var isCurrentlyVisible = false

    private var controllerNode: DWallControllerNode {
        return self.displayNode as! DWallControllerNode
    }
    
    public init(context: AccountContext) {
        self.context = context
        
        self.animationCache = context.animationCache
        self.animationRenderer = context.animationRenderer
        
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        
        super.init(context: context, navigationBarPresentationData: NavigationBarPresentationData(presentationData: self.presentationData), mediaAccessoryPanelVisibility: .none, locationBroadcastPanelSource: .none, groupCallPanelSource: .none)
        
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBarStyle.style
        
        navigationItem.title = "Wall.Title".tp_loc(lang: presentationData.strings.baseLanguageCode)
        tabBarItem.title = "Wall.TabTitle".tp_loc(lang: presentationData.strings.baseLanguageCode)
        let icon = TPIconManager.shared.icon(.wallTab)
        tabBarItem.image = icon
        tabBarItem.selectedImage = icon
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: self.presentationData.strings.Common_Back,
            style: .plain,
            target: nil,
            action: nil
        )
        
        self.presentationDataDisposable = (self.context.sharedContext.presentationData
                                           |> deliverOnMainQueue).start(next: { [weak self] presentationData in
            guard let self else { return }
            
            let previousTheme = self.presentationData.theme
            let previousStrings = self.presentationData.strings
            
            self.presentationData = presentationData
            
            if previousTheme !== presentationData.theme || previousStrings !== presentationData.strings {
                updateThemeAndStrings()
            }
        }).strict()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: self.presentationData.strings.Common_Back,
            style: .plain,
            target: nil,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Wall.Reload".tp_loc(lang: presentationData.strings.baseLanguageCode),
            style: .plain,
            target: self,
            action: #selector(self.reloadPressed)
        )
        
        let settingsIcon = PresentationResourcesChat.chatWallGearImage(self.presentationData.theme)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: settingsIcon,
            style: .plain,
            target: self,
            action: #selector(self.settingsPressed)
        )
        
        self.scrollToTop = { [weak self] in
            self?.controllerNode.scrollToTop()
        }
        
        setupUnreadCounterObserving()
        setupFilterUpdateObserving()
        setupLoadingActionObserving()
        setupInitialLoadingView()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        presentationDataDisposable?.dispose()
        unreadCountDisposable?.dispose()
        scrollDisposable?.dispose()
        filterDisposable?.dispose()
        loadingActionDisposable?.dispose()
        peersLoadingMonitorDisposable?.dispose()
    }
    
    public override func loadDisplayNode() {
        self.displayNode = DWallControllerNode(context: self.context, controller: self)
        
        controllerNode.chatController.parentController = self
        self.displayNodeDidLoad()
    }
    
    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        controllerNode.chatController.customNavigationController = self.navigationController as? NavigationController
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isCurrentlyVisible {
            isCurrentlyVisible = true
            Analytics.trackOpenWall()
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCurrentlyVisible = false
    }
    
    public override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        let _ = self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.cleanNavigationHeight, transition: transition)
        
        if let loadingNode = self.loadingNode {
            loadingNode.updateLayout(layout: layout, navigationBarHeight: self.cleanNavigationHeight)
        }
    }
    
    private func updateThemeAndStrings() {
        let icon = TPIconManager.shared.icon(.wallTab)
        tabBarItem.image = icon
        tabBarItem.selectedImage = icon
        
        navigationItem.title = "Wall.Title".tp_loc(lang: presentationData.strings.baseLanguageCode)
        tabBarItem.title = "Wall.TabTitle".tp_loc(lang: presentationData.strings.baseLanguageCode)
        
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBarStyle.style
        
        self.navigationBar?.updatePresentationData(NavigationBarPresentationData(presentationData: self.presentationData))
        self.controllerNode.updatePresentationData(self.presentationData)
        self.loadingNode?.updatePresentationData(self.presentationData)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Wall.Reload".tp_loc(lang: presentationData.strings.baseLanguageCode),
            style: .plain,
            target: self,
            action: #selector(self.reloadPressed)
        )
        
        let settingsIcon = PresentationResourcesChat.chatWallGearImage(self.presentationData.theme)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: settingsIcon,
            style: .plain,
            target: self,
            action: #selector(self.settingsPressed)
        )
    }
    
    private func setupUnreadCounterObserving(single: Bool = false) {
        let context = self.context

        if case .wall = controllerNode.wallContent.kind {
            unreadCountDisposable?.dispose()
            unreadCountDisposable = nil
            
            let unreadCountSignal = controllerNode.wallContent.filterSignal
            |> mapToSignal { [weak self] filter -> Signal<Int, NoError>  in
                guard let self = self else {
                    return .complete()
                }
                return self.context.totalUnreadCount(filterPredicate: filter)
            }
            
            unreadCountDisposable = (combineLatest(unreadCountSignal, context.sharedContext.presentationData) |> deliverOnMainQueue)
                .startStrict(next: { [weak self] unreadCount, presentationData in
                guard let self else { return }

                if unreadCount == 0 {
                    tabBarItem.badgeValue = ""
                } else {
                    tabBarItem.badgeValue = compactNumericCountString(Int(unreadCount), decimalSeparator: presentationData.dateTimeFormat.decimalSeparator)
                }
            })
            
        }
    }
    
    private func setupFilterUpdateObserving() {
        var skipFirst = true

        filterDisposable = (
            controllerNode.wallContent.filterSignal
        ).start(next: { [weak self] _ in
            if skipFirst {
                skipFirst = false
                return
            }

            guard let self = self else { return }
            self.scrollDisposable?.dispose()
            self.scrollDisposable = (
                self.controllerNode.wallContent.historyView
                |> filter { !$0.0.isLoading }
                |> take(1)
                |> delay(2.0, queue: .mainQueue())
            )
            .start(next: { view in

                if let first = view.0.entries.first {
                    (self.controllerNode.chatController as? ChatControllerImpl)?.chatDisplayNode.historyNode.scrollToMessage(index: first.index)

                }
            })
        })
    }
    
    private func setupLoadingActionObserving() {
        loadingActionDisposable = (controllerNode.wallContent.loadingActionSignal
                                    |> deliverOnMainQueue).start(next: { [weak self] action in
            guard let self = self else { return }
            
            switch action {
            case .loadingStarted:
                self.showLoadingOverlay()
                
            case .loadingEnded(let isLoadAll, let shouldScroll):
                self.hideLoadingOverlay()
                if shouldScroll {
                    if isLoadAll {
                        self.scrollToEnd()
                    } else {
                        self.scrollToStart()
                    }
                }
            }
        })
    }
    
    private func scrollToEnd() {
        let chatController = self.controllerNode.chatController as? ChatControllerImpl
        chatController?.chatDisplayNode.historyNode.resetScrolling(location: .Scroll(subject: MessageHistoryScrollToSubject(index: .upperBound, quote: nil), anchorIndex: .upperBound, sourceIndex: .lowerBound, scrollPosition: .top(0.0), animated: true, highlight: false, setupReply: false))
    }
    
    private func scrollToStart() {
        (self.controllerNode.chatController as? ChatControllerImpl)?.chatDisplayNode.historyNode.resetScrolling(location: nil)
        (self.controllerNode.chatController as? ChatControllerImpl)?.chatDisplayNode.historyNode.scrollToFirstItem()
    }
    
    @objc private func reloadPressed() {
        controllerNode.wallContent.reloadData()
    }
    
    @objc private func settingsPressed() {
        let settingsController = dWallSettingsController(context: context)
        self.present(settingsController, in: .window(.root), with: ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
    }
    
    private func showLoadingOverlay() {
        guard !isShowingOverlay || overlayStatusController?.isViewLoaded != true else { return }
        isShowingOverlay = true
        
        let overlayController = OverlayStatusController(
            theme: self.presentationData.theme,
            type: .loading(cancelled: { [weak self] in
                self?.hideLoadingOverlay()
            })
        )
        
        self.overlayStatusController = overlayController
        self.present(overlayController, in: .window(.root), with: ViewControllerPresentationArguments(presentationAnimation: .none))
    }
    
    private func hideLoadingOverlay() {
        guard isShowingOverlay else { return }
        isShowingOverlay = false
        
        if let overlayStatusController = self.overlayStatusController {
            self.overlayStatusController = nil
            overlayStatusController.dismiss(completion: nil)
        }
    }
    
    private func setupInitialLoadingView() {
        let wallContent = self.controllerNode.wallContent
        self.showLoadingView()
        
        self.peersLoadingMonitorDisposable = wallContent.peersLoadingMonitor.loadedSignal
            .start(next: { [weak self] loaded in
                guard let self = self else { return }
                
                if loaded {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.hideLoadingView()
                    }
                }
            })
    }
    
    private func showLoadingView() {
        guard self.loadingNode == nil, self.isViewLoaded else { return }
        
        let loadingNode = DWallLoadingNode(presentationData: self.presentationData)
        self.loadingNode = loadingNode
        
        self.displayNode.addSubnode(loadingNode)
        loadingNode.animateIn()
    }
    
    private func hideLoadingView() {
        guard let loadingNode = self.loadingNode else { return }
        self.loadingNode = nil
        
        loadingNode.animateOut { [weak loadingNode] in
            loadingNode?.removeFromSupernode()
        }
    }
}
