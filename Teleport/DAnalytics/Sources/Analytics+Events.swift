import Foundation

public extension Analytics {
    enum WallEvent {
        public static let openWall = "openWall"
        public static let allreadWall = "allreadWall"
        public static let disableMenuWall = "disableMenuWall"
        public static let enableMenuWall = "enableMenuWall"
    }
    
    static func trackOpenWall() {
        trackEvent(name: WallEvent.openWall)
    }
    
    static func trackAllReadWall() {
        trackEvent(name: WallEvent.allreadWall)
    }
    
    static func trackDisableMenuWall() {
        trackEvent(name: WallEvent.disableMenuWall)
    }
    
    static func trackEnableMenuWall() {
        trackEvent(name: WallEvent.enableMenuWall)
    }
}
