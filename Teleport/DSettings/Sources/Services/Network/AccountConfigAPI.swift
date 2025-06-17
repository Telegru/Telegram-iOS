import DNetwork
import Foundation

enum AccountConfigAPI: DahlBaseTargetType {
    
    case getConfig
    case updateSessionConfig(ConfigDTO)
    case resetConfig
    
    var path: String {
        switch self {
        case .getConfig, .updateSessionConfig:
            "/account/config"
        case .resetConfig:
            "/account/config/reset"
        }
    }
    
    var method: DNetwork.Method {
        switch self {
        case .getConfig:
            return .get
        case .updateSessionConfig:
            return .patch
        case .resetConfig:
            return .post
        }
    }
    
    var task: DNetwork.APITask {
        switch self {
        case .getConfig, .resetConfig:
            return .requestPlain
        case let .updateSessionConfig(dto):
            return .requestJSONEncodable(dto)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}

extension AccountConfigAPI: RequestRetryable {
    
    var retryStrategy: DNetwork.RequestRetryStrategy? {
        .afterFailure(retryCount: 3, retryDelay: 1.0)
    }
}
