import UIKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramUIPreferences
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext

private final class DChatTextFormattingSettingsControllerArguments {
    let context: AccountContext
    let updateShowFormattingPanel: (Bool) -> Void
    
    init(
        context: AccountContext,
        updateShowFormattingPanel: @escaping (Bool) -> Void
    ) {
        self.context = context
        self.updateShowFormattingPanel = updateShowFormattingPanel
    }
}

private enum DChatTextFormattingSettingsSection: Int32 {
    case toggle
}

private enum DChatTextFormattingSettingsEntry: ItemListNodeEntry {
    case toggleFormattingPanel(title: String, value: Bool)
    
    var section: ItemListSectionId {
        switch self {
        case .toggleFormattingPanel:
            return DChatTextFormattingSettingsSection.toggle.rawValue
        }
    }
    
    var stableId: Int {
        switch self {
        case .toggleFormattingPanel:
            return 0
        }
    }
    
    static func ==(
        lhs: DChatTextFormattingSettingsEntry,
        rhs: DChatTextFormattingSettingsEntry
    ) -> Bool {
        switch lhs {
        case let .toggleFormattingPanel(lhsTitle, lhsValue):
            if case let .toggleFormattingPanel(rhsTitle, rhsValue) = rhs,
               lhsTitle == rhsTitle,
               lhsValue == rhsValue {
                return true
            }
            return false
        }
    }
    
    static func <(
        lhs: DChatTextFormattingSettingsEntry,
        rhs: DChatTextFormattingSettingsEntry
    ) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(
        presentationData: ItemListPresentationData,
        arguments: Any
    ) -> ListViewItem {
        let arguments = arguments as! DChatTextFormattingSettingsControllerArguments
        switch self {
        case let .toggleFormattingPanel(title, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: value,
                sectionId: section,
                style: .blocks,
                updated: { updatedValue in
                    arguments.updateShowFormattingPanel(updatedValue)
                }
            )
        }
    }
}

public func dChatTextFormattingSettingsController(
    context: AccountContext
) -> ViewController {
    let arguments = DChatTextFormattingSettingsControllerArguments(
        context: context,
        updateShowFormattingPanel: { value in
            _ = updateDalSettingsInteractively(
                accountManager: context.sharedContext.accountManager) { settings in
                    var updatedSettings = settings
                    updatedSettings.chatsSettings.formattingPanelEnabled = value
                    return updatedSettings
                }
                .start()
        }
    )
    
    let showFormattingPanelSignal = context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.dalSettings])
    |> map { sharedData -> Bool in
        let dahlSettings = sharedData.entries[ApplicationSpecificSharedDataKeys.dalSettings]?.get(DalSettings.self) ?? .defaultSettings
        return dahlSettings.chatsSettings.formattingPanelEnabled
    } |> distinctUntilChanged
    
    let signal = combineLatest(
        context.sharedContext.presentationData,
        showFormattingPanelSignal
    ) |> map { presentationData, showFormattingPanel -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("DahlSettings.Chats.Keyboard.TextFormatting".tp_loc(lang: presentationData.strings.baseLanguageCode)),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back),
            animateChanges: true
        )
        
        let lang = presentationData.strings.baseLanguageCode
        var entries: [DChatTextFormattingSettingsEntry] = []
        
        entries.append(
            .toggleFormattingPanel(
                title: "DahlSettings.Chats.Keyboard.TextFormatting.Toolbar".tp_loc(lang: lang),
                value: showFormattingPanel
            )
        )
        
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks
        )
        
        return (controllerState, (listState, arguments))
    }
    
    return ItemListController(context: context, state: signal)
}
