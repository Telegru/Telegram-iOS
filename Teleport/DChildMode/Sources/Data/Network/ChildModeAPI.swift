import Foundation
import SwiftSignalKit
import DNetwork

enum ChildModeAPI: DahlBaseTargetType {
    
    case getWhitelist
    case addToWhitelist(type: WhitelistType, value: Int64, title: String?, description: String?, link: String?)
    
    var path: String {
        switch self {
        case .getWhitelist, .addToWhitelist:
            return "account/services/whitelist"
        }
    }
    
    var method: DNetwork.Method {
        switch self {
        case .getWhitelist:
            return .get
        case .addToWhitelist:
            return .post
        }
    }
    
    var task: APITask {
        switch self {
        case .getWhitelist:
            return .requestPlain
            
        case let .addToWhitelist(type, value, title, description, link):
            var body: [String: Any] = [
                "type": type.rawValue,
                "value": value
            ]
            if let title = title { body["title"] = title }
            if let description = description { body["description"] = description }
            if let link = link { body["link"] = link }
            return .requestParameters(parameters: body, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? { nil }
}
