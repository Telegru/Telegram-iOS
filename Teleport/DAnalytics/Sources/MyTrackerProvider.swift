import MyTrackerSDK
import BuildConfig

public final class MyTrackerProvider: AnalyticsProvider {
    
    private let trackerId: String
    
    public init() {
        let baseAppBundleId = Bundle.main.bundleIdentifier!
        let buildConfig = BuildConfig(baseAppBundleId: baseAppBundleId)
        self.trackerId = buildConfig.dMyTrackerId
        MRMyTracker.setDebugMode(enabled: !buildConfig.isAppStoreBuild)
    }

    public func setup() {
        let config = MRMyTracker.trackerConfig()
        config.autotrackPurchase = false
        config.registerForSKAdAttribution = false
        config.locationTrackingMode = .none
        
        MRMyTracker.setupTracker(trackerId)
    }
    
    public func setUserId(_ userId: String?) {
        let params = MRMyTracker.trackerParams()
        params.customUserId = userId
    }
}
