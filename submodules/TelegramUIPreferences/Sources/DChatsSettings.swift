import Foundation

public struct DChatsSettings: Codable, Equatable {
    public var formattingPanelEnabled: Bool
    public var messageDoubleTapActionType: DMessageItemDoubleTapActionType
    
    public init(
        formattingPanelEnabled: Bool,
        messageDoubleTapActionType: DMessageItemDoubleTapActionType
    ) {
        self.formattingPanelEnabled = formattingPanelEnabled
        self.messageDoubleTapActionType = messageDoubleTapActionType
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formattingPanelEnabled = try container.decode(Bool.self, forKey: .formattingPanelEnabled)
        self.messageDoubleTapActionType = DMessageItemDoubleTapActionType(rawValue: try container.decode(Int32.self, forKey: .messageDoubleTapActionType))!
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.formattingPanelEnabled, forKey: .formattingPanelEnabled)
        try container.encode(self.messageDoubleTapActionType.rawValue, forKey: .messageDoubleTapActionType)
    }
    
    enum CodingKeys: String, CodingKey {
        case formattingPanelEnabled
        case messageDoubleTapActionType
    }
}

extension DChatsSettings {
    public static var `default`: DChatsSettings {
        return DChatsSettings(
            formattingPanelEnabled: false,
            messageDoubleTapActionType: .quickReaction
        )
    }
}

// MARK: - DMessageItemDoubleTap

public enum DMessageItemDoubleTapActionType: Int32, Codable, Equatable, CaseIterable {
    case disabled
    case quickReaction
    case forwardMessage
    case forwardToSavedMessage
    case editMessage
}
