import Foundation
import DNetwork
import DCore
import Postbox
import TelegramCore

public final class DChildModeAssembly {
    
    private let userID: Int64
    private let networkAssembly: DNetworkAssembly
    private let postbox: Postbox
    private let engine: TelegramEngine?
    
    public init(
        userID: Int64,
        networkAssembly: DNetworkAssembly,
        postbox: Postbox,
        engine: TelegramEngine?
    ) {
        self.userID = userID
        self.networkAssembly = networkAssembly
        self.postbox = postbox
        self.engine = engine
    }
    
    public lazy var childModeManager: Lazy<DChildModeManager> = {
        Lazy(
            ChildModeManager(
                childModeService: self.childModeService,
                engine: self.engine,
                postbox: self.postbox
            )
        )
    }()
    
    private var childModeService: ChildModeService {
        ChildModeServiceImpl(
            userID: self.userID,
            accountService: self.networkAssembly.accountService,
            clientFactory: self.networkAssembly.clientFactory
        )
    }
}
