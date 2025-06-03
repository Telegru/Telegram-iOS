import UIKit

public enum ChatTextFormattingTool: Hashable, Equatable {
    case mention
    case undo
    case redo
    case copy
    case paste
    case cut
    case selectAll
    case link
    case bold
    case italic
    case spoiler
    case quote
    case monospace
    case underline
    case strikethrough
    case regular
    
    var image: UIImage? {
        switch self {
        case .mention:
            return UIImage(bundleImageName: "DChat/TextFormatter/Mention")
        case .undo:
            return UIImage(bundleImageName: "DChat/TextFormatter/Undo")
        case .redo:
            return UIImage(bundleImageName: "DChat/TextFormatter/Redo")
        case .copy:
            return UIImage(bundleImageName: "DChat/TextFormatter/Copy")
        case .paste:
            return UIImage(bundleImageName: "DChat/TextFormatter/Paste")
        case .cut:
            return UIImage(bundleImageName: "DChat/TextFormatter/Cut")
        case .selectAll:
            return UIImage(bundleImageName: "DChat/TextFormatter/SelectAll")
        case .link:
            return UIImage(bundleImageName: "DChat/TextFormatter/Link")
        case .bold:
            return UIImage(bundleImageName: "DChat/TextFormatter/Bold")
        case .italic:
            return UIImage(bundleImageName: "DChat/TextFormatter/Italic")
        case .spoiler:
            return UIImage(bundleImageName: "DChat/TextFormatter/Spoiler")
        case .quote:
            return UIImage(bundleImageName: "DChat/TextFormatter/Quote")
        case .monospace:
            return UIImage(bundleImageName: "DChat/TextFormatter/Monospace")
        case .underline:
            return UIImage(bundleImageName: "DChat/TextFormatter/Underline")
        case .strikethrough:
            return UIImage(bundleImageName: "DChat/TextFormatter/Strikethrough")
        case .regular:
            return UIImage(bundleImageName: "DChat/TextFormatter/Regular")
        }
    }

    var isSelectable: Bool {
        switch self {
        case .bold, .italic, .underline, .strikethrough, .spoiler, .quote, .monospace:
            return true
        default:
            return false
        }
    }
}

public struct ChatTextFormattingEntry: Equatable {
    public let tool: ChatTextFormattingTool
    public let isEnabled: Bool
    public let isSelected: Bool
}
