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
import UndoUI

import TPUI
import TPStrings

private final class DAppearanceSettingsArguments {
    let context: AccountContext
    
    let updateShowCustomWallpaperInChannels: (Bool) -> Void
    let updateChannelBottomPanel: (Bool) -> Void
    let updateChatsListViewType: (DChatListViewStyle) -> Void
    let updateViewRounding: (Bool) -> Void
    let updateVKIcons: (Bool) -> Void
    let updateAlternativeFontInAvatars: (Bool) -> Void
    let updateShowChatListSeparators: (Bool) -> Void
    
    init(
        context: AccountContext,
        updateShowCustomWallpaperInChannels: @escaping (Bool) -> Void,
        updateChannelBottomPanel: @escaping (Bool) -> Void,
        updateChatsListViewType: @escaping (DChatListViewStyle) -> Void,
        updateViewRounding: @escaping (Bool) -> Void,
        updateVKIcons: @escaping (Bool) -> Void,
        updateAlternativeFontInAvatars: @escaping (Bool) -> Void,
        updateShowChatListSeparators: @escaping (Bool) -> Void
    ) {
        self.context = context
        self.updateShowCustomWallpaperInChannels = updateShowCustomWallpaperInChannels
        self.updateChannelBottomPanel = updateChannelBottomPanel
        self.updateChatsListViewType = updateChatsListViewType
        self.updateViewRounding = updateViewRounding
        self.updateVKIcons = updateVKIcons
        self.updateAlternativeFontInAvatars = updateAlternativeFontInAvatars
        self.updateShowChatListSeparators = updateShowChatListSeparators
    }
}

private enum DAppearanceSettingsSection: Int32 {
    case chatsAppearance
    case listViewType
    case viewRounding
    case avatarFont
    case icons
}

private enum DAppearanceSettingsEntry: ItemListNodeEntry {
    case chatsAppearanceHeader(title: String)
    case showCustomWallpaperInChannels(title: String, isActive: Bool)
    case showChannelBottomPanel(title: String, isActive: Bool)
    
    case listViewTypeHeader(title: String)
    case listViewTypeOptions(types: [DChatListViewStyle], currentType: DChatListViewStyle, theme: PresentationTheme)
    case showChatListSeparators(title: String, isActive: Bool)
    
    case viewRoundingHeader(title: String)
    case viewRounding(title: String, isActive: Bool)
    
    case avatarFontHeader(title: String)
    case avatarFont(title: String, isActive: Bool)
    case avatarFontFooter(text: NSAttributedString)
    
    case iconsHeader(title: String)
    case vkIcons(title: String, isActive: Bool)
    case iconsPreview(PresentationTheme)
    
    var section: ItemListSectionId {
        switch self {
        case .chatsAppearanceHeader, .showCustomWallpaperInChannels, .showChannelBottomPanel:
            return DAppearanceSettingsSection.chatsAppearance.rawValue
            
        case .listViewTypeHeader, .listViewTypeOptions, .showChatListSeparators:
            return DAppearanceSettingsSection.listViewType.rawValue
            
        case .viewRoundingHeader, .viewRounding:
            return DAppearanceSettingsSection.viewRounding.rawValue
            
        case .avatarFontHeader, .avatarFont, .avatarFontFooter:
            return DAppearanceSettingsSection.avatarFont.rawValue
            
        case .iconsHeader, .vkIcons, .iconsPreview:
            return DAppearanceSettingsSection.icons.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .chatsAppearanceHeader:
            return 0
        case .showCustomWallpaperInChannels:
            return 1
        case .showChannelBottomPanel:
            return 2
        case .listViewTypeHeader:
            return 3
        case .listViewTypeOptions:
            return 4
        case .showChatListSeparators:
            return 5
        case .viewRoundingHeader:
            return 6
        case .viewRounding:
            return 7
        case .avatarFontHeader:
            return 8
        case .avatarFont:
            return 9
        case .avatarFontFooter:
            return 10
        case .iconsHeader:
            return 11
        case .vkIcons:
            return 12
        case .iconsPreview:
            return 13
        }
    }
    
    static func == (lhs: DAppearanceSettingsEntry, rhs: DAppearanceSettingsEntry) -> Bool {
        switch lhs {
        case let .chatsAppearanceHeader(lhsTitle):
            if case let .chatsAppearanceHeader(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
            
        case let .showCustomWallpaperInChannels(lhsTitle, lhsIsActive):
            if case let .showCustomWallpaperInChannels(rhsTitle, rhsIsActive) = rhs {
                return lhsTitle == rhsTitle && lhsIsActive == rhsIsActive
            }
            return false
            
        case let .showChannelBottomPanel(lhsTitle, lhsIsActive):
            if case let .showChannelBottomPanel(rhsTitle, rhsIsActive) = rhs {
                return lhsTitle == rhsTitle && lhsIsActive == rhsIsActive
            }
            return false
            
        case let .listViewTypeHeader(lhsTitle):
            if case let .listViewTypeHeader(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
            
        case let .listViewTypeOptions(lhsTypes, lhsCurrentType, lhsTheme):
            if case let .listViewTypeOptions(rhsTypes, rhsCurrentType, rhsTheme) = rhs {
                return lhsTypes == rhsTypes && lhsCurrentType == rhsCurrentType && lhsTheme === rhsTheme
            }
            return false
            
        case let .showChatListSeparators(lhsTitle, lhsIsActive):
            if case let .showChatListSeparators(rhsTitle, rhsIsActive) = rhs {
                return lhsTitle == rhsTitle && lhsIsActive == rhsIsActive
            }
            return false
            
        case let .viewRoundingHeader(lhsTitle):
            if case let .viewRoundingHeader(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
        
        case let .viewRounding(lhsTitle, lhsIsActive):
            if case let .viewRounding(rhsTitle, rhsIsActive) = rhs {
                return lhsTitle == rhsTitle && lhsIsActive == rhsIsActive
            }
            return false
            
        case let .avatarFontHeader(lhsTitle):
            if case let .avatarFontHeader(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
            
        case let .avatarFont(lhsTitle, lhsIsActive):
            if case let .avatarFont(rhsTitle, rhsIsActive) = rhs {
                return lhsTitle == rhsTitle && lhsIsActive == rhsIsActive
            }
            return false

        case let .avatarFontFooter(lhsTitle):
            if case let .avatarFontFooter(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
            
        case let .iconsHeader(lhsTitle):
            if case let .iconsHeader(rhsTitle) = rhs {
                return lhsTitle == rhsTitle
            }
            return false
            
        case let .vkIcons(lhsTitle, lhsIsActive):
            if case let .vkIcons(rhsTitle, rhsIsActive) = rhs {
                return lhsTitle == rhsTitle && lhsIsActive == rhsIsActive
            }
            return false

        case let .iconsPreview(lhsTheme):
            if case let .iconsPreview(rhsTheme) = rhs {
                return lhsTheme === rhsTheme
            }
            return false
        }
    }
    
    static func <(lhs: DAppearanceSettingsEntry, rhs: DAppearanceSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! DAppearanceSettingsArguments
        switch self {
        case let .chatsAppearanceHeader(title):
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: title,
                sectionId: self.section
            )
            
        case let .showCustomWallpaperInChannels(title, isActive):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: isActive,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateShowCustomWallpaperInChannels(value)
                }
            )
            
        case let .showChannelBottomPanel(title, isActive):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: isActive,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateChannelBottomPanel(value)
                }
            )
            
        case let .listViewTypeHeader(title):
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: title,
                sectionId: self.section
            )
            
        case let .listViewTypeOptions(types, currentType, theme):
            return DChatListStyleCarouselItem(
                context: arguments.context,
                sectionId: self.section,
                theme: theme,
                strings: presentationData.strings,
                types: types,
                currentType: currentType,
                updateType: { type in
                    arguments.updateChatsListViewType(type)
                }
            )
            
        case let .showChatListSeparators(title, isActive):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: isActive,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateShowChatListSeparators(value)
                }
            )
            
        case let .viewRoundingHeader(title):
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: title,
                sectionId: self.section
            )
            
        case let .viewRounding(title, isActive):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: isActive,
                sectionId: section,
                style: .blocks) { value in
                    arguments.updateViewRounding(value)
                }
            
        case let .avatarFontHeader(title):
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: title,
                sectionId: self.section
            )
            
        case let .avatarFont(title, isActive):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: isActive,
                sectionId: section,
                style: .blocks) { value in
                    arguments.updateAlternativeFontInAvatars(value)
                }
            
        case let .avatarFontFooter(text):
            return ItemListTextItem(
                presentationData: presentationData,
                text: .custom(context: arguments.context, string: text),
                sectionId: self.section,
                style: .blocks
            )
            
        case let .iconsHeader(title):
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: title,
                sectionId: self.section
            )
            
        case let .vkIcons(title, isActive):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: title,
                value: isActive,
                sectionId: section,
                style: .blocks) { value in
                    arguments.updateVKIcons(value)
                }

        case .iconsPreview:
            return DIconSetPreviewItem(
                presentationData: presentationData,
                sectionId: section
            )
        }
    }
}

public func dAppearanceSettingsController(
    context: AccountContext
) -> ViewController {
    var showRestartToast: (() -> Void)?
    
    let arguments = DAppearanceSettingsArguments(
        context: context,
        updateShowCustomWallpaperInChannels: { value in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.appearanceSettings.showCustomWallpaperInChannels = value
                return updatedSettings
            }
            .start()
        },
        updateChannelBottomPanel: { value in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.appearanceSettings.showChannelBottomPanel = value
                return updatedSettings
            }
            .start()
        },
        updateChatsListViewType: { selectedType in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.chatsListViewType = selectedType
                return updatedSettings
            }
            .start()
        },
        updateViewRounding: { value in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.appearanceSettings.squareStyle = value
                return updatedSettings
            }
            .start()
        },
        updateVKIcons: { value in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.appearanceSettings.vkIcons = value
                return updatedSettings
            }
            .start()
        },
        updateAlternativeFontInAvatars: { value in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.appearanceSettings.alternativeAvatarFont = value
                return updatedSettings
            }
            .start()
            
            if DFontManager.shared.isAlternativeFontEnabled != value {
                showRestartToast?()
            }
        },
        updateShowChatListSeparators: { value in
            let _ = updateDalSettingsInteractively(engine: context.engine) { settings in
                var updatedSettings = settings
                updatedSettings.appearanceSettings.showChatListSeparators = value
                return updatedSettings
            }.start()
        }
    )
    
    let dahlSettingsSignal = context.account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
    |> map { view -> DalSettings in
        return view.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self) ?? DalSettings.defaultSettings
    } |> distinctUntilChanged
    
    let signal = combineLatest(
        queue: .mainQueue(),
        context.sharedContext.presentationData,
        dahlSettingsSignal
    ) |> map { presentationData, dahlSettings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        
        let lang = presentationData.strings.baseLanguageCode
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("DahlSettings.Appearance.Title".tp_loc(lang: lang)),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        
        var entries: [DAppearanceSettingsEntry] = []
        
        entries.append(.chatsAppearanceHeader(title: "DahlSettings.Appearance.Chats.Header".tp_loc(lang: lang).uppercased()))
        entries.append(
            .showCustomWallpaperInChannels(
                title: "DahlSettings.Appearance.Chats.CustomChannelWallpapers".tp_loc(lang: lang),
                isActive: dahlSettings.appearanceSettings.showCustomWallpaperInChannels
            )
        )
        entries.append(
            .showChannelBottomPanel(
                title: "DahlSettings.Appearance.Chats.ChannelBottomPanel".tp_loc(lang: lang),
                isActive: dahlSettings.appearanceSettings.showChannelBottomPanel
            )
        )
        
        entries.append(
            .listViewTypeHeader(title: "DahlSettings.Appearance.ChatsList.Header".tp_loc(lang: lang).uppercased())
        )
        
        entries.append(.listViewTypeOptions(types: DChatListViewStyle.allCases, currentType: dahlSettings.chatsListViewType, theme: presentationData.theme))
        
        entries.append(
            .showChatListSeparators(
                title: "DahlSettings.Appearance.ChatsList.ShowSeparators".tp_loc(lang: lang),
                isActive: dahlSettings.appearanceSettings.showChatListSeparators
            )
        )
        
        entries.append(
            .viewRoundingHeader(
                title: "DahlSettings.Appearance.ViewRounding.Header".tp_loc(lang: lang).uppercased()
            )
        )
        
        entries.append(
            .viewRounding(
                title: "DahlSettings.Appearance.ViewRounding".tp_loc(lang: lang),
                isActive: dahlSettings.appearanceSettings.squareStyle
            )
        )
        
        entries.append(
            .avatarFontHeader(
                title: "DahlSettings.Appearance.AvatarFont.Header".tp_loc(lang: lang).uppercased()
            )
        )
        
        entries.append(
            .avatarFont(
                title: "DahlSettings.Appearance.AvatarFont".tp_loc(lang: lang),
                isActive: dahlSettings.appearanceSettings.alternativeAvatarFont
            )
        )
        
        let tableFont = Font.regular(13.0)
        let presentationData = arguments.context.sharedContext.currentPresentationData.with { $0 }
        let footerTextColor = presentationData.theme.list.sectionHeaderTextColor
        let footerHighlightColor = presentationData.theme.list.itemPrimaryTextColor
        let avatarFontString = NSMutableAttributedString(string: "DahlSettings.Appearance.AvatarFont.Footer".tp_loc(lang: lang), font: tableFont, paragraphAlignment: .left)
        var highlightStartPosition: Int = 0
        if let highlightIndex = avatarFontString.string.firstIndex(of: ":") {
            highlightStartPosition = avatarFontString.string.distance(from: avatarFontString.string.startIndex, to: highlightIndex) + 1
        }
        avatarFontString.addAttribute(.foregroundColor, value: footerTextColor, range: NSRange(location: 0, length: highlightStartPosition))
        avatarFontString.addAttribute(.foregroundColor, value: footerHighlightColor, range: NSRange(location: highlightStartPosition, length: avatarFontString.length - highlightStartPosition - 1))
        
        entries.append(
            .avatarFontFooter(text: avatarFontString)
        )
        
        entries.append(
            .iconsHeader(
                title: "DahlSettings.Appearance.Icons.Header".tp_loc(lang: lang).uppercased()
            )
        )
        
        entries.append(
            .vkIcons(
                title: "DahlSettings.Appearance.Icons.VKUI".tp_loc(lang: lang),
                isActive: dahlSettings.appearanceSettings.vkIcons
            )
        )
        
//        entries.append(.iconsPreview(presentationData.theme))
        
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks,
            animateChanges: true
        )
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    
    showRestartToast = { [weak controller] in
        guard let controller else { return }
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let lang = presentationData.strings.baseLanguageCode
        let presenting = UndoOverlayController(
            presentationData: presentationData,
            content: .info(
                title: nil,
                text: "DahlSettings.Common.RestartRequired".tp_loc(lang: lang),
                timeout: nil,
                customUndoText: "DahlSettings.Common.RestartNow".tp_loc(lang: lang)
            ),
            elevatedLayout: false,
            action: { action in if action == .undo { exit(0) }; return true }
        )
        controller.present(presenting, in: .window(.root))
    }
    
    return controller
}
