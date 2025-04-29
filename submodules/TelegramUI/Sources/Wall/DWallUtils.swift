import Foundation
import Postbox

extension MessageHistoryView {
    static func areHistoryViewsEqual(_ lhs: (MessageHistoryView, ViewUpdateType, InitialMessageHistoryData?),
                              _ rhs: (MessageHistoryView, ViewUpdateType, InitialMessageHistoryData?)) -> Bool {
        if lhs.1 != rhs.1 {
            return false
        }
        
        if lhs.0.entries.count != rhs.0.entries.count {
            return false
        }
        
        for i in 0..<lhs.0.entries.count {
            let lhsEntry = lhs.0.entries[i]
            let rhsEntry = rhs.0.entries[i]
            
            if lhsEntry.index != rhsEntry.index {
                return false
            }
            
            if lhsEntry.location != rhsEntry.location {
                return false
            }
            
            if lhsEntry.monthLocation != rhsEntry.monthLocation {
                return false
            }
            
            if lhsEntry.attributes != rhsEntry.attributes {
                return false
            }
            
            let lhsMsg = lhsEntry.message
            let rhsMsg = rhsEntry.message
            
            if lhsMsg.stableId != rhsMsg.stableId  {
                return false
            }
            
            if lhsMsg.id != rhsMsg.id ||
                lhsMsg.timestamp != rhsMsg.timestamp ||
                lhsMsg.flags != rhsMsg.flags {
                return false
            }
            
            if lhsMsg.text != rhsMsg.text {
                return false
            }
            
            if lhsMsg.tags != rhsMsg.tags ||
                lhsMsg.globalTags != rhsMsg.globalTags ||
                lhsMsg.localTags != rhsMsg.localTags {
                return false
            }
            
            if lhsMsg.customTags.count != rhsMsg.customTags.count {
                return false
            }
            
            for j in 0..<lhsMsg.customTags.count {
                if lhsMsg.customTags[j] != rhsMsg.customTags[j] {
                    return false
                }
            }
            
            if lhsMsg.attributes.count != rhsMsg.attributes.count {
                return false
            }
            
            if lhsMsg.media.count != rhsMsg.media.count {
                return false
            }
            
            if let lhsThreadInfo = lhsMsg.associatedThreadInfo,
               let rhsThreadInfo = rhsMsg.associatedThreadInfo {
                if lhsThreadInfo.title != rhsThreadInfo.title ||
                    lhsThreadInfo.icon != rhsThreadInfo.icon ||
                    lhsThreadInfo.iconColor != rhsThreadInfo.iconColor ||
                    lhsThreadInfo.isClosed != rhsThreadInfo.isClosed {
                    return false
                }
            } else if (lhsMsg.associatedThreadInfo == nil) != (rhsMsg.associatedThreadInfo == nil) {
                return false
            }
        }
        
        return true
    }
}


