import Foundation
import UIKit
import SwiftSignalKit
import Postbox
import TelegramCore
import AccountContext

public class DWallPeersLoadingMonitor {
    private var checkDisposable: Disposable?
    private var timerDisposable: Disposable?
    private let postbox: Postbox
    private let timeout: Double
    private let queue: Queue
    private let loadedPromise = Promise<Bool>()
    private var timer: SwiftSignalKit.Timer? = nil
    private let unreadMessageCount: Int
    
    public init(
        postbox: Postbox,
        unreadMessageCount: Int = 44,
        timeout: Double = 3.0,
        queue: Queue = Queue.mainQueue()
    ) {
        self.postbox = postbox
        self.timeout = timeout
        self.queue = queue
        self.unreadMessageCount = unreadMessageCount
    }
    
    public func start() {
        self.checkWallPeersLoading()
        timer?.invalidate()
        timer = Timer(timeout: self.timeout, repeat: true, completion: { [weak self] in
            self?.checkWallPeersLoading()
        }, queue: self.queue)
        
        timer?.start()
        
        self.timerDisposable = ActionDisposable { [weak self] in
            self?.timer?.invalidate()
        }
    }
    
    public func stop() {
        self.checkDisposable?.dispose()
        self.timerDisposable?.dispose()
        self.checkDisposable = nil
        self.timerDisposable = nil
    }
    
    public func checkWallPeersLoading() {
        self.checkDisposable?.dispose()
        self.checkDisposable = self.areWallPeersAndMessagesLoaded().start(next: { [weak self] loaded in
            #if DEBUG
            let status = loaded ? "LOADED" : "NOT LOADED"
            print("Wall: peers and messages loading status: \(status) - \(Date())")
            #endif

            if loaded {
                self?.stop()
                self?.loadedPromise.set(.single(true))
            }
        })
    }
    
    public func areWallPeersAndMessagesLoaded() -> Signal<Bool, NoError> {
        return self.postbox.transaction { transaction -> (chatListLoaded: Bool, relevantPeerIds: [PeerId]) in
            let root = transaction.allChatListHoles(groupId: .root)
            let archive = transaction.allChatListHoles(groupId: Namespaces.PeerGroup.archive)
            
            let chatListLoaded = root.isEmpty && archive.isEmpty
            
            if !chatListLoaded {
                return (false, [])
            }
            
            let rootPeerIds = transaction.getChatListPeers(
                groupId: .root,
                filterPredicate: nil,
                additionalFilter: nil
            ).map { $0.id }
            
            let archivePeerIds = transaction.getChatListPeers(
                groupId: Namespaces.PeerGroup.archive,
                filterPredicate: nil,
                additionalFilter: nil
            ).map { $0.id }
            
            let allPeerIds = rootPeerIds + archivePeerIds
            
            return (true, allPeerIds)
        }
        |> mapToSignal { result -> Signal<Bool, NoError> in
            if !result.chatListLoaded {
                return .single(false)
            }
            
            if result.relevantPeerIds.isEmpty {
                return .single(true)
            }
            
            let peerSignals = result.relevantPeerIds.map { peerId -> Signal<Bool, NoError> in
                return self.areChannelUnreadMessagesLoaded(peerId: peerId, count: self.unreadMessageCount)
            }
            
            return combineLatest(peerSignals)
            |> map { results in
                return !results.contains(false)
            }
        }
    }
    
    private func areChannelUnreadMessagesLoaded(peerId: PeerId, count: Int) -> Signal<Bool, NoError> {
        return self.postbox.transaction { transaction -> Bool in
            guard let readState = transaction.getCombinedPeerReadState(peerId) else {
                return true
            }
            
            for (namespace, state) in readState.states {
                if state.count > 0 {
                    
                    let view = transaction.getMessagesHistoryViewState(
                        input: .single(peerId: peerId, threadId: nil),
                        ignoreMessagesInTimestampRange: nil,
                        ignoreMessageIds: Set(),
                        count: count,
                        clipHoles: false,
                        anchor: .unread,
                        namespaces: .just(Set([namespace]))
                    )
                    
                    if view.holeEarlier || view.holeLater {
                        return false
                    }
                }
            }
            
            return true
        }
    }
    
    public var loadedSignal: Signal<Bool, NoError> {
        return self.loadedPromise.get()
    }
}
