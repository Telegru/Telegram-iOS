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

private final class DContextMenuSettingsArguments {
    let context: AccountContext
    let openMessageMenu: () -> Void
    
    init(
        context: AccountContext,
        openMessageMenu: @escaping () -> Void
    ) {
        self.context = context
        self.openMessageMenu = openMessageMenu
    }
}

private enum DContextMenuSettingsSection: Int32, CaseIterable {
    case options
}

private enum DContextMenuSettingsEntry: ItemListNodeEntry {
    case messageMenu(PresentationTheme, title: String)
    case messageMenuFooter(PresentationTheme, title: String)
    
    var section: ItemListSectionId {
        switch self {
        case .messageMenu, .messageMenuFooter:
            return DContextMenuSettingsSection.options.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .messageMenu:
            return 0
        case .messageMenuFooter:
            return 1
        }
    }
    
    var tag: ItemListItemTag? {
        return nil
    }
    
    static func ==(lhs: DContextMenuSettingsEntry, rhs: DContextMenuSettingsEntry) -> Bool {
        switch lhs {
        case let .messageMenu(lhsTheme, lhsTitle):
            if case let .messageMenu(rhsTheme, rhsTitle) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
            
        case let .messageMenuFooter(lhsTheme, lhsTitle):
            if case let .messageMenuFooter(rhsTheme, rhsTitle) = rhs,
               lhsTheme === rhsTheme,
               lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        }
    }
    
    static func <(lhs: DContextMenuSettingsEntry, rhs: DContextMenuSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(
        presentationData: ItemListPresentationData,
        arguments: Any
    ) -> ListViewItem {
        let arguments = arguments as! DContextMenuSettingsArguments
        
        switch self {
        case let .messageMenu(_, title):
            return ItemListDisclosureItem(
                presentationData: presentationData,
                title: title,
                label: "",
                sectionId: self.section,
                style: .blocks,
                action: {
                    arguments.openMessageMenu()
                }
            )
            
        case let .messageMenuFooter(_, title):
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain(title),
                sectionId: self.section
            )
        }
    }
}

private func dContextMenuSettingsEntries(
    presentationData: PresentationData
) -> [DContextMenuSettingsEntry] {
    var entries: [DContextMenuSettingsEntry] = []
    let lang = presentationData.strings.baseLanguageCode
    
    entries.append(
        .messageMenu(
            presentationData.theme,
            title: "DahlSettings.ContextMenu.MessageMenu".tp_loc(lang: lang)
        )
    )
    
    entries.append(
        .messageMenuFooter(
            presentationData.theme,
            title: "DahlSettings.ContextMenu.Footer".tp_loc(lang: lang)
        )
    )
    
    return entries
}

public func dContextMenuSettingsController(
    context: AccountContext
) -> ViewController {
    var pushControllerImpl: ((ViewController) -> Void)?
    
    let arguments = DContextMenuSettingsArguments(
        context: context,
        openMessageMenu: {
            let controller = dMessageMenuSettingsController(context: context)
            pushControllerImpl?(controller)
        }
    )
    
    let signal = context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
            let entries = dContextMenuSettingsEntries(
                presentationData: presentationData
            )
            
            let controllerState = ItemListControllerState(
                presentationData: ItemListPresentationData(presentationData),
                title: .navigationItemTitle(
                    "DahlSettings.ContextMenu.Title".tp_loc(
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
    
    pushControllerImpl = { [weak controller] c in
        controller?.push(c)
    }
    
    return controller
}
