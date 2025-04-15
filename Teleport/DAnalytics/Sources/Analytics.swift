import SwiftSignalKit

public final class Analytics {
    
    private static var providers: Atomic<[AnalyticsProvider]> = Atomic(value: [])
    
    public static func register(_ provider: AnalyticsProvider) {
        _ = providers.modify {
            var providers = $0
            providers.append(provider)
            return providers
        }
    }
    
    public static func setup() {
        let providers = self.providers.with { $0 }
        providers.forEach { $0.setup() }
    }
    
    public static func setUserId(_ userId: String?) {
        let providers = self.providers.with { $0 }
        providers.forEach { $0.setUserId(userId) }
    }
}
