import Foundation
import DNetwork

enum EventsAPI: DahlBaseTargetType {
    
    case getSessionEvents
    
    var baseURL: URL {
        var link = NetworkEnvironment.current.eventsBaseLink
        link += "/v1"
        if includeAPISuffix {
            link += "/api"
        }
        return URL(string: link)!
    }
    
    var path: String {
        switch self {
        case .getSessionEvents:
            return "/account/events"
        }
    }
    
    var method: DNetwork.Method {
        switch self {
        case .getSessionEvents:
            return .get
        }
    }
    
    var task: APITask {
        switch self {
        case .getSessionEvents:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getSessionEvents:
            return nil
        }
    }
}

private extension NetworkEnvironment {
    
    var eventsBaseLink: String {
        switch self {
        case .production:
            "https://events.dahlmessenger.com"
        case .test:
            "https://testapi.dahlmessenger.com"
        }
    }
}
