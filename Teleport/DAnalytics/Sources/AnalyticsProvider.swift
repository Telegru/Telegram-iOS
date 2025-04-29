import Foundation

public protocol AnalyticsProvider: AnyObject {
    func setup()
    func setUserId(_ userId: String?)
    func trackEvent(name: String, params: [String: String]?)
}
