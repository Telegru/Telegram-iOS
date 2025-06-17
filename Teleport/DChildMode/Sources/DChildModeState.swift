import Foundation
import TelegramCore

public struct DChildModeState {
    public let isEnabled: Bool
    public let allowedPeerIds: Set<EnginePeer.Id>
    
    public init(isEnabled: Bool, allowedPeerIds: Set<EnginePeer.Id>) {
        self.isEnabled = isEnabled
        self.allowedPeerIds = allowedPeerIds
    }
    
    public func isPeerAllowed(_ peerId: EnginePeer.Id) -> Bool {
        guard isEnabled else { return true }
        return allowedPeerIds.contains(peerId)
    }
    
    public var asTuple: (Bool, [EnginePeer.Id]) {
        (isEnabled, Array(allowedPeerIds))
    }
}
