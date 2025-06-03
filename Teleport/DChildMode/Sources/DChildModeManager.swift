import Foundation
import SwiftSignalKit
import TelegramCore
import DNetwork
import Postbox
import DSessionEvents

public protocol DChildModeManager {
    var isChildModeActive: Signal<Bool, NoError> { get }
    
    func isPeerAllowedSync(_ peerId: EnginePeer.Id) -> Bool
    func isPeerAllowed(_ peerId: EnginePeer.Id) -> Signal<Bool, NoError>
    func isLinkAllowed(_ url: String) -> Signal<Bool, NoError>
    
    func requestPermission(for peerId: EnginePeer.Id, title: String?, description: String?) -> Signal<Void, Error>
    func requestPermission(for url: String) -> Signal<Bool, NoError>
    
    func whitelist() -> Signal<(Bool, [EnginePeer.Id]), NoError>
}

public final class ChildModeManager: DChildModeManager {
    
    private let childModeService: ChildModeService
    private let engine: TelegramEngine?
    private let postbox: Postbox
    private let refreshWhitelistDisposable = MetaDisposable()
    private var lastWhitelist: Atomic<(Bool, [EnginePeer.Id])?> = Atomic(value: nil)
    private let sessionEventMonitorDisposable = MetaDisposable()

    public init(childModeService: ChildModeService, engine: TelegramEngine?, postbox: Postbox) {
        self.childModeService = childModeService
        self.engine = engine
        self.postbox = postbox
        
        if let engine {
            let signal = engine.peers.resolvePeerByName(name: "dahl_children_control_bot", referrer: nil)
                    
            refreshWhitelistDisposable.set((signal
                |> mapToSignal { result -> Signal<EnginePeer?, NoError> in
                    guard case let .result(peer) = result, let peer = peer else {
                        return .single(nil)
                    }
                    return engine.account.postbox.peerView(id: peer.id) |> map { _ in peer }
                }
                |> deliverOnMainQueue
                |> mapToSignal { _ -> Signal<Bool, NoError> in
                    return childModeService.refresh()
                }).start())
        }
    }
    
    deinit {
        sessionEventMonitorDisposable.dispose()
    }
    
    public var isChildModeActive: Signal<Bool, NoError> {
        let cachedSignal: Signal<Bool, NoError>
        
        if let cachedValue = childModeService.getCache()?.enabled {
            cachedSignal = .single(cachedValue)
        } else {
            cachedSignal = .complete()
        }
        
        let whitelistSignal = self.childModeService.whitelist(forceUpdate: false)
            |> map { $0.0 }
        
        return cachedSignal
            |> then(whitelistSignal)
            |> deliverOnMainQueue
    }
    
    public func isPeerAllowedSync(_ peerId: EnginePeer.Id) -> Bool {
        if let whitelist = lastWhitelist.with({ $0 }), whitelist.0 {
            return whitelist.1.contains(peerId)
        }
        return true
    }
    
    public func isPeerAllowed(_ peerId: EnginePeer.Id) -> Signal<Bool, NoError> {
        return childModeService.whitelist(forceUpdate: false)
        |> map { !$0.0 || $0.1.contains(peerId) }
    }
    
    public func isLinkAllowed(_ url: String) -> Signal<Bool, NoError> {
        return .single(false)
    }
    
    public func requestPermission(for peerId: EnginePeer.Id, title: String?, description: String?) -> Signal<Void, Error> {
        guard let engine else {
            return .complete()
        }
        return engine.peers.fetchAndUpdateCachedPeerData(peerId: peerId)
        |> castError(Error.self)
        |> mapToSignal { [weak self] _ -> Signal<(String?, DWhitelistItemType)?, Error> in
            guard let strongSelf = self else {
                return .single(nil)
            }
            return strongSelf.postbox.transaction { transaction -> (String?, DWhitelistItemType)? in
                guard let peer = transaction.getPeer(peerId).flatMap(EnginePeer.init) else {
                    return nil
                }
                
                switch peer {
                case let .user(user):
                    return (user.addressName, user.botInfo == nil ? DWhitelistItemType.user : .bot)
                case let .channel(channel):
                    return (channel.addressName, .channel)
                case let .legacyGroup(group):
                    return (group.addressName, .chat)
                case .secretChat:
                    return nil // У secret chat нет username
                }
            }
            |> castError(Error.self)
        }
        |> mapToSignal { [weak self] result -> Signal<Void, Error> in
            guard let strongSelf = self, let (username, type) = result else {
                return .complete()
            }
            let link = username.map { "@" + $0 }
            return strongSelf.childModeService.add(item: DWhitelistItem(id: peerId.id._internalGetInt64Value(), type: type, title: title, description: description, link: link))
        }
    }
    
    public func requestPermission(for url: String) -> Signal<Bool, NoError> {
        return .single(false)
    }
    
    public func whitelist() -> Signal<(Bool, [EnginePeer.Id]), NoError> {
        return childModeService.whitelist(forceUpdate: true)
        |> afterNext { [weak self] newValue in
            let _ = self?.lastWhitelist.swap(newValue)
        }
    }
    
    private func startSessionEventsObserving() {
        sessionEventMonitorDisposable.set(
            (
                SessionEventMonitor.shared.eventsSignal
                |> mapToSignal { [weak self] events -> Signal<Void, NoError> in
                    guard let self else { return .never() }
                    let shouldUpdateWhitelist = events.contains {
                        switch $0 {
                        case .whitelistUpdated:
                            return true
                        }
                    }
                    
                    if shouldUpdateWhitelist {
                        return self.childModeService.refresh() |> map { _ in () }
                    } else {
                        return .never()
                    }
                }
            )
            .start()
        )
    }
}
