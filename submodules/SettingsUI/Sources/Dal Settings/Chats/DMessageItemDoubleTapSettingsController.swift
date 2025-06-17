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

private final class DMessageItemDoubleTapSettingsArguments {
    let context: AccountContext
    let updateSelectedItem: (DMessageItemDoubleTapActionType) -> Void
    
    init(
        context: AccountContext,
        updateSelectedItem: @escaping (DMessageItemDoubleTapActionType) -> Void
    ) {
        self.context = context
        self.updateSelectedItem = updateSelectedItem
    }
}

private enum DMessageItemDoubleTapSettingsEntry: ItemListNodeEntry {
    case header(title: String)
    case item(
        type: DMessageItemDoubleTapActionType,
        title: String,
        icon: UIImage?,
        isSelected: Bool
    )
    case footer(title: String)
    
    var section: ItemListSectionId {
        0
    }
    
    var stableId: Int32 {
        switch self {
        case .header:
            return 0
        case let .item(type, _, _, _):
            return Int32(type.rawValue + 10)
        case .footer:
            return 1000
        }
    }
    
    static func ==(lhs: DMessageItemDoubleTapSettingsEntry, rhs: DMessageItemDoubleTapSettingsEntry) -> Bool {
        switch lhs {
            
        case let .header(lhsTitle):
            if case let .header(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
            
        case let .item(lhsType, lhsTitle, lhsIcon, lhsIsSelected):
            if case let .item(rhsType, rhsTitle, rhsIcon, rhsIsSelected) = rhs {
                return lhsType == rhsType && lhsTitle == rhsTitle && lhsIsSelected == rhsIsSelected && ((lhsIcon == nil && rhsIcon == nil) || (lhsIcon != nil && lhsIcon?.isEqual(rhsIcon) == true))
            }
            return false
            
        case let .footer(lhsTitle):
            if case let .footer(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
        }
    }
    
    static func <(
        lhs: DMessageItemDoubleTapSettingsEntry,
        rhs: DMessageItemDoubleTapSettingsEntry
    ) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(
        presentationData: ItemListPresentationData,
        arguments: Any
    ) -> ListViewItem {
        let arguments = arguments as! DMessageItemDoubleTapSettingsArguments
        
        switch self {
        case let .header(title):
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: title,
                sectionId: section
            )
            
        case let .item(type, title, icon, isSelected):
            return ItemListCheckboxItem(
                presentationData: presentationData,
                icon: icon ?? UIImage(),
                iconSize: CGSize(width: 20.0, height: 20.0),
                title: title,
                style: .right,
                checked: isSelected,
                zeroSeparatorInsets: false,
                sectionId: section,
                action: {
                    arguments.updateSelectedItem(type)
                }
            )
            
        case let .footer(title):
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain(title),
                sectionId: section
            )
        }
    }
}

private func dMessageItemDoubleTapSettingsEntries(
    presentationData: PresentationData,
    selectedType: DMessageItemDoubleTapActionType
) -> [DMessageItemDoubleTapSettingsEntry] {
    let lang = presentationData.strings.baseLanguageCode
    var entries = [DMessageItemDoubleTapSettingsEntry]()
    
    entries.append(
        .header(
            title: "DahlSettings.Chats.Message.DoubleTapAction.Header".tp_loc(lang: lang).uppercased()
        )
    )
    
    for actionType in DMessageItemDoubleTapActionType.allCases {
        entries.append(
            .item(
                type: actionType,
                title: actionType.localized(lang: lang),
                icon: generateTintedImage(
                    image: actionType.icon,
                    color: presentationData.theme.actionSheet.primaryTextColor
                ),
                isSelected: selectedType == actionType
            )
        )
    }
        
    
    entries.append(
        .footer(
            title: "DahlSettings.Chats.Message.DoubleTapAction.Footer".tp_loc(lang: lang)
        )
    )
    
    return entries
}

public func dMessageItemDoubleTapSettingsController(
    context: AccountContext
) -> ViewController {
    let arguments = DMessageItemDoubleTapSettingsArguments(
        context: context,
        updateSelectedItem: { value in
            let _ = updateDalSettingsInteractively(
                engine: context.engine,
                { settings in
                    var settings = settings
                    settings.chatsSettings.messageDoubleTapActionType = value
                    return settings
                }
            ).start()
        }
    )
    
    let doubleTapActionTypeSignal = (
        context.account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
        |> map { view -> DMessageItemDoubleTapActionType in
            return (view.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self) ?? DalSettings.defaultSettings).chatsSettings.messageDoubleTapActionType
        }
        |> distinctUntilChanged
    )
    
    let signal = combineLatest(
        context.sharedContext.presentationData,
        doubleTapActionTypeSignal
    )
    |> map { presentationData, doubleTapActionType -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let lang = presentationData.strings.baseLanguageCode
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("DahlSettings.Chats.Message.DoubleTapAction.Title".tp_loc(lang: lang)),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        
        let entries = dMessageItemDoubleTapSettingsEntries(
            presentationData: presentationData,
            selectedType: doubleTapActionType
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
