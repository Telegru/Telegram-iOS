import Foundation
import TelegramCore

public struct ChildModeCache: Codable {
    let enabled: Bool
    let peers: [EnginePeer.Id]
}
