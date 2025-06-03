import Foundation
import SwiftSignalKit
import TelegramCore

protocol ChildModeStorage: AnyObject {
    func getCache(forUserID userID: Int64) -> ChildModeCache?
    func setCache(_ cache: ChildModeCache, forUserID userID: Int64)
    func removeCache(forUserID userID: Int64)
}

final class ChildModeStorageImpl: ChildModeStorage {
    
    // MARK: - Private properties
    
    private let userDefaults: UserDefaults
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(
        userDefaults: UserDefaults? = .appGroup,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.userDefaults = userDefaults ?? .standard
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }
    
    // MARK: - Public methods
    
    func getCache(forUserID userID: Int64) -> ChildModeCache? {
        if let data = userDefaults.data(forKey: cacheKey(forUserID: userID)),
           let cache = try? jsonDecoder.decode(ChildModeCache.self, from: data)
        {
            return cache
        }
        return nil
    }
    
    func setCache(_ cache: ChildModeCache, forUserID userID: Int64) {
        if let data = try? jsonEncoder.encode(cache) {
            userDefaults.set(data, forKey: cacheKey(forUserID: userID))
        }
    }
    
    func removeCache(forUserID userID: Int64) {
        userDefaults.removeObject(forKey: cacheKey(forUserID: userID))
    }
    
    // MARK: - Private methods
    
    private func cacheKey(forUserID userID: Int64) -> String {
        "dahl.childmode.whlist.\(userID)"
    }
}
