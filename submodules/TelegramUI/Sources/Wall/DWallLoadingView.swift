import Foundation
import Display
import TelegramPresentationData
import AppBundle
import SwiftSignalKit
import OverlayStatusControllerImpl
import AsyncDisplayKit
import ActivityIndicator
import PresentationDataUtils
import TPStrings
import AsyncDisplayKit

private enum DWallLoadingMessage: CaseIterable {
    case manyPosts
    case formingFeed
    
    var text: String {
        switch self {
        case .manyPosts:
            return "Wall.Load.ManyPosts"
        case .formingFeed:
            return "Wall.Load.FormingFeed"
        }
    }
}

public final class DWallLoadingNode: ASDisplayNode {
    private let overlayBackgroundNode: ASDisplayNode
    private let containerNode: ASDisplayNode
    private let spinner: ActivityIndicator
    private let textNode: ASTextNode
    
    private let messageSwitchInterval: TimeInterval = 3.5
    private var currentMessageType: DWallLoadingMessage = .manyPosts
    private var messageChangeTimer: SwiftSignalKit.Timer?
    
    private var presentationData: PresentationData
    private var theme: PresentationTheme
    private var isLight: Bool
    
    public init(presentationData: PresentationData) {
        self.presentationData = presentationData
        self.theme = presentationData.theme
        self.isLight = !theme.overallDarkAppearance
        
        self.overlayBackgroundNode = ASDisplayNode()
        self.overlayBackgroundNode.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        self.overlayBackgroundNode.alpha = 0.0
        
        let containerBaseColor = theme.overallDarkAppearance ?
            UIColor(rgb: 0x3C3C43) : UIColor(rgb: 0xF4F4F4)

        self.containerNode = ASDisplayNode()
        self.containerNode.backgroundColor = containerBaseColor.withAlphaComponent(0.5)
        self.containerNode.cornerRadius = 20.0
        self.containerNode.clipsToBounds = true
        self.containerNode.alpha = 0.0
        
        let spinnerColor = self.isLight ? UIColor(rgb: 0x5a5a5a) : UIColor.white
        self.spinner = ActivityIndicator(
            type: .custom(spinnerColor, 30.0, 2.5, true),
            speed: .regular
        )
        
        self.textNode = ASTextNode()
        self.textNode.attributedText = NSAttributedString(
            string: DWallLoadingMessage.manyPosts.text.tp_loc(lang: presentationData.strings.baseLanguageCode),
            attributes: [
                NSAttributedString.Key.font: Font.regular(16.0),
                NSAttributedString.Key.foregroundColor: theme.overallDarkAppearance ? UIColor.white : UIColor(rgb: 0x5A5A5A)
            ]
        )
        self.textNode.maximumNumberOfLines = 0
        self.textNode.truncationMode = .byTruncatingTail
        self.textNode.textAlignment = .center
        
        super.init()
        
        self.addSubnode(self.overlayBackgroundNode)
        self.addSubnode(self.containerNode)
        self.containerNode.addSubnode(self.spinner)
        self.containerNode.addSubnode(self.textNode)
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func applicationWillEnterForeground() {
        spinner.isHidden = true
        spinner.isHidden = false
        startMessageChangeTimer()
        changeMessage()
    }
    
    private func updateTextWithCurrentMessage() {
        self.textNode.attributedText = NSAttributedString(
            string: self.currentMessageType.text.tp_loc(lang: self.presentationData.strings.baseLanguageCode),
            attributes: [
                NSAttributedString.Key.font: Font.bold(15.0),
                NSAttributedString.Key.foregroundColor: self.theme.overallDarkAppearance ? UIColor.white : UIColor(rgb: 0x5A5A5A)
            ]
        )
    }
    
    deinit {
        self.messageChangeTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func didLoad() {
        super.didLoad()
        
        setupAppLifecycleObservers()
        startMessageChangeTimer()
    }
    
    override public func didEnterHierarchy() {
        super.didEnterHierarchy()
        spinner.isHidden = false
    }
    
    override public func didExitHierarchy() {
        super.didExitHierarchy()
        spinner.isHidden = true
    }
    
    private func startMessageChangeTimer() {
        self.messageChangeTimer?.invalidate()
        
        let timer = SwiftSignalKit.Timer(timeout: messageSwitchInterval, repeat: true, completion: { [weak self] in
            self?.changeMessage()
        }, queue: Queue.mainQueue())
        
        self.messageChangeTimer = timer
        timer.start()
    }
    
    private func changeMessage() {
        let nextMessageType: DWallLoadingMessage = (self.currentMessageType == .manyPosts) ? .formingFeed : .manyPosts
        self.currentMessageType = nextMessageType
        
        UIView.transition(with: self.textNode.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.textNode.attributedText = NSAttributedString(
                string: nextMessageType.text.tp_loc(lang: self.presentationData.strings.baseLanguageCode),
                attributes: [
                    NSAttributedString.Key.font: Font.bold(15.0),
                    NSAttributedString.Key.foregroundColor: self.theme.overallDarkAppearance ? UIColor.white : UIColor(rgb: 0x5A5A5A)
                ]
            )
        }, completion: nil)
    }
    
    public func updateLayout(layout: ContainerViewLayout, navigationBarHeight: CGFloat) {
        self.frame = CGRect(origin: CGPoint(), size: layout.size)
        self.overlayBackgroundNode.frame = self.bounds
        
        let containerWidth: CGFloat = min(layout.size.width - 40, 264)
        let containerHeight: CGFloat = 126
        let containerX = (layout.size.width - containerWidth) / 2.0
        let containerY = (layout.size.height - containerHeight) / 2.0
        
        self.containerNode.frame = CGRect(x: containerX, y: containerY, width: containerWidth, height: containerHeight)
        
        let spinnerSize = CGSize(width: 48, height: 48)
        let spinnerX = (containerWidth - spinnerSize.width) / 2.0
        let spinnerY: CGFloat = 16.0
        
        self.spinner.frame = CGRect(origin: CGPoint(x: spinnerX, y: spinnerY), size: spinnerSize)
        
        let textPadding: CGFloat = 8.0
        let textWidth = containerWidth - (textPadding * 2)
        
        let textX = textPadding
        let textY = spinnerY + spinnerSize.height + 8.0
        
        let textSize = self.textNode.measure(CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textNode.frame = CGRect(origin: CGPoint(x: textX, y: textY), size: CGSize(width: textWidth, height: textSize.height))
    }
    
    public func animateIn() {
        self.overlayBackgroundNode.alpha = 0.0
        self.containerNode.alpha = 0.0
        self.containerNode.transform = CATransform3DMakeScale(0.6, 0.6, 1.0)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.overlayBackgroundNode.alpha = 1.0
            self.containerNode.alpha = 1.0
            
            let containerBaseColor = self.theme.overallDarkAppearance ?
                UIColor(rgb: 0x3C3C43) : UIColor(rgb: 0xF4F4F4)
            
            self.containerNode.backgroundColor = containerBaseColor.withAlphaComponent(0.8)
            self.containerNode.transform = CATransform3DIdentity
        }, completion: nil)
    }
    
    public func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.overlayBackgroundNode.alpha = 0.0
            self.containerNode.alpha = 0.0
            self.containerNode.transform = CATransform3DMakeScale(0.6, 0.6, 1.0)
        }, completion: { _ in
            completion?()
        })
    }
    
    func updatePresentationData(_ presentationData: PresentationData) {
        self.presentationData = presentationData
        self.theme = presentationData.theme
        self.isLight = !presentationData.theme.overallDarkAppearance
        
        let containerBaseColor = presentationData.theme.overallDarkAppearance ?
            UIColor(rgb: 0x3C3C43) : UIColor(rgb: 0xF4F4F4)
        self.containerNode.backgroundColor = containerBaseColor.withAlphaComponent(0.8)
        
        let spinnerColor = self.isLight ? UIColor(rgb: 0x5a5a5a) : UIColor.white
        self.spinner.type = .custom(spinnerColor, 30.0, 2.5, true)
        
        self.textNode.attributedText = NSAttributedString(
            string: self.currentMessageType.text.tp_loc(lang: self.presentationData.strings.baseLanguageCode),
            attributes: [
                NSAttributedString.Key.font: Font.bold(15.0),
                NSAttributedString.Key.foregroundColor: presentationData.theme.overallDarkAppearance ?
                    UIColor.white : UIColor(rgb: 0x5A5A5A)
            ]
        )
    }
}
