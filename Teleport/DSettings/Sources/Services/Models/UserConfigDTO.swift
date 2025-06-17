import Foundation

struct UserConfigDTO: Codable {
    let viewMode: ViewMode
    
    enum ViewMode: String, Codable {
        case `default`
    }
    
    enum CodingKeys: String, CodingKey {
        case viewMode = "view_mode"
    }
}
