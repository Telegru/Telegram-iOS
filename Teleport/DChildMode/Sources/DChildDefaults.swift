import Foundation
import TelegramCore
import DNetwork

public enum DChildDefaults {
    
    public static func cachedWhitelist(for userId: Int64)
    -> (enabled: Bool, peerIds: [EnginePeer.Id])? {
        if let result = ChildModeStorageImpl().getCache(forUserID: userId) {
            return (result.enabled, result.peers)
        }
        return (false, [])
    }
    
}
