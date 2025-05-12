import Foundation
import DWall
import AccountContext
import Postbox

extension ChatControllerImpl: DWallManageable {
    
    public var disableMessageMerge: Bool {
        get {
            self.chatDisplayNode.controllerInteraction.disableMessageMerge
        }
        set {
            self.chatDisplayNode.controllerInteraction.disableMessageMerge = newValue
        }
    }
    
    public func scrollToMessage(index: MessageIndex) {
        self.chatDisplayNode.historyNode.scrollToMessage(index: index)
    }
    
    public func resetScrolling(location: ChatHistoryLocation?) {
        self.chatDisplayNode.historyNode.resetScrolling(location: location)
    }
    
    public func scrollToFirstItem() {
        self.chatDisplayNode.historyNode.scrollToFirstItem()
    }
}
