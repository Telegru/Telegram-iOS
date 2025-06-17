import Foundation
import SwiftSignalKit
import TelegramCore
import DNetwork

final class ChildModeServiceImpl: ChildModeService {
    
    // MARK: - Private properties
    
    private let userID: Int64
    private let client: APIClient
    private let storage: ChildModeStorage
    private let accountUserInfoSyncManager: AccountUserInfoSyncManager
    private let serviceIds: ServiceIds
    
    // In-memory cache
    private let whitelistPromise = Promise<(Bool, [EnginePeer.Id])>()
    private let firstFetchPerformed = Atomic<Bool>(value: false)
    
    // MARK: - Initialization

    init(
        userID: Int64,
        accountUserInfoSyncManager: AccountUserInfoSyncManager,
        storage: ChildModeStorage = ChildModeStorageImpl(),
        clientFactory: APIClientFactory = APIClientFactoryImpl(),
        serviceIds: ServiceIds = .default
    ) {
        var serviceIds = serviceIds
        serviceIds.users += [userID]
        self.userID = userID
        self.storage = storage
        self.client = clientFactory.sharedClient(forUserID: userID)
        self.accountUserInfoSyncManager = accountUserInfoSyncManager
        self.serviceIds = serviceIds
        
        if let cached = self.storage.getCache(forUserID: userID) {
            whitelistPromise.set(.single((cached.enabled, cached.peers)))
        } else {
            whitelistPromise.set(.single((false, [])))
        }
    }
    
    // MARK: - ChildModeService
    
    func add(item: DWhitelistItem) -> Signal<Void, any Error> {
        client.request(
            ChildModeAPI.addToWhitelist(
                type: WhitelistType(rawValue: item.type.rawValue) ?? .user,
                value: item.type == .channel || item.type == .chat  ? -abs(item.id) : item.id,
                title: item.title,
                description:
                    item.description,
                link: item.link
            )
        ).mapObject(WhitelistAddResponse.self)
        |> map { _ in () }
    }
    
    //TODO: лучше set пусть возращает
    func whitelist(forceUpdate: Bool) -> Signal<(Bool, [EnginePeer.Id]), NoError> {
        if forceUpdate {
            performInitialFetchIfNeeded()
        }
        
        return whitelistPromise.get()
        |> map { [weak self] (enabled, peers) -> (Bool, [EnginePeer.Id]) in
            guard let self else {
                return (enabled, peers)
            }
            
            // Если детский режим не активен, возвращаем как есть
            guard enabled else {
                return (enabled, peers)
            }
            
            // Добавляем сервисные ID к существующему списку
            var allPeers = peers
            
            allPeers += self.serviceIds.users.map {
                EnginePeer.Id(namespace: Namespaces.Peer.CloudUser,
                              id: ._internalFromInt64Value($0))
            }
            allPeers += self.serviceIds.bots.map {
                EnginePeer.Id(namespace: Namespaces.Peer.CloudUser,
                              id: ._internalFromInt64Value($0))
            }
            allPeers += self.serviceIds.channels.map {
                EnginePeer.Id(namespace: Namespaces.Peer.CloudChannel,
                              id: ._internalFromInt64Value(-abs($0)))
            }
            
            allPeers += self.serviceIds.chats.map {
                EnginePeer.Id(namespace: Namespaces.Peer.CloudGroup,
                              id: ._internalFromInt64Value(abs($0)))
            }
            
            // Убираем дубликаты
            return (enabled, Array(Set(allPeers)))
        }
    }
    
    func refresh() -> Signal<Bool, NoError> {
        return fetchWhitelist() |> map { enabled, _ in enabled }
    }
    
    func clearCache() {
        whitelistPromise.set(.single((false, [])))
        storage.removeCache(forUserID: self.userID)
        _ = firstFetchPerformed.swap(false)
    }
    
    func getCache() -> ChildModeCache? {
        storage.getCache(forUserID: self.userID)
    }
    
    // MARK: - Private methods
    
    private func performInitialFetchIfNeeded() {
        if firstFetchPerformed.swap(true) { return } 
        
        _ = fetchWhitelist().start()
    }
    
    /// Сетевой запрос + обновление in‑memory + запись в UserDefaults
    private func fetchWhitelist() -> Signal<(Bool, [EnginePeer.Id]), NoError> {
        let currentValue = self.whitelistPromise.get() |> take(1)
        let fetchSignal = self.client.request(ChildModeAPI.getWhitelist).mapObject(WhitelistResponse.self)
        let userInfo = self.accountUserInfoSyncManager.syncUserInfo() |> castError(Error.self)
        return combineLatest(userInfo, fetchSignal)
        |> map { [weak self] userInfo, whitelist -> (Bool, [EnginePeer.Id]) in
            guard let self else {
                return (false, [])
            }
            
            guard userInfo?.viewMode == .child else {
                self.whitelistPromise.set(.single((false, [])))
                self.storage.setCache(ChildModeCache(enabled: false, peers: []), forUserID: self.userID)
                return (false, [])
            }
            
            let enabled = true
            let peers = self.convert(whitelist)
            let tuple = (enabled, peers)
            
            self.whitelistPromise.set(.single(tuple))
            self.storage.setCache(ChildModeCache(enabled: enabled, peers: peers), forUserID: self.userID)
            return tuple
        }
        |> `catch` { _ in currentValue }
    }
    
    // MARK: - Private methods - Mapping helper
    
    private func convert(_ response: WhitelistResponse) -> [EnginePeer.Id] {
        var ids: [EnginePeer.Id] = []
        
        ids += response.config.whitelist.users.map {
            EnginePeer.Id(namespace: Namespaces.Peer.CloudUser,
                          id: ._internalFromInt64Value($0))
        }
        ids += response.config.whitelist.chats.map {
            EnginePeer.Id(namespace: Namespaces.Peer.CloudGroup,
                          id: ._internalFromInt64Value(abs($0)))
        }
        ids += response.config.whitelist.bots.map {
            EnginePeer.Id(namespace: Namespaces.Peer.CloudUser,
                          id: ._internalFromInt64Value($0))
        }
        ids += response.config.whitelist.channels.map {
            EnginePeer.Id(namespace: Namespaces.Peer.CloudChannel,
                          id: ._internalFromInt64Value(abs($0)))
        }
        
        return Array(Set(ids))
    }
}
