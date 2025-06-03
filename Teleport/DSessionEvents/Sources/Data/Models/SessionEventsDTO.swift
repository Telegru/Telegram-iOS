import Foundation

struct SessionEventsDTO: Decodable {
    let events: [SessionEventDTO]
}

extension SessionEventsDTO {
    
    struct SessionEventDTO: Decodable {
        
        private static let dateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            return formatter
        }()
        
        let eventType: EventTypeDTO
        let id: Int64
        let payload: [String: Any]
        let createdAt: Date
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let eventTypeRawValue = try container.decodeIfPresent(String.self, forKey: .eventType) ?? ""
            self.eventType = EventTypeDTO(rawValue: eventTypeRawValue) ?? .whitelistUpdated
            self.id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? 0
            self.payload = try container.decodeIfPresent([String: Any].self, forKey: .payload) ?? [:]
            self.createdAt = Self.dateFormatter.date(from: try container.decodeIfPresent(String.self, forKey: .createdAt) ?? "") ?? Date()
        }
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
            case id
            case payload
            case createdAt = "created_at"
        }
    }
}

extension SessionEventsDTO.SessionEventDTO {
    
    enum EventTypeDTO: String {
        case whitelistUpdated = "whitelist_updated"
    }
}

extension SessionEventsDTO {
    
    func toPlain() -> [SessionEvent] {
        events.map {
            switch $0.eventType {
            case .whitelistUpdated:
                return .whitelistUpdated
            }
        }
    }
}
