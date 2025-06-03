import Foundation
import UIKit
import SwiftSignalKit

public final class SessionEventMonitor {
    
    // MARK: - Public static properties
    
    public static let shared = SessionEventMonitor()
    
    // MARK: - Public properties
    
    public var eventsSignal: Signal<[SessionEvent], NoError> {
        eventsPromise.get()
    }
    
    // MARK: - Private properties
    
    private var currentUserID: Int64? {
        didSet {
            if oldValue != currentUserID {
                fetchRemoteEventsDisposable.set(nil)
                eventsPromise = Promise<[SessionEvent]>()
                if let currentUserID {
                    eventsService = SessionEventServiceImpl(userID: currentUserID)
                }
            }
        }
    }
    private var appBecomeActiveObserver: NSObjectProtocol?
    private var eventsService: SessionEventService?
    private var fetchRemoteEventsDisposable = MetaDisposable()
    private var eventsPromise = Promise<[SessionEvent]>()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public methods
    
    public func startObserving(forUserID userID: Int64) {
        currentUserID = userID
        
        if appBecomeActiveObserver == nil {
            appBecomeActiveObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: nil,
                using: { [weak self] _ in
                    self?.fetchRemoteEvents()
                }
            )
        }
        
        self.fetchRemoteEvents()
    }
    
    // MARK: - Private methods
    
    private func fetchRemoteEvents() {
        guard let eventsService else {
            return
        }
        
        fetchRemoteEventsDisposable.set(
            (
                eventsService.getSessionEvents()
                |> map { $0.toPlain() }
            )
            .start(next: { [weak self] in
                guard let self else {
                    return
                }
                self.eventsPromise.set(.single($0))
            })
        )
    }
}
