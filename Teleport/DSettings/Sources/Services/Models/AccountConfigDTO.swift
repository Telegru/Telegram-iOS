import Foundation
import TelegramUIPreferences

struct AccountConfigDTO: Codable {
    
    let sessionConfig: SessionConfigDTO
    let userConfig: UserConfigDTO
    
    enum CodingKeys: String, CodingKey {
        case sessionConfig = "session_config"
        case userConfig = "user_config"
    }
}
