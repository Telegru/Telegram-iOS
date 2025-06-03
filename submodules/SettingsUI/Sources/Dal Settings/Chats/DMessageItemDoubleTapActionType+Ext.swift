import UIKit
import TelegramUIPreferences
import TPStrings
import AppBundle

extension DMessageItemDoubleTapActionType {
    
    func localized(lang: String) -> String {
        switch self {
        case .disabled:
            "DahlSettings.Chats.Message.DoubleTapAction.Disabled".tp_loc(lang: lang)
        case .editMessage:
            "DahlSettings.Chats.Message.DoubleTapAction.EditMessage".tp_loc(lang: lang)
        case .forwardMessage:
            "DahlSettings.Chats.Message.DoubleTapAction.ForwardMessage".tp_loc(lang: lang)
        case .forwardToSavedMessage:
            "DahlSettings.Chats.Message.DoubleTapAction.ForwardToSavedMessage".tp_loc(lang: lang)
        case .quickReaction:
            "DahlSettings.Chats.Message.DoubleTapAction.QuickReaction".tp_loc(lang: lang)
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .disabled:
            return nil
        case .quickReaction:
            return UIImage(bundleImageName: "Settings/MessageDoubleTap/QuickReaction")
        case .forwardMessage:
            return UIImage(bundleImageName: "Settings/MessageDoubleTap/Forward")
        case .forwardToSavedMessage:
            return UIImage(bundleImageName: "Settings/MessageDoubleTap/SavedMessage")
        case .editMessage:
            return UIImage(bundleImageName: "Settings/MessageDoubleTap/EditMessage")
        }
    }
}
