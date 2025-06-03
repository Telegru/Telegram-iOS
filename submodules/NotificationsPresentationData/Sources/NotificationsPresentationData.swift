import Foundation

public struct NotificationsPresentationData: Codable, Equatable {
    public var applicationLockedMessageString: String
    public var incomingCallString: String
    public var messageHiddenString: String

    public init(applicationLockedMessageString: String, incomingCallString: String, messageHiddenString: String) {
        self.applicationLockedMessageString = applicationLockedMessageString
        self.incomingCallString = incomingCallString
        self.messageHiddenString = messageHiddenString
    }
}

public func notificationsPresentationDataPath(rootPath: String) -> String {
    return rootPath + "/notificationsPresentationData.json"
}
