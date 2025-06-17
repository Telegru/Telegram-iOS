import Foundation
import TelegramUIPreferences
import TelegramCore

extension DalSettings {
    
    func toDTO() -> ConfigDTO {
        ConfigDTO(
            appearanceAlternativeAvatarFont: self.appearanceSettings.alternativeAvatarFont,
            appearanceShowChannelBottomPanel: self.appearanceSettings.showChannelBottomPanel,
            appearanceShowCustomWallpaperInChannels: self.appearanceSettings.showCustomWallpaperInChannels,
            appearanceSquareStyle: self.appearanceSettings.squareStyle,
            appearanceVkIcons: self.appearanceSettings.vkIcons,
            appearanceShowSeparators: self.appearanceSettings.showChatListSeparators,
            callConfirmation: self.callConfirmation,
            chatFullscreenInput: self.chatFullscreenInput,
            chatsFoldersAtBottom: self.chatsFoldersAtBottom,
            chatsFormattingPanelEnabled: self.chatsSettings.formattingPanelEnabled,
            chatsListViewType: self.chatsListViewType.rawValue,
            chatsMessageDoubleTapActionType: self.chatsSettings.messageDoubleTapActionType.rawValue,
            hideAllChatsFolder: self.hideAllChatsFolder,
            hidePhone: self.hidePhone,
            infiniteScrolling: self.infiniteScrolling,
            iosActiveTabs: self.tabBarSettings.activeTabs.map(\.rawValue),
            iosShowTabTitles: self.tabBarSettings.showTabTitles,
            messageMenuReply: self.messageMenuSettings.reply,
            messageMenuReport: self.messageMenuSettings.report,
            messageMenuSaveSound: self.messageMenuSettings.saveSound,
            messageMenuForwardWithoutName: self.messageMenuSettings.forwardWithoutName,
            messageMenuSaved: self.messageMenuSettings.saved,
            messageMenuReplyPrivately: self.messageMenuSettings.replyPrivately,
            premiumShowAnimatedAvatar: self.premiumSettings.showAnimatedAvatar,
            premiumShowAnimatedReactions: self.premiumSettings.showAnimatedReactions,
            premiumShowAnimatedSticker: self.premiumSettings.showPremiumStickerAnimation,
            premiumShowStatusIcon: self.premiumSettings.showStatusIcon,
            sendAudioConfirmation: self.sendAudioConfirmation,
            settingsScreenShowBusiness: self.menuItemsSettings.business,
            settingsScreenShowChatFolders: self.menuItemsSettings.chatFolders,
            settingsScreenShowDevices: self.menuItemsSettings.devices,
            settingsScreenShowFAQ: self.menuItemsSettings.faq,
            settingsScreenShowMyProfile: self.menuItemsSettings.myProfile,
            settingsScreenShowMyStars: self.menuItemsSettings.myStars,
            settingsScreenShowPremium: self.menuItemsSettings.premium,
            settingsScreenShowRecentCalls: self.menuItemsSettings.recentCalls,
            settingsScreenShowSavedMsgs: self.menuItemsSettings.savedMessages,
            settingsScreenShowSendGift: self.menuItemsSettings.sendGift,
            settingsScreenShowSupport: self.menuItemsSettings.support,
            settingsScreenShowTips: self.menuItemsSettings.tips,
            settingsScreenShowWallet: self.menuItemsSettings.wallet,
            showChatFolders: self.showChatFolders,
            showRecentChats: self.showRecentChats,
            storiesHidePublishButton: self.hidePublishStoriesButton,
            storiesHideStories: self.hideStories,
            storiesHideViewedStories: self.hideViewedStories,
            storiesPostingGestureEnabled: self.isStoriesPostingGestureEnabled,
            videoMessageCamera: self.videoMessageCamera.identifier,
            wallExcludedChannels: self.wallSettings.excludedChannels.map { $0.id._internalGetInt64Value() },
            wallMarkAsRead: self.wallSettings.markAsRead,
            wallShowArchivedChannels: self.wallSettings.showArchivedChannels
        )
    }
}

extension ConfigDTO {
    
    func toPlain() -> DalSettings {
        return DalSettings(
            tabBarSettings: DTabBarSettings(
                currentTabs: self.iosActiveTabs.compactMap { .init(rawValue: $0) },
                showTabTitles: self.iosShowTabTitles
            ),
            menuItemsSettings: MenuItemsSettings(
                myProfile: self.settingsScreenShowMyProfile,
                wallet: self.settingsScreenShowWallet,
                savedMessages: self.settingsScreenShowSavedMsgs,
                recentCalls: self.settingsScreenShowRecentCalls,
                devices: self.settingsScreenShowDevices,
                chatFolders: self.settingsScreenShowChatFolders,
                premium: self.settingsScreenShowPremium,
                myStars: self.settingsScreenShowMyStars,
                business: self.settingsScreenShowBusiness,
                sendGift: self.settingsScreenShowSendGift,
                support: self.settingsScreenShowSupport,
                faq: self.settingsScreenShowFAQ,
                tips: self.settingsScreenShowTips
            ),
            premiumSettings: DPremiumSettings(
                showStatusIcon: self.premiumShowStatusIcon,
                showAnimatedAvatar: self.premiumShowAnimatedAvatar,
                showAnimatedReactions: self.premiumShowAnimatedReactions,
                showPremiumStickerAnimation: self.premiumShowAnimatedSticker
            ),
            appearanceSettings: DAppearanceSettings(
                squareStyle: self.appearanceSquareStyle,
                vkIcons: self.appearanceVkIcons,
                alternativeAvatarFont: self.appearanceAlternativeAvatarFont,
                showCustomWallpaperInChannels: self.appearanceShowCustomWallpaperInChannels,
                showChannelBottomPanel: self.appearanceShowChannelBottomPanel,
                showChatListSeparators: self.appearanceShowSeparators
            ),
            chatsSettings: DChatsSettings(
                formattingPanelEnabled: self.chatsFormattingPanelEnabled,
                messageDoubleTapActionType: DMessageItemDoubleTapActionType(rawValue: self.chatsMessageDoubleTapActionType) ?? .quickReaction
            ),
            wallSettings: DWallSettings(
                markAsRead: self.wallMarkAsRead,
                showArchivedChannels: self.wallShowArchivedChannels,
                excludedChannels: self.wallExcludedChannels.map { EnginePeer.Id($0) }
            ),
            messageMenuSettings: DMessageMenuSettings(
                saveSound: self.messageMenuSaveSound,
                reply: self.messageMenuReply,
                report: self.messageMenuReport,
                forwardWithoutName: self.messageMenuForwardWithoutName,
                saved: self.messageMenuSaved,
                replyPrivately: self.messageMenuReplyPrivately
            ),
            hidePublishStoriesButton: self.storiesHidePublishButton,
            hideStories: self.storiesHideStories,
            hideViewedStories: self.storiesHideViewedStories,
            isStoriesPostingGestureEnabled: self.storiesPostingGestureEnabled,
            hidePhone: self.hidePhone,
            disableReadHistory: false,
            offlineMode: false,
            sendAudioConfirmation: self.sendAudioConfirmation,
            callConfirmation: self.callConfirmation,
            videoMessageCamera: CameraType(identifier: self.videoMessageCamera),
            chatsFoldersAtBottom: self.chatsFoldersAtBottom,
            hideAllChatsFolder: self.hideAllChatsFolder,
            infiniteScrolling: self.infiniteScrolling,
            showChatFolders: self.showChatFolders,
            showRecentChats: self.showRecentChats,
            chatsListViewType: DChatListViewStyle(rawValue: self.chatsListViewType)!,
            chatFullscreenInput: self.chatFullscreenInput
        )
    }
}
