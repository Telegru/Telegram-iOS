import Foundation

enum WhitelistType: String, Codable {
    case user, chat, bot, channel
}

struct WhitelistEntry: Codable {
    let value: Int64
    let type: WhitelistType
    let title: String?
    let description: String?
}

struct WhitelistResponse: Codable {
    let service: ServiceInfo
    let config: WhitelistConfig
    
    struct ServiceInfo: Codable {
        let id: String
        let state: String
        let title: String
        let description: String
        
        var isEnabled: Bool {
            return state == "activated"
        }
    }
    
    struct WhitelistConfig: Codable {
        let whitelist: WhitelistEntries
    }
    
    struct WhitelistEntries: Codable {
        let users: [Int64]
        let chats: [Int64]
        let bots: [Int64]
        let channels: [Int64]
    }
}


struct WhitelistAddResponse: Codable {
    let success: Bool
    let added: WhitelistEntry
}
