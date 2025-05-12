import Foundation
import TelegramCore

public struct DMessageMenuSettings: Codable, Equatable {
    public var saveSound: Bool
    public var reply: Bool
    public var report: Bool
    
    public init(
        saveSound: Bool,
        reply: Bool,
        report: Bool
    ) {
        self.saveSound = saveSound
        self.reply = reply
        self.report = report
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        
        self.saveSound = try container.decodeIfPresent(Bool.self, forKey: "saveSound") ?? true
        self.reply = try container.decodeIfPresent(Bool.self, forKey: "reply") ?? true
        self.report = try container.decodeIfPresent(Bool.self, forKey: "report") ?? true
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        
        try container.encode(self.saveSound, forKey: "saveSound")
        try container.encode(self.reply, forKey: "reply")
        try container.encode(self.report, forKey: "report")
    }
    
    public static func ==(lhs: DMessageMenuSettings, rhs: DMessageMenuSettings) -> Bool {
        return lhs.saveSound == rhs.saveSound &&
               lhs.reply == rhs.reply &&
               lhs.report == rhs.report
    }
}

extension DMessageMenuSettings {
    
    public static var `default`: DMessageMenuSettings {
        return DMessageMenuSettings(
            saveSound: true,
            reply: true,
            report: true
        )
    }
    
}
