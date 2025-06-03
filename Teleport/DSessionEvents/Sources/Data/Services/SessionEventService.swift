import Foundation
import SwiftSignalKit
import DNetwork

protocol SessionEventService: AnyObject {
    func getSessionEvents() -> Signal<SessionEventsDTO, any Error>
}

final class SessionEventServiceImpl: SessionEventService {
    
    private let client: APIClient
    
    init(
        userID: Int64
    ) {
        let clientFactory = APIClientFactoryImpl()
        client = clientFactory.sharedClient(forUserID: userID)
    }
    
    func getSessionEvents() -> Signal<SessionEventsDTO, any Error> {
        client.request(EventsAPI.getSessionEvents)
            .mapObject(SessionEventsDTO.self)
    }
}
