import Foundation
import UIKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import AccountContext
import AppBundle
import PresentationDataUtils

import TPUI
import TPStrings

private final class DMessageMenuSettingsArguments {
    let context: AccountContext
    let updateSaveSound: (Bool) -> Void
    let updateReply: (Bool) -> Void
    let updateReplyPrivately: (Bool) -> Void
    let updateReport: (Bool) -> Void
    let updateForwardWithoutName: (Bool) -> Void
    let updateSaved: (Bool) -> Void
    
    init(
        context: AccountContext,
        updateSaveSound: @escaping (Bool) -> Void,
        updateReply: @escaping (Bool) -> Void,
        updateReport: @escaping (Bool) -> Void,
        updateReplyPrivately: @escaping (Bool) -> Void,
        updateForwardWithoutName: @escaping (Bool) -> Void,
        updateSaved: @escaping (Bool) -> Void
    ) {
        self.context = context
        self.updateSaveSound = updateSaveSound
        self.updateReply = updateReply
        self.updateReplyPrivately = updateReplyPrivately
        self.updateReport = updateReport
        self.updateForwardWithoutName = updateForwardWithoutName
        self.updateSaved = updateSaved
    }
}

private enum DMessageMenuSettingsSection: Int32, CaseIterable {
    case options
}

private enum DMessageMenuSettingsEntryTag: ItemListItemTag {
    case saveSound
    case reply
    case replyPrivately
    case report
    case forwardWithoutName
    case saved
    
    func isEqual(to other: ItemListItemTag) -> Bool {
        if let other = other as? DMessageMenuSettingsEntryTag, self == other {
            return true
        } else {
            return false
        }
    }
}

private enum DMessageMenuSettingsEntry: ItemListNodeEntry {
    case saveSoundItem(PresentationTheme, title: String, value: Bool)
    case replyItem(PresentationTheme, title: String, value: Bool)
    case replyPrivatelyItem(PresentationTheme, title: String, text: String, value: Bool)
    case reportItem(PresentationTheme, title: String, text: String, value: Bool)
    case forwardWithoutName(PresentationTheme, title: String, value: Bool)
    case savedItem(PresentationTheme, title: String, value: Bool)
    case footer(PresentationTheme, title: String)
    
    var section: ItemListSectionId {
        switch self {
        case .saveSoundItem, .replyItem, .reportItem, .forwardWithoutName, .savedItem, .replyPrivatelyItem, .footer:
            return DMessageMenuSettingsSection.options.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .saveSoundItem:
            return 0
        case .replyItem:
            return 1
        case .replyPrivatelyItem:
            return 2
        case .forwardWithoutName:
            return 3
        case .savedItem:
            return 4
        case .reportItem:
            return 5
        case .footer:
            return 1000
        }
    }
    
    var tag: ItemListItemTag? {
        switch self {
        case .saveSoundItem:
            return DMessageMenuSettingsEntryTag.saveSound
        case .replyItem:
            return DMessageMenuSettingsEntryTag.reply
        case .replyPrivatelyItem:
            return DMessageMenuSettingsEntryTag.replyPrivately
        case .reportItem:
            return DMessageMenuSettingsEntryTag.report
        case .forwardWithoutName:
            return DMessageMenuSettingsEntryTag.forwardWithoutName
        case .savedItem:
            return DMessageMenuSettingsEntryTag.saved
        case .footer:
            return nil
        }
    }
    
    static func ==(lhs: DMessageMenuSettingsEntry, rhs: DMessageMenuSettingsEntry) -> Bool {
        switch lhs {
        case let .saveSoundItem(lhsTheme, lhsTitle, lhsValue):
            if case let .saveSoundItem(rhsTheme, rhsTitle, rhsValue) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle,
               lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .replyItem(lhsTheme, lhsTitle, lhsValue):
            if case let .replyItem(rhsTheme, rhsTitle, rhsValue) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle,
               lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .replyPrivatelyItem(lhsTheme, lhsTitle, lhsText, lhsValue):
            if case let .replyPrivatelyItem(rhsTheme, rhsTitle, rhsText, rhsValue) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle,
               lhsText == rhsText,
               lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .reportItem(lhsTheme, lhsTitle, lhsText, lhsValue):
            if case let .reportItem(rhsTheme, rhsTitle, rhsText, rhsValue) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle,
               lhsText == rhsText,
               lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .forwardWithoutName(lhsTheme, lhsTitle, lhsValue):
            if case let .forwardWithoutName(rhsTheme, rhsTitle, rhsValue) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle,
               lhsValue == rhsValue {
                return true
            } else {
                return false
            }

        case let .savedItem(lhsTheme, lhsTitle, lhsValue):
            if case let .savedItem(rhsTheme, rhsTitle, rhsValue) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle,
               lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .footer(lhsTheme, lhsTitle):
            if case let .footer(rhsTheme, rhsTitle) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        }
    }
    
    static func <(lhs: DMessageMenuSettingsEntry, rhs: DMessageMenuSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(
        presentationData: ItemListPresentationData,
        arguments: Any
    ) -> ListViewItem {
        let arguments = arguments as! DMessageMenuSettingsArguments
        
        switch self {
        case let .saveSoundItem(_, title, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                icon: generateTintedImage(image: TPIconManager.shared.icon(.contextMenuDownload), color: presentationData.theme.contextMenu.primaryColor),
                title: title,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateSaveSound(updatedValue)
                },
                tag: self.tag
            )
            
        case let .replyItem(_, title, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                icon: generateTintedImage(image: TPIconManager.shared.icon(.contextMenuReply), color: presentationData.theme.contextMenu.primaryColor),
                title: title,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateReply(updatedValue)
                },
                tag: self.tag
            )
            
        case let .replyPrivatelyItem(_, title, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                icon: generateTintedImage(image: TPIconManager.shared.icon(.contextMenuReplyPrivately), color: presentationData.theme.contextMenu.primaryColor),
                title: title,
                text: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateReplyPrivately(updatedValue)
                },
                tag: self.tag
            )
            
        case let .reportItem(_, title, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                icon: generateTintedImage(image: TPIconManager.shared.icon(.contextMenuReport), color: presentationData.theme.contextMenu.primaryColor),
                title: title,
                text: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateReport(updatedValue)
                },
                tag: self.tag
            )
            
        case let .forwardWithoutName(_, title, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                icon: generateTintedImage(image: TPIconManager.shared.icon(.contextMenuForwardWithoutName), color: presentationData.theme.contextMenu.primaryColor),
                title: title,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateForwardWithoutName(updatedValue)
                },
                tag: self.tag
            )

        case let .savedItem(_, title, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                icon: generateTintedImage(image: TPIconManager.shared.icon(.contextMenuSaved), color: presentationData.theme.contextMenu.primaryColor),
                title: title,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateSaved(updatedValue)
                },
                tag: self.tag
            )
            
        case let .footer(_, title):
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain(title),
                sectionId: self.section
            )
        }
    }
}

private func dMessageMenuSettingsEntries(
    presentationData: PresentationData,
    messageMenuSettings: DMessageMenuSettings
) -> [DMessageMenuSettingsEntry] {
    var entries: [DMessageMenuSettingsEntry] = []
    let lang = presentationData.strings.baseLanguageCode
    
    entries.append(
        .saveSoundItem(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.SaveSound".tp_loc(lang: lang),
            value: messageMenuSettings.saveSound
        )
    )
    
    entries.append(
        .replyItem(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.Reply".tp_loc(lang: lang),
            value: messageMenuSettings.reply
        )
    )
    
    entries.append(
        .replyPrivatelyItem(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.ReplyPrivately".tp_loc(lang: lang),
            text: "DahlSettings.MessageMenu.ReplyPrivatelyGroups".tp_loc(lang: lang),
            value: messageMenuSettings.replyPrivately
        )
    )
    
    entries.append(
        .forwardWithoutName(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.ForwardWithoutName".tp_loc(lang: lang),
            value: messageMenuSettings.forwardWithoutName
        )
    )

    entries.append(
        .savedItem(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.Saved".tp_loc(lang: lang),
            value: messageMenuSettings.saved
        )
    )
    
    entries.append(
        .reportItem(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.Report".tp_loc(lang: lang),
            text: "DahlSettings.MessageMenu.ReportGroups".tp_loc(lang: lang),
            value: messageMenuSettings.report
        )
    )
    
    entries.append(
        .footer(
            presentationData.theme,
            title: "DahlSettings.MessageMenu.Footer".tp_loc(lang: lang)
        )
    )
    
    return entries
}

public func dMessageMenuSettingsController(
    context: AccountContext
) -> ViewController {
    let arguments = DMessageMenuSettingsArguments(
        context: context,
        updateSaveSound: { value in
            let _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager,
                { settings in
                    var updatedSettings = settings
                    var updatedMessageMenuSettings = settings.messageMenuSettings
                    updatedMessageMenuSettings.saveSound = value
                    updatedSettings.messageMenuSettings = updatedMessageMenuSettings
                    return updatedSettings
                }
            ).start()
        },
        updateReply: { value in
            let _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager,
                { settings in
                    var updatedSettings = settings
                    var updatedMessageMenuSettings = settings.messageMenuSettings
                    updatedMessageMenuSettings.reply = value
                    updatedSettings.messageMenuSettings = updatedMessageMenuSettings
                    return updatedSettings
                }
            ).start()
        },
        updateReport: { value in
            let _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager,
                { settings in
                    var updatedSettings = settings
                    var updatedMessageMenuSettings = settings.messageMenuSettings
                    updatedMessageMenuSettings.report = value
                    updatedSettings.messageMenuSettings = updatedMessageMenuSettings
                    return updatedSettings
                }
            ).start()
        },
        updateReplyPrivately: { value in
            let _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager,
                { settings in
                    var updatedSettings = settings
                    var updatedMessageMenuSettings = settings.messageMenuSettings
                    updatedMessageMenuSettings.replyPrivately = value
                    updatedSettings.messageMenuSettings = updatedMessageMenuSettings
                    return updatedSettings
                }
            ).start()
        },
        updateForwardWithoutName: { value in
            let _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager,
                { settings in
                    var updatedSettings = settings
                    var updatedMessageMenuSettings = settings.messageMenuSettings
                    updatedMessageMenuSettings.forwardWithoutName = value
                    updatedSettings.messageMenuSettings = updatedMessageMenuSettings
                    return updatedSettings
                }
            ).start()
        },
        updateSaved: { value in
            let _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager,
                { settings in
                    var updatedSettings = settings
                    var updatedMessageMenuSettings = settings.messageMenuSettings
                    updatedMessageMenuSettings.saved = value
                    updatedSettings.messageMenuSettings = updatedMessageMenuSettings
                    return updatedSettings
                }
            ).start()
        }
    )
    
    let sharedData = context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.dalSettings])
    
    let signal = combineLatest(
        sharedData,
        context.sharedContext.presentationData
    ) |> map { sharedData, presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let dahlSettings = sharedData.entries[ApplicationSpecificSharedDataKeys.dalSettings]?.get(DalSettings.self) ?? .defaultSettings
        
        let entries = dMessageMenuSettingsEntries(
            presentationData: presentationData,
            messageMenuSettings: dahlSettings.messageMenuSettings
        )
        
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .navigationItemTitle(
                "DahlSettings.MessageMenu.Title".tp_loc(
                    lang: presentationData.strings.baseLanguageCode
                )
            ),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks
        )
        
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    
    return controller
}
