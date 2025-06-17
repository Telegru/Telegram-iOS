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
    func whitelistSync() -> Set<EnginePeer.Id>?
    func state() -> Signal<DChildModeState, NoError>
}

public final class ChildModeManager: DChildModeManager {
    
    private let childModeService: ChildModeService
    private let engine: TelegramEngine?
    private let postbox: Postbox
    private let refreshWhitelistDisposable = MetaDisposable()
    private var lastWhitelist: Atomic<(Bool, Set<EnginePeer.Id>)?> = Atomic(value: nil)
    private let sessionEventMonitorDisposable = MetaDisposable()
    private let initialWhitelistFetchDisposable = MetaDisposable()

    private struct SecretCache {
        var forward: [EnginePeer.Id: EnginePeer.Id] = [:]
        var backward: [EnginePeer.Id: EnginePeer.Id] = [:]
    }
    private var secretChatCache = Atomic(value: SecretCache())
    private var secretChatPromise: Promise<SecretCache?> = Promise(nil)

    public init(childModeService: ChildModeService, engine: TelegramEngine?, postbox: Postbox) {
        self.childModeService = childModeService
        self.engine = engine
        self.postbox = postbox
        
        if let engine {
            let signal = engine.peers.resolvePeerByName(name: "dahl_children_control_bot", referrer: nil)
                    
            refreshWhitelistDisposable.set((signal
                |> mapToSignal { result -> Signal<Bool, NoError> in
                    guard case let .result(peer) = result,
                        let peer = peer else {
                        return .complete()
                    }
                    
                    // Подписываемся на историю сообщений этого бота
                let historySignal = engine.account.postbox.unreadMessageCountsView(items: [UnreadMessageCountsItem.peer(id: peer.id, handleThreads: false)])
                    return historySignal
                    |> mapToSignal { _ -> Signal<Bool, NoError> in
                        return self.childModeService.refresh()
                    }
                }).start())
        }
        
        initialWhitelistFetchDisposable.set(
            (childModeService.whitelist(forceUpdate: true)
             |> distinctUntilChanged(isEqual: { lhs, rhs in
                 lhs.0 == rhs.0 && lhs.1 == rhs.1
             })
            |> mapToSignal { [weak self] tuple -> Signal<((Bool, [EnginePeer.Id])), NoError> in
                guard let self else { return .single((false, [])) }
                let users = tuple.1.filter { $0.namespace == Namespaces.Peer.CloudUser }
                return self.warmSecretCache(for: users)
                |> map { _ in return tuple }
            }).start(next: { [weak self] tuple in
                let allowed = self?.fullAllowedList(Set(tuple.1)) ?? Set(tuple.1)
                let _ = self?.lastWhitelist.swap((tuple.0, allowed))
            })
        )
    }
    
    deinit {
        sessionEventMonitorDisposable.dispose()
        initialWhitelistFetchDisposable.dispose()
        refreshWhitelistDisposable.dispose()
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
    
    private func fullAllowedList(_ raw: Set<EnginePeer.Id>) -> Set<EnginePeer.Id> {
        let cache = secretChatCache.with { $0.forward }
        var result = raw
        for user in raw where user.namespace == Namespaces.Peer.CloudUser {
            if let secret = cache[user] { result.insert(secret) }
        }
        return result
    }
    
    public func isPeerAllowedSync(_ peerId: EnginePeer.Id) -> Bool {
        if let whitelist = lastWhitelist.with({ $0 }), whitelist.0 {
            return whitelist.1.contains(peerId)
        }
        return true
    }
    
    public func whitelistSync() -> Set<EnginePeer.Id>? {
        if let whitelist = lastWhitelist.with({ $0 }), whitelist.0 {
            return whitelist.1
        }
        return nil
    }
    
    public func isPeerAllowed(_ peerId: EnginePeer.Id) -> Signal<Bool, NoError> {
        if peerId.namespace == Namespaces.Peer.SecretChat {
            guard let engine else {
                return .single(false)
            }
            
            return engine.data.get(TelegramEngine.EngineData.Item.Peer.Peer(id: peerId))
            |> mapToSignal { [weak self] peerResult -> Signal<Bool, NoError> in
                guard let strongSelf = self else {
                    return .single(false)
                }
                
                if case let .secretChat(secretChat) = peerResult {
                    return strongSelf.childModeService.whitelist(forceUpdate: false)
                    |> map { !$0.0 || $0.1.contains(secretChat.regularPeerId) }
                } else {
                    return .single(false)
                }
            }
        } else {
            return childModeService.whitelist(forceUpdate: false)
            |> map { !$0.0 || $0.1.contains(peerId) }
        }
    }
    
    public func isLinkAllowed(_ url: String) -> Signal<Bool, NoError> {
        return .single(false)
    }
    
    public func requestPermission(for peerId: EnginePeer.Id, title: String?, description: String?) -> Signal<Void, Error> {
        guard let engine else {
            return .complete()
        }
        
        return engine.data.get(TelegramEngine.EngineData.Item.Peer.Peer(id: peerId))
        |> castError(Error.self)
        |> mapToSignal { [weak self] peerResult -> Signal<Void, Error> in
            guard let strongSelf = self else {
                return .complete()
            }
            
            let targetPeerId: EnginePeer.Id
            if case let .secretChat(secretChat) = peerResult {
                targetPeerId = secretChat.regularPeerId
            } else {
                targetPeerId = peerId
            }
            
            return engine.peers.fetchAndUpdateCachedPeerData(peerId: targetPeerId)
            |> castError(Error.self)
            |> mapToSignal { _ -> Signal<(String?, DWhitelistItemType, EnginePeer.Id)?, Error> in
                return strongSelf.postbox.transaction { transaction -> (String?, DWhitelistItemType, EnginePeer.Id)? in
                    guard let peer = transaction.getPeer(peerId).flatMap(EnginePeer.init) else {
                        return nil
                    }
                    
                    switch peer {
                    case let .user(user):
                        return (user.addressName, user.botInfo == nil ? DWhitelistItemType.user : .bot, peerId)
                    case let .channel(channel):
                        return (channel.addressName, .channel, peerId)
                    case let .legacyGroup(group):
                        return (group.addressName, .chat, peerId)
                    case let .secretChat(secretChat):
                        guard let regularPeer = transaction.getPeer(secretChat.regularPeerId).flatMap(EnginePeer.init),
                              case let .user(user) = regularPeer else {
                            return nil
                        }
                        return (user.addressName, .user, secretChat.regularPeerId)
                    }
                }
                |> castError(Error.self)
            }
            |> mapToSignal { result -> Signal<Void, Error> in
                guard let (username, type, finalPeerId) = result else {
                    return .complete()
                }
                let link = username.map { "@" + $0 }
                return strongSelf.childModeService.add(item: DWhitelistItem(
                    id: finalPeerId.id._internalGetInt64Value(),
                    type: type,
                    title: title,
                    description: description,
                    link: link
                ))
            }
        }
    }
    
    public func requestPermission(for url: String) -> Signal<Bool, NoError> {
        return .single(false)
    }
    
    public func whitelist() -> Signal<(Bool, [EnginePeer.Id]), NoError> {
        return combineLatest(childModeService.whitelist(forceUpdate: false), secretChatPromise.get() |> take(2))
        |> map { [weak self] whitelist, _ in
            guard let self else {
                return whitelist
            }
            let list = self.fullAllowedList(Set(whitelist.1))
            return (whitelist.0, Array(list))
        }
        |> distinctUntilChanged { lhs, rhs in
            lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
    }
    
    public func state() -> Signal<DChildModeState, NoError> {
        return childModeService.whitelist(forceUpdate: false)
        |> map {
            DChildModeState(isEnabled: $0.0, allowedPeerIds: Set($0.1))
        }
    }
    
    private func warmSecretCache(for users: [EnginePeer.Id]) -> Signal<Void, NoError> {
        guard let engine else { return .single(()) }

        let signals = users.map { engine.peers.mostRecentSecretChat(id: $0) }
        return combineLatest(signals) |> map { [weak self] ids in
            let result = self?.secretChatCache.modify {[] cache in
                var fw = cache.forward, bw = cache.backward
                zip(users, ids).forEach { user, secret in
                    if let secret { fw[user] = secret; bw[secret] = user }
                }
                let secretCache = SecretCache(forward: fw, backward: bw)
                return secretCache
            }
            self?.secretChatPromise.set(.single(result))
            return Void()
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
