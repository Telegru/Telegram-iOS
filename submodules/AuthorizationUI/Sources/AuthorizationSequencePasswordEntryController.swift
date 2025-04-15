import Foundation
import UIKit
import Display
import AsyncDisplayKit
import TelegramPresentationData
import ProgressNavigationButtonNode
import TelegramCore
import AccountContext
import SwiftSignalKit

final class AuthorizationSequencePasswordEntryController: ViewController {
    private var controllerNode: AuthorizationSequencePasswordEntryControllerNode {
        return self.displayNode as! AuthorizationSequencePasswordEntryControllerNode
    }
    
    private let proxyButtonNode: DAuthorizationProxyButtonNode
    private let proxyDisposable = MetaDisposable()
    
    private var validLayout: ContainerViewLayout?
    private let sharedContext: SharedAccountContext
    private var account: UnauthorizedAccount?
    
    private let presentationData: PresentationData
    
    var loginWithPassword: ((String) -> Void)?
    var forgot: (() -> Void)?
    var reset: (() -> Void)?
    var hint: String?
    
    var didForgotWithNoRecovery: Bool = false {
        didSet {
            if self.didForgotWithNoRecovery != oldValue {
                if self.isNodeLoaded, let hint = self.hint {
                    self.controllerNode.updateData(hint: hint, didForgotWithNoRecovery: didForgotWithNoRecovery, suggestReset: self.suggestReset)
                }
            }
        }
    }
    
    var suggestReset: Bool = false
    
    private let hapticFeedback = HapticFeedback()
    
    var inProgress: Bool = false {
        didSet {
            self.updateNavigationItems()
            self.controllerNode.inProgress = self.inProgress
        }
    }
    
    deinit {
        proxyDisposable.dispose()
    }
    
    init(presentationData: PresentationData, sharedContext: SharedAccountContext, account: UnauthorizedAccount?, back: @escaping () -> Void) {
        self.presentationData = presentationData
        self.sharedContext = sharedContext
        self.account = account
        
        self.proxyButtonNode = DAuthorizationProxyButtonNode(theme: presentationData.theme)
        
        super.init(navigationBarPresentationData: NavigationBarPresentationData(theme: AuthorizationSequenceController.navigationBarTheme(presentationData.theme), strings: NavigationBarStrings(presentationStrings: presentationData.strings)))
        
        self.proxyButtonNode.addTarget(self, action: #selector(proxyButtonPressed), forControlEvents: .touchUpInside)
        
        self.supportedOrientations = ViewControllerSupportedOrientations(regularSize: .all, compactSize: .portrait)
        
        self.hasActiveInput = true
        
        self.statusBar.statusBarStyle = presentationData.theme.intro.statusBarStyle.style
        
        self.attemptNavigation = { _ in
            return false
        }
        self.navigationBar?.backPressed = {
            back()
        }
        
        proxyDisposable.set(
            (
                sharedContext.accountManager.sharedData(keys: [SharedDataKeys.proxySettings])
                |> map { sharedData -> Bool in
                    if let settings = sharedData.entries[SharedDataKeys.proxySettings]?.get(ProxySettings.self) {
                        return settings.enabled
                    } else {
                        return false
                    }
                }
                |> distinctUntilChanged
                |> deliverOnMainQueue
            )
            .start(next: { [weak self] enabled in
                guard let self else { return }
                self.proxyButtonNode.status = enabled ? .connected : .available
                self.updateNavigationItems()
            })
        )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadDisplayNode() {
        self.displayNode = AuthorizationSequencePasswordEntryControllerNode(strings: self.presentationData.strings, theme: self.presentationData.theme)
        self.displayNodeDidLoad()
        
        self.controllerNode.view.disableAutomaticKeyboardHandling = [.forward, .backward]
        
        self.controllerNode.loginWithCode = { [weak self] _ in
            self?.nextPressed()
        }
        
        self.controllerNode.forgot = { [weak self] in
            self?.forgotPressed()
        }
        
        self.controllerNode.reset = { [weak self] in
            self?.resetPressed()
        }
        
        if let hint = self.hint {
            self.controllerNode.updateData(hint: hint, didForgotWithNoRecovery: self.didForgotWithNoRecovery, suggestReset: self.suggestReset)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationController = self.navigationController as? NavigationController, let layout = self.validLayout {
            addTemporaryKeyboardSnapshotView(navigationController: navigationController, layout: layout)
        }
        
        self.controllerNode.activateInput()
    }
    
    @objc private func proxyButtonPressed() {
        guard let account else {
            return
        }
        self.present(self.sharedContext.makeProxySettingsController(sharedContext: self.sharedContext, account: account), in: .window(.root), with: ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
    }
    
    func updateNavigationItems() {
        let proxyItem = UIBarButtonItem(customDisplayNode: proxyButtonNode)
        guard let layout = self.validLayout, layout.size.width < 360.0 else {
            self.navigationItem.rightBarButtonItem = proxyItem
            return
        }
                
        if self.inProgress {
            let item = UIBarButtonItem(customDisplayNode: ProgressNavigationButtonNode(color: self.presentationData.theme.rootController.navigationBar.accentTextColor))
            self.navigationItem.rightBarButtonItems = [proxyItem, item].compactMap { $0 }
        } else {
            self.navigationItem.rightBarButtonItems = [
                proxyItem,
                UIBarButtonItem(title: self.presentationData.strings.Common_Next, style: .done, target: self, action: #selector(self.nextPressed))
            ].compactMap { $0 }
        }
    }
    
    func updateData(hint: String, suggestReset: Bool) {
        if self.hint != hint || self.suggestReset != suggestReset {
            self.hint = hint
            self.suggestReset = suggestReset
            if self.isNodeLoaded {
                self.controllerNode.updateData(hint: hint, didForgotWithNoRecovery: self.didForgotWithNoRecovery, suggestReset: self.suggestReset)
            }
        }
    }
    
    func passwordIsInvalid() {
        if self.isNodeLoaded {
            self.hapticFeedback.error()
            self.controllerNode.passwordIsInvalid()
        }
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        let hadLayout = self.validLayout != nil
        self.validLayout = layout
        
        if !hadLayout {
            self.updateNavigationItems()
            
            if let navigationController = self.navigationController as? NavigationController {
                addTemporaryKeyboardSnapshotView(navigationController: navigationController, layout: layout, local: true)
            }
        }
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationLayout(layout: layout).navigationFrame.maxY, transition: transition)
    }
    
    @objc func nextPressed() {
        if self.controllerNode.currentPassword.isEmpty {
            self.hapticFeedback.error()
            self.controllerNode.animateError()
        } else {
            self.loginWithPassword?(self.controllerNode.currentPassword)
        }
    }
    
    func forgotPressed() {
        /*if self.suggestReset {
            self.present(standardTextAlertController(theme: AlertControllerTheme(presentationData: self.presentationData), title: nil, text: self.presentationData.strings.TwoStepAuth_RecoveryFailed, actions: [TextAlertAction(type: .defaultAction, title: self.presentationData.strings.Common_OK, action: {})]), in: .window(.root))
        } else*/ if self.didForgotWithNoRecovery {
            self.present(standardTextAlertController(theme: AlertControllerTheme(presentationData: self.presentationData), title: nil, text: self.presentationData.strings.TwoStepAuth_RecoveryUnavailable, actions: [TextAlertAction(type: .defaultAction, title: self.presentationData.strings.Common_OK, action: {})]), in: .window(.root))
        } else {
            self.forgot?()
        }
    }
    
    func resetPressed() {
        self.reset?()
    }
}
