import Foundation

public enum DWhitelistItemType: String, Codable {
    case user, chat, bot, channel
}

public struct DWhitelistItem: Identifiable, Equatable {
    public let id: Int64
    public let type: DWhitelistItemType
    public let title: String?
    public let description: String?
    public let link: String?
    
    public init(id: Int64, type: DWhitelistItemType, title: String?, description: String?, link: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.link = link
    }
}
