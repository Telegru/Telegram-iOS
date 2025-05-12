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
    let updateReport: (Bool) -> Void
    
    init(
        context: AccountContext,
        updateSaveSound: @escaping (Bool) -> Void,
        updateReply: @escaping (Bool) -> Void,
        updateReport: @escaping (Bool) -> Void
    ) {
        self.context = context
        self.updateSaveSound = updateSaveSound
        self.updateReply = updateReply
        self.updateReport = updateReport
    }
}

private enum DMessageMenuSettingsSection: Int32, CaseIterable {
    case options
}

private enum DMessageMenuSettingsEntryTag: ItemListItemTag {
    case saveSound
    case reply
    case report
    
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
    case reportItem(PresentationTheme, title: String, text: String, value: Bool)
    case footer(PresentationTheme, title: String)
    
    var section: ItemListSectionId {
        switch self {
        case .saveSoundItem, .replyItem, .reportItem, .footer:
            return DMessageMenuSettingsSection.options.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .saveSoundItem:
            return 0
        case .replyItem:
            return 1
        case .reportItem:
            return 2
        case .footer:
            return 3
        }
    }
    
    var tag: ItemListItemTag? {
        switch self {
        case .saveSoundItem:
            return DMessageMenuSettingsEntryTag.saveSound
        case .replyItem:
            return DMessageMenuSettingsEntryTag.reply
        case .reportItem:
            return DMessageMenuSettingsEntryTag.report
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
