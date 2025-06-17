import Foundation
import TelegramUIPreferences

struct SessionConfigDTO: Codable {
    let config: ConfigDTO
    let isDefault: Bool
    
    init(
        config: ConfigDTO
    ) {
        self.config = config
        self.isDefault = false
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? true
        self.config = try container.decode(ConfigDTO.self, forKey: .config)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isDefault, forKey: .isDefault)
        try container.encode(self.config, forKey: .config)
    }
    
    enum CodingKeys: String, CodingKey {
        case config
        case isDefault = "is_default"
    }
}

struct ConfigDTO: Codable {
    
    let appearanceAlternativeAvatarFont, appearanceShowChannelBottomPanel, appearanceShowCustomWallpaperInChannels, appearanceSquareStyle: Bool
    let appearanceVkIcons, appearanceShowSeparators, callConfirmation, chatFullscreenInput, chatsFoldersAtBottom: Bool
    let chatsFormattingPanelEnabled: Bool
    let chatsListViewType, chatsMessageDoubleTapActionType: Int32
    let hideAllChatsFolder, hidePhone, infiniteScrolling: Bool
    let iosActiveTabs: [Int]
    let iosShowTabTitles, messageMenuReply, messageMenuReport, messageMenuSaveSound, messageMenuForwardWithoutName, messageMenuSaved, messageMenuReplyPrivately: Bool
    let premiumShowAnimatedAvatar, premiumShowAnimatedReactions, premiumShowAnimatedSticker, premiumShowStatusIcon: Bool
    let sendAudioConfirmation, settingsScreenShowBusiness, settingsScreenShowChatFolders, settingsScreenShowDevices: Bool
    let settingsScreenShowFAQ, settingsScreenShowMyProfile, settingsScreenShowMyStars, settingsScreenShowPremium: Bool
    let settingsScreenShowRecentCalls, settingsScreenShowSavedMsgs, settingsScreenShowSendGift, settingsScreenShowSupport: Bool
    let settingsScreenShowTips, settingsScreenShowWallet, showChatFolders, showRecentChats: Bool
    let storiesHidePublishButton, storiesHideStories, storiesHideViewedStories, storiesPostingGestureEnabled: Bool
    let videoMessageCamera: Int32
    let wallExcludedChannels: [Int64]
    let wallMarkAsRead, wallShowArchivedChannels: Bool
    
    init(appearanceAlternativeAvatarFont: Bool, appearanceShowChannelBottomPanel: Bool, appearanceShowCustomWallpaperInChannels: Bool, appearanceSquareStyle: Bool, appearanceVkIcons: Bool, appearanceShowSeparators: Bool, callConfirmation: Bool, chatFullscreenInput: Bool, chatsFoldersAtBottom: Bool, chatsFormattingPanelEnabled: Bool, chatsListViewType: Int32, chatsMessageDoubleTapActionType: Int32, hideAllChatsFolder: Bool, hidePhone: Bool, infiniteScrolling: Bool, iosActiveTabs: [Int], iosShowTabTitles: Bool, messageMenuReply: Bool, messageMenuReport: Bool, messageMenuSaveSound: Bool, messageMenuForwardWithoutName: Bool, messageMenuSaved: Bool, messageMenuReplyPrivately: Bool, premiumShowAnimatedAvatar: Bool, premiumShowAnimatedReactions: Bool, premiumShowAnimatedSticker: Bool, premiumShowStatusIcon: Bool, sendAudioConfirmation: Bool, settingsScreenShowBusiness: Bool, settingsScreenShowChatFolders: Bool, settingsScreenShowDevices: Bool, settingsScreenShowFAQ: Bool, settingsScreenShowMyProfile: Bool, settingsScreenShowMyStars: Bool, settingsScreenShowPremium: Bool, settingsScreenShowRecentCalls: Bool, settingsScreenShowSavedMsgs: Bool, settingsScreenShowSendGift: Bool, settingsScreenShowSupport: Bool, settingsScreenShowTips: Bool, settingsScreenShowWallet: Bool, showChatFolders: Bool, showRecentChats: Bool, storiesHidePublishButton: Bool, storiesHideStories: Bool, storiesHideViewedStories: Bool, storiesPostingGestureEnabled: Bool, videoMessageCamera: Int32, wallExcludedChannels: [Int64], wallMarkAsRead: Bool, wallShowArchivedChannels: Bool) {
        self.appearanceAlternativeAvatarFont = appearanceAlternativeAvatarFont
        self.appearanceShowChannelBottomPanel = appearanceShowChannelBottomPanel
        self.appearanceShowCustomWallpaperInChannels = appearanceShowCustomWallpaperInChannels
        self.appearanceSquareStyle = appearanceSquareStyle
        self.appearanceShowSeparators = appearanceShowSeparators
        self.appearanceVkIcons = appearanceVkIcons
        self.callConfirmation = callConfirmation
        self.chatFullscreenInput = chatFullscreenInput
        self.chatsFoldersAtBottom = chatsFoldersAtBottom
        self.chatsFormattingPanelEnabled = chatsFormattingPanelEnabled
        self.chatsListViewType = chatsListViewType
        self.chatsMessageDoubleTapActionType = chatsMessageDoubleTapActionType
        self.hideAllChatsFolder = hideAllChatsFolder
        self.hidePhone = hidePhone
        self.infiniteScrolling = infiniteScrolling
        self.iosActiveTabs = iosActiveTabs
        self.iosShowTabTitles = iosShowTabTitles
        self.messageMenuReply = messageMenuReply
        self.messageMenuReport = messageMenuReport
        self.messageMenuSaveSound = messageMenuSaveSound
        self.messageMenuForwardWithoutName = messageMenuForwardWithoutName
        self.messageMenuSaved = messageMenuSaved
        self.messageMenuReplyPrivately = messageMenuReplyPrivately
        self.premiumShowAnimatedAvatar = premiumShowAnimatedAvatar
        self.premiumShowAnimatedReactions = premiumShowAnimatedReactions
        self.premiumShowAnimatedSticker = premiumShowAnimatedSticker
        self.premiumShowStatusIcon = premiumShowStatusIcon
        self.sendAudioConfirmation = sendAudioConfirmation
        self.settingsScreenShowBusiness = settingsScreenShowBusiness
        self.settingsScreenShowChatFolders = settingsScreenShowChatFolders
        self.settingsScreenShowDevices = settingsScreenShowDevices
        self.settingsScreenShowFAQ = settingsScreenShowFAQ
        self.settingsScreenShowMyProfile = settingsScreenShowMyProfile
        self.settingsScreenShowMyStars = settingsScreenShowMyStars
        self.settingsScreenShowPremium = settingsScreenShowPremium
        self.settingsScreenShowRecentCalls = settingsScreenShowRecentCalls
        self.settingsScreenShowSavedMsgs = settingsScreenShowSavedMsgs
        self.settingsScreenShowSendGift = settingsScreenShowSendGift
        self.settingsScreenShowSupport = settingsScreenShowSupport
        self.settingsScreenShowTips = settingsScreenShowTips
        self.settingsScreenShowWallet = settingsScreenShowWallet
        self.showChatFolders = showChatFolders
        self.showRecentChats = showRecentChats
        self.storiesHidePublishButton = storiesHidePublishButton
        self.storiesHideStories = storiesHideStories
        self.storiesHideViewedStories = storiesHideViewedStories
        self.storiesPostingGestureEnabled = storiesPostingGestureEnabled
        self.videoMessageCamera = videoMessageCamera
        self.wallExcludedChannels = wallExcludedChannels
        self.wallMarkAsRead = wallMarkAsRead
        self.wallShowArchivedChannels = wallShowArchivedChannels
    }
    
    init(from decoder: any Decoder) throws {
        let configContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.appearanceAlternativeAvatarFont = try configContainer.decodeIfPresent(Bool.self, forKey: .appearanceAlternativeAvatarFont) ?? false
        self.appearanceShowChannelBottomPanel = try configContainer.decodeIfPresent(Bool.self, forKey: .appearanceShowChannelBottomPanel) ?? true
        self.appearanceShowCustomWallpaperInChannels = try configContainer.decodeIfPresent(Bool.self, forKey: .appearanceShowCustomWallpaperInChannels) ?? true
        self.appearanceSquareStyle = try configContainer.decodeIfPresent(Bool.self, forKey: .appearanceSquareStyle) ?? false
        self.appearanceShowSeparators = try configContainer.decodeIfPresent(Bool.self, forKey: .appearanceShowSeparators) ?? true
        self.appearanceVkIcons = try configContainer.decodeIfPresent(Bool.self, forKey: .appearanceVkIcons) ?? false
        self.callConfirmation = try configContainer.decodeIfPresent(Bool.self, forKey: .callConfirmation) ?? false
        self.chatFullscreenInput = try configContainer.decodeIfPresent(Bool.self, forKey: .chatFullscreenInput) ?? false
        self.chatsFoldersAtBottom = try configContainer.decodeIfPresent(Bool.self, forKey: .chatsFoldersAtBottom) ?? false
        self.chatsFormattingPanelEnabled = try configContainer.decodeIfPresent(Bool.self, forKey: .chatsFormattingPanelEnabled) ?? false
        self.chatsListViewType = try configContainer.decodeIfPresent(Int32.self, forKey: .chatsListViewType) ?? 0
        self.chatsMessageDoubleTapActionType = try configContainer.decodeIfPresent(Int32.self, forKey: .chatsMessageDoubleTapActionType) ?? 1
        self.hideAllChatsFolder = try configContainer.decodeIfPresent(Bool.self, forKey: .hideAllChatsFolder) ?? false
        self.hidePhone = try configContainer.decodeIfPresent(Bool.self, forKey: .hidePhone) ?? false
        self.infiniteScrolling = try configContainer.decodeIfPresent(Bool.self, forKey: .infiniteScrolling) ?? false
        self.iosActiveTabs = try configContainer.decodeIfPresent([Int].self, forKey: .iosActiveTabs) ?? DTabBarSettings.default.activeTabs.map(\.rawValue)
        self.iosShowTabTitles = try configContainer.decodeIfPresent(Bool.self, forKey: .iosShowTabTitles) ?? true
        self.messageMenuReply = try configContainer.decodeIfPresent(Bool.self, forKey: .messageMenuReply) ?? true
        self.messageMenuReport = try configContainer.decodeIfPresent(Bool.self, forKey: .messageMenuReport) ?? true
        self.messageMenuSaveSound = try configContainer.decodeIfPresent(Bool.self, forKey: .messageMenuSaveSound) ?? true
        self.messageMenuForwardWithoutName = try configContainer.decodeIfPresent(Bool.self, forKey: .messageMenuForwardWithoutName) ?? false
        self.messageMenuSaved = try configContainer.decodeIfPresent(Bool.self, forKey: .messageMenuSaved) ?? false
        self.messageMenuReplyPrivately = try configContainer.decodeIfPresent(Bool.self, forKey: .messageMenuReplyPrivately) ?? false
        self.premiumShowAnimatedAvatar = try configContainer.decodeIfPresent(Bool.self, forKey: .premiumShowAnimatedAvatar) ?? true
        self.premiumShowAnimatedReactions = try configContainer.decodeIfPresent(Bool.self, forKey: .premiumShowAnimatedReactions) ?? true
        self.premiumShowAnimatedSticker = try configContainer.decodeIfPresent(Bool.self, forKey: .premiumShowAnimatedSticker) ?? true
        self.premiumShowStatusIcon = try configContainer.decodeIfPresent(Bool.self, forKey: .premiumShowStatusIcon) ?? true
        self.sendAudioConfirmation = try configContainer.decodeIfPresent(Bool.self, forKey: .sendAudioConfirmation) ?? true
        self.settingsScreenShowBusiness = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowBusiness) ?? true
        self.settingsScreenShowChatFolders = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowChatFolders) ?? true
        self.settingsScreenShowDevices = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowDevices) ?? true
        self.settingsScreenShowFAQ = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowFAQ) ?? true
        self.settingsScreenShowMyProfile = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowMyProfile) ?? true
        self.settingsScreenShowRecentCalls = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowRecentCalls) ?? true
        self.settingsScreenShowSavedMsgs = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowSavedMsgs) ?? true
        self.settingsScreenShowSendGift = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowSendGift) ?? true
        self.settingsScreenShowSupport = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowSupport) ?? true
        self.settingsScreenShowMyStars = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowMyStars) ?? true
        self.settingsScreenShowPremium = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowPremium) ?? true
        self.settingsScreenShowTips = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowTips) ?? true
        self.settingsScreenShowWallet = try configContainer.decodeIfPresent(Bool.self, forKey: .settingsScreenShowWallet) ?? true
        self.showChatFolders = try configContainer.decodeIfPresent(Bool.self, forKey: .showChatFolders) ?? true
        self.showRecentChats = try configContainer.decodeIfPresent(Bool.self, forKey: .showRecentChats) ?? true
        self.storiesHidePublishButton = try configContainer.decodeIfPresent(Bool.self, forKey: .storiesHidePublishButton) ?? false
        self.storiesHideStories = try configContainer.decodeIfPresent(Bool.self, forKey: .storiesHideStories) ?? false
        self.storiesHideViewedStories = try configContainer.decodeIfPresent(Bool.self, forKey: .storiesHideViewedStories) ?? false
        self.storiesPostingGestureEnabled = try configContainer.decodeIfPresent(Bool.self, forKey: .storiesPostingGestureEnabled) ?? false
        self.videoMessageCamera = try configContainer.decodeIfPresent(Int32.self, forKey: .videoMessageCamera) ?? 0
        self.wallExcludedChannels = try configContainer.decodeIfPresent([Int64].self, forKey: .wallExcludedChannels) ?? []
        self.wallMarkAsRead = try configContainer.decodeIfPresent(Bool.self, forKey: .wallMarkAsRead) ?? false
        self.wallShowArchivedChannels = try configContainer.decodeIfPresent(Bool.self, forKey: .wallShowArchivedChannels) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.appearanceAlternativeAvatarFont, forKey: .appearanceAlternativeAvatarFont)
        try container.encode(self.appearanceShowChannelBottomPanel, forKey: .appearanceShowChannelBottomPanel)
        try container.encode(self.appearanceShowCustomWallpaperInChannels, forKey: .appearanceShowCustomWallpaperInChannels)
        try container.encode(self.appearanceSquareStyle, forKey: .appearanceSquareStyle)
        try container.encode(self.appearanceShowSeparators, forKey: .appearanceShowSeparators)
        try container.encode(self.appearanceVkIcons, forKey: .appearanceVkIcons)
        try container.encode(self.callConfirmation, forKey: .callConfirmation)
        try container.encode(self.chatFullscreenInput, forKey: .chatFullscreenInput)
        try container.encode(self.chatsFoldersAtBottom, forKey: .chatsFoldersAtBottom)
        try container.encode(self.chatsFormattingPanelEnabled, forKey: .chatsFormattingPanelEnabled)
        try container.encode(self.chatsListViewType, forKey: .chatsListViewType)
        try container.encode(self.chatsMessageDoubleTapActionType, forKey: .chatsMessageDoubleTapActionType)
        try container.encode(self.hideAllChatsFolder, forKey: .hideAllChatsFolder)
        try container.encode(self.hidePhone, forKey: .hidePhone)
        try container.encode(self.infiniteScrolling, forKey: .infiniteScrolling)
        try container.encode(self.iosActiveTabs, forKey: .iosActiveTabs)
        try container.encode(self.iosShowTabTitles, forKey: .iosShowTabTitles)
        try container.encode(self.messageMenuReply, forKey: .messageMenuReply)
        try container.encode(self.messageMenuReport, forKey: .messageMenuReport)
        try container.encode(self.messageMenuSaveSound, forKey: .messageMenuSaveSound)
        try container.encode(self.messageMenuForwardWithoutName, forKey: .messageMenuForwardWithoutName)
        try container.encode(self.messageMenuSaved, forKey: .messageMenuSaved)
        try container.encode(self.messageMenuReplyPrivately, forKey: .messageMenuReplyPrivately)
        try container.encode(self.premiumShowAnimatedAvatar, forKey: .premiumShowAnimatedAvatar)
        try container.encode(self.premiumShowAnimatedReactions, forKey: .premiumShowAnimatedReactions)
        try container.encode(self.premiumShowAnimatedSticker, forKey: .premiumShowAnimatedSticker)
        try container.encode(self.premiumShowStatusIcon, forKey: .premiumShowStatusIcon)
        try container.encode(self.sendAudioConfirmation, forKey: .sendAudioConfirmation)
        try container.encode(self.settingsScreenShowBusiness, forKey: .settingsScreenShowBusiness)
        try container.encode(self.settingsScreenShowChatFolders, forKey: .settingsScreenShowChatFolders)
        try container.encode(self.settingsScreenShowDevices, forKey: .settingsScreenShowDevices)
        try container.encode(self.settingsScreenShowFAQ, forKey: .settingsScreenShowFAQ)
        try container.encode(self.settingsScreenShowMyProfile, forKey: .settingsScreenShowMyProfile)
        try container.encode(self.settingsScreenShowRecentCalls, forKey: .settingsScreenShowRecentCalls)
        try container.encode(self.settingsScreenShowSavedMsgs, forKey: .settingsScreenShowSavedMsgs)
        try container.encode(self.settingsScreenShowSendGift, forKey: .settingsScreenShowSendGift)
        try container.encode(self.settingsScreenShowSupport, forKey: .settingsScreenShowSupport)
        try container.encode(self.settingsScreenShowMyStars, forKey: .settingsScreenShowMyStars)
        try container.encode(self.settingsScreenShowPremium, forKey: .settingsScreenShowPremium)
        try container.encode(self.settingsScreenShowTips, forKey: .settingsScreenShowTips)
        try container.encode(self.settingsScreenShowWallet, forKey: .settingsScreenShowWallet)
        try container.encode(self.showChatFolders, forKey: .showChatFolders)
        try container.encode(self.showRecentChats, forKey: .showRecentChats)
        try container.encode(self.storiesHidePublishButton, forKey: .storiesHidePublishButton)
        try container.encode(self.storiesHideStories, forKey: .storiesHideStories)
        try container.encode(self.storiesHideViewedStories, forKey: .storiesHideViewedStories)
        try container.encode(self.storiesPostingGestureEnabled, forKey: .storiesPostingGestureEnabled)
        try container.encode(self.videoMessageCamera, forKey: .videoMessageCamera)
        try container.encode(self.wallExcludedChannels, forKey: .wallExcludedChannels)
        try container.encode(self.wallMarkAsRead, forKey: .wallMarkAsRead)
        try container.encode(self.wallShowArchivedChannels, forKey: .wallShowArchivedChannels)
    }
    
    enum CodingKeys: String, CodingKey {
        case appearanceAlternativeAvatarFont = "appearance_alternative_avatar_font"
        case appearanceShowChannelBottomPanel = "appearance_show_channel_bottom_panel"
        case appearanceShowCustomWallpaperInChannels = "appearance_show_custom_wallpaper_in_channels"
        case appearanceSquareStyle = "appearance_square_style"
        case appearanceShowSeparators = "appearance_show_separators"
        case appearanceVkIcons = "appearance_vk_icons"
        case callConfirmation = "call_confirmation"
        case chatFullscreenInput = "chat_fullscreen_input"
        case chatsFoldersAtBottom = "chats_folders_at_bottom"
        case chatsFormattingPanelEnabled = "chats_formatting_panel_enabled"
        case chatsListViewType = "chats_list_view_type"
        case chatsMessageDoubleTapActionType = "chats_message_double_tap_action_type"
        case hideAllChatsFolder = "hide_all_chats_folder"
        case hidePhone = "hide_phone"
        case infiniteScrolling = "infinite_scrolling"
        case iosActiveTabs = "ios_active_tabs"
        case iosShowTabTitles = "ios_show_tab_titles"
        case messageMenuReply = "message_menu_reply"
        case messageMenuReport = "message_menu_report"
        case messageMenuSaveSound = "message_menu_save_sound"
        case messageMenuForwardWithoutName = "message_menu_forward_without_name"
        case messageMenuSaved = "message_menu_saved"
        case messageMenuReplyPrivately = "message_menu_reply_privately"
        case premiumShowAnimatedAvatar = "premium_show_animated_avatar"
        case premiumShowAnimatedReactions = "premium_show_animated_reactions"
        case premiumShowAnimatedSticker = "premium_show_animated_sticker"
        case premiumShowStatusIcon = "premium_show_status_icon"
        case sendAudioConfirmation = "send_audio_confirmation"
        case settingsScreenShowBusiness = "ios_set_business"
        case settingsScreenShowChatFolders = "ios_set_chat_folders"
        case settingsScreenShowDevices = "ios_set_devices"
        case settingsScreenShowFAQ = "ios_set_faq"
        case settingsScreenShowMyProfile = "ios_set_profile"
        case settingsScreenShowMyStars = "ios_set_my_stars"
        case settingsScreenShowPremium = "ios_set_premium"
        case settingsScreenShowRecentCalls = "ios_set_calls"
        case settingsScreenShowSavedMsgs = "ios_set_saved_msgs"
        case settingsScreenShowSendGift = "ios_set_send_gift"
        case settingsScreenShowSupport = "ios_set_support"
        case settingsScreenShowTips = "ios_set_tips"
        case settingsScreenShowWallet = "ios_set_wallet"
        case showChatFolders = "show_chat_folders"
        case showRecentChats = "show_recent_chats"
        case storiesHidePublishButton = "stories_hide_publish_button"
        case storiesHideStories = "stories_hide_stories"
        case storiesHideViewedStories = "stories_hide_viewed_stories"
        case storiesPostingGestureEnabled = "ios_stories_posting_gesture_enabled"
        case videoMessageCamera = "video_message_camera_type"
        case wallExcludedChannels = "wall_excluded_channels"
        case wallMarkAsRead = "wall_mark_as_read"
        case wallShowArchivedChannels = "wall_show_archived_channels"
    }
}
