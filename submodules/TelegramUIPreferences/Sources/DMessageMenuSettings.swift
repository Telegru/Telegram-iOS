import Foundation
import TelegramCore

public struct DMessageMenuSettings: Codable, Equatable {
    public var saveSound: Bool
    public var reply: Bool
    public var report: Bool
    public var forwardWithoutName: Bool
    public var saved: Bool
    public var replyPrivately: Bool
    
    public init(
        saveSound: Bool,
        reply: Bool,
        report: Bool,
        forwardWithoutName: Bool,
        saved: Bool,
        replyPrivately: Bool
    ) {
        self.saveSound = saveSound
        self.reply = reply
        self.report = report
        self.forwardWithoutName = forwardWithoutName
        self.saved = saved
        self.replyPrivately = replyPrivately
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        
        self.saveSound = try container.decodeIfPresent(Bool.self, forKey: "saveSound") ?? true
        self.reply = try container.decodeIfPresent(Bool.self, forKey: "reply") ?? true
        self.report = try container.decodeIfPresent(Bool.self, forKey: "report") ?? true
        self.forwardWithoutName = try container.decodeIfPresent(Bool.self, forKey: "forwardWithoutName") ?? false
        self.saved = try container.decodeIfPresent(Bool.self, forKey: "saved") ?? false
        self.replyPrivately = try container.decodeIfPresent(Bool.self, forKey: "replyPrivately") ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        
        try container.encode(self.saveSound, forKey: "saveSound")
        try container.encode(self.reply, forKey: "reply")
        try container.encode(self.report, forKey: "report")
        try container.encode(self.forwardWithoutName, forKey: "forwardWithoutName")
        try container.encode(self.saved, forKey: "saved")
        try container.encode(self.replyPrivately, forKey: "replyPrivately")
    }
    
    public static func ==(lhs: DMessageMenuSettings, rhs: DMessageMenuSettings) -> Bool {
        return lhs.saveSound == rhs.saveSound &&
        lhs.reply == rhs.reply &&
        lhs.report == rhs.report &&
        lhs.forwardWithoutName == rhs.forwardWithoutName &&
        lhs.saved == rhs.saved  && 
        lhs.replyPrivately == rhs.replyPrivately
    }
}

extension DMessageMenuSettings {
    
    public static var `default`: DMessageMenuSettings {
        return DMessageMenuSettings(
            saveSound: true,
            reply: true,
            report: true,
            forwardWithoutName: false,
            saved: false,
            replyPrivately: false
        )
    }
    
}
