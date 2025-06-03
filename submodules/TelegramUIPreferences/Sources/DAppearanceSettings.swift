import Foundation

public struct DAppearanceSettings: Codable, Equatable {
    
    public var squareStyle: Bool
    public var vkIcons: Bool
    public var alternativeAvatarFont: Bool
    public var showCustomWallpaperInChannels: Bool
    public var showChannelBottomPanel: Bool
    public var showChatListSeparators: Bool
    
    public init(
        squareStyle: Bool,
        vkIcons: Bool,
        alternativeAvatarFont: Bool,
        showCustomWallpaperInChannels: Bool,
        showChannelBottomPanel: Bool,
        showChatListSeparators: Bool
    ) {
        self.squareStyle = squareStyle
        self.vkIcons = vkIcons
        self.alternativeAvatarFont = alternativeAvatarFont
        self.showCustomWallpaperInChannels = showCustomWallpaperInChannels
        self.showChannelBottomPanel = showChannelBottomPanel
        self.showChatListSeparators = showChatListSeparators
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.squareStyle = try container.decode(Bool.self, forKey: .squareStyle)
        self.vkIcons = try container.decode(Bool.self, forKey: .vkIcons)
        self.alternativeAvatarFont = try container.decode(Bool.self, forKey: .alternativeAvatarFont)
        self.showCustomWallpaperInChannels = try container.decodeIfPresent(Bool.self, forKey: .showCustomWallpaperInChannels) ?? true
        self.showChannelBottomPanel = try container.decodeIfPresent(Bool.self, forKey: .showChannelBottomPanel) ?? true
        self.showChatListSeparators = try container.decodeIfPresent(Bool.self, forKey: .showChatListSeparators) ?? true
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(squareStyle, forKey: .squareStyle)
        try container.encode(vkIcons, forKey: .vkIcons)
        try container.encode(alternativeAvatarFont, forKey: .alternativeAvatarFont)
        try container.encode(showCustomWallpaperInChannels, forKey: .showCustomWallpaperInChannels)
        try container.encode(showChannelBottomPanel, forKey: .showChannelBottomPanel)
        try container.encode(showChatListSeparators, forKey: .showChatListSeparators)
    }
    
    enum CodingKeys: CodingKey {
        case squareStyle
        case vkIcons
        case alternativeAvatarFont
        case showCustomWallpaperInChannels
        case showChannelBottomPanel
        case showChatListSeparators
    }
}

extension DAppearanceSettings {
    
    public static var `default`: DAppearanceSettings {
        DAppearanceSettings(
            squareStyle: false,
            vkIcons: false,
            alternativeAvatarFont: false,
            showCustomWallpaperInChannels: true,
            showChannelBottomPanel: true,
            showChatListSeparators: true
        )
    }
}
