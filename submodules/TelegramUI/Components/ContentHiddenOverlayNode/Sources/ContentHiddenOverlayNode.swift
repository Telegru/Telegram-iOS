import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramUIPreferences
import TelegramPresentationData
import TPStrings

public enum ContentHiddenType {
    case chat
    case content
    case channel
    case group
    case media
    case stories

    func getTitle() -> String {
        switch self {
        case .chat:
            return "ChildMode.ChatHidden"
        case .content:
            return "ChildMode.ContentHidden"
        case .channel:
            return "ChildMode.ChannelHidden"
        case .group:
            return "ChildMode.GroupHidden"
        case .media:
            return "ChildMode.MediaHidden"
        case .stories:
            return "ChildMode.StoriesHidden"
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .chat:
            return "ChildMode.ChatHiddenDescription"
        case .channel:
            return "ChildMode.ChannelHiddenDescription"
        case .group:
            return "ChildMode.GroupHiddenDescription"
        case .media:
            return "ChildMode.MediaHiddenDescription"
        case .content:
            return "ChildMode.ContentHiddenDescription"
        case .stories:
            return "ChildMode.StoriesHiddenDescription"
        }
    }
    
    func getButtonText() -> String {
        return "ChildMode.RequestAccessButton"
    }
}

public class ContentHiddenOverlayNode: ASDisplayNode {
    private let blurNode: ASDisplayNode
    private let contentNode: ASDisplayNode
    private let iconNode: ASImageNode
    private let titleNode: ImmediateTextNode
    private let descriptionNode: ImmediateTextNode
    private let buttonNode: IconLeftButtonNode
    
    private var theme: PresentationTheme?
    private var strings: PresentationStrings?
    private var contentType: ContentHiddenType
    
    public var requestAccessAction: (() -> Void)?
    
    public init(theme: PresentationTheme? = nil, strings: PresentationStrings? = nil, contentType: ContentHiddenType = .chat) {
        self.theme = theme
        self.strings = strings
        self.contentType = contentType
        
        self.blurNode = ASDisplayNode()
        self.contentNode = ASDisplayNode()
        self.iconNode = ASImageNode()
        self.titleNode = ImmediateTextNode()
        self.descriptionNode = ImmediateTextNode()
        self.buttonNode = IconLeftButtonNode()
        
        super.init()
        
        self.blurNode.backgroundColor = theme?.list.plainBackgroundColor ?? .black
        self.addSubnode(self.blurNode)
        self.addSubnode(self.contentNode)
        
        self.contentNode.addSubnode(self.iconNode)
        self.contentNode.addSubnode(self.titleNode)
        self.contentNode.addSubnode(self.descriptionNode)
        self.contentNode.addSubnode(self.buttonNode)
        
        self.isUserInteractionEnabled = true
        self.contentNode.isUserInteractionEnabled = true
        
        self.setupNodes()
    }
    
    private func setupNodes() {
        guard let theme, let strings else {
            return
        }
        
        let iconImage = generateTintedImage(image: UIImage(bundleImageName: "Child Mode/Blocked"), color: theme.chat.inputPanel.primaryTextColor)
        self.iconNode.image = iconImage
        
        self.titleNode.attributedText = NSAttributedString(
            string: self.contentType.getTitle().tp_loc(lang: strings.baseLanguageCode),
            font: Font.bold(15.0),
            textColor: theme.chat.inputPanel.primaryTextColor
        )
        
        self.descriptionNode.maximumNumberOfLines = 0
        self.descriptionNode.attributedText = NSAttributedString(
            string: self.contentType.getDescription().tp_loc(lang: strings.baseLanguageCode),
            font: Font.regular(15.0),
            textColor: theme.chat.inputPanel.primaryTextColor,
            paragraphAlignment: .center
        )
        
        buttonNode.setAttributedTitle(NSAttributedString(
            string: self.contentType.getButtonText().tp_loc(lang: strings.baseLanguageCode),
            font: Font.medium(15.0),
            textColor: .white
        ), for: [])
        
        buttonNode.backgroundColor = theme.chat.inputPanel.actionControlFillColor
        buttonNode.cornerRadius = 10.0
        
        let lockImage = UIImage(bundleImageName: "Child Mode/Lock")
        buttonNode.imageNode.image = generateTintedImage(image: lockImage, color: .white)
        
        buttonNode.contentSpacing = 10.0
        buttonNode.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        buttonNode.addTarget(self, action: #selector(buttonPressed), forControlEvents: .touchUpInside)
    }
    
    public func update(theme: PresentationTheme, strings: PresentationStrings? = nil, contentType: ContentHiddenType? = nil) {
        self.theme = theme
        self.strings = strings
        
        if let newContentType = contentType {
            self.contentType = newContentType
        }
        
        self.setupNodes()
        
        self.setNeedsLayout()
    }
    
    @objc private func buttonPressed() {
        self.requestAccessAction?()
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard self.view.isUserInteractionEnabled else { return false }

        let p = convert(point, to: buttonNode)
        return buttonNode.view.point(inside: p, with: event)   
    }
    
    override public func layout() {
        super.layout()
        
        let size = self.bounds.size
        
        self.blurNode.frame = CGRect(origin: CGPoint.zero, size: size)
        self.contentNode.frame = CGRect(origin: CGPoint.zero, size: size)
        
        let contentCenterY = size.height * 0.38
        
        let iconSize = CGSize(width: 28.0, height: 28.0)
        let iconFrame = CGRect(
            origin: CGPoint(x: (size.width - iconSize.width) / 2.0, y: contentCenterY),
            size: iconSize
        )
        self.iconNode.frame = iconFrame
        
        let titleSize = self.titleNode.updateLayout(CGSize(width: size.width - 40.0, height: .greatestFiniteMagnitude))
        let titleFrame = CGRect(
            origin: CGPoint(x: (size.width - titleSize.width) / 2.0, y: iconFrame.maxY + 10.0),
            size: titleSize
        )
        self.titleNode.frame = titleFrame
        
        let descriptionWidth = size.width 
        let descriptionSize = self.descriptionNode.updateLayout(CGSize(width: descriptionWidth, height: .greatestFiniteMagnitude))
        let descriptionFrame = CGRect(
            origin: CGPoint(x: (size.width - descriptionSize.width) / 2.0, y: titleFrame.maxY + 10.0),
            size: descriptionSize
        )
        self.descriptionNode.frame = descriptionFrame
        
        let buttonHeight: CGFloat = 50.0
        let buttonWidth = min(size.width - 80.0, 332.0)
        let buttonFrame = CGRect(
            origin: CGPoint(x: (size.width - buttonWidth) / 2.0, y: descriptionFrame.maxY + 30.0),
            size: CGSize(width: buttonWidth, height: buttonHeight)
        )
        self.buttonNode.frame = buttonFrame
    }
    
    public func isVisible() -> Bool {
        return !isHidden && alpha > 0
    }
}
