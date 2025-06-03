import Foundation
import TelegramCore
import SwiftSignalKit
import AccountContext
import TelegramUIPreferences
import BuildConfig
import MtProtoKit
import TelegramApi
import DNetwork

enum ConnectionError {
    case firstConnectError
    case proxyConnectError
    case proxyManagerConfigurationError
}

public final class DConnectionChecker {
    
    public static let shared = DConnectionChecker()
    
    private let connectionCheckDisposable = MetaDisposable()
#if DEBUG
    private let connectionTimeout: Double = 5.0
#else
    private let connectionTimeout: Double = 15.0
#endif
    private var proxyManager: DProxyManager?
    
    private let statusPromise = Promise<ConnectionStatus>()
    public var status: Signal<ConnectionStatus, NoError> {
        return statusPromise.get()
    }
    
    public enum ConnectionStatus {
        case idle
        case checking
        case success
        case failed
    }
    
    private init() {
        statusPromise.set(.single(.idle))
    }
    
    deinit {
        connectionCheckDisposable.dispose()
    }
    
    public func configure(with proxyManager: DProxyManager) {
        self.proxyManager = proxyManager
        if proxyManager.needsInitialLoad {
            _ = proxyManager.initialize().start()
        }
    }
    
    public func checkAndEnableProxyIfNeeded(network: Network, sharedContext: SharedAccountContext) {
        statusPromise.set(.single(.checking))
        
        let firstCheck: Signal<Bool, NoError> = self.checkConnection(network: network)
        
        connectionCheckDisposable.set((firstCheck
                                       |> mapToSignal { [weak self] ok -> Signal<Bool, NoError> in
            guard let self = self else {
                self?.statusPromise.set(.single(.failed))
                return .single(false)
            }
            if ok {
                self.statusPromise.set(.single(.success))
                return .single(true)
            }
            guard let proxyManager = self.proxyManager else {
                self.statusPromise.set(.single(.failed))
                return .single(false)
            }
            return proxyManager.refreshOnError()
            |> mapToSignal { [weak self] fetched -> Signal<Bool, NoError> in
                guard let self = self, !fetched.isEmpty else {
                    self?.statusPromise.set(.single(.failed))
                    return .single(false)
                }
                let uris = fetched.map { $0.uri }
                return self.attemptProxy(at: 0, uris: uris, network: network, sharedContext: sharedContext)
            }
        })
        .start())
    }
    
    private func checkConnection(network: Network) -> Signal<Bool, NoError> {
        return network.connectionStatus
            |> mapToSignal { status -> Signal<Bool, NoError> in
                switch status {
                case .online:
                    return network.request(Api.functions.help.getConfig())
                        |> map { _ -> Bool in
                            return true
                        }
                        |> `catch` { error -> Signal<Bool, NoError> in
                            return .single(false)
                        }
                        |> take(1)
                
                case .connecting(_, let proxyHasConnectionIssues):
                    if proxyHasConnectionIssues {
                        return .single(false)
                    }
                    return .never()
                
                case .waitingForNetwork:
                    return .never()
                
                case .updating:
                    return .never()
                }
            }
            |> take(1)
            |> timeout(self.connectionTimeout, queue: Queue.concurrentDefaultQueue(), alternate: .single(false))
    }
    
    private func attemptProxy(
        at index: Int,
        uris: [String],
        network: Network,
        sharedContext: SharedAccountContext
    ) -> Signal<Bool, NoError> {
        guard index < uris.count, let proxyManager = proxyManager else {
            statusPromise.set(.single(.failed))
            return .single(false)
        }
        let uri = uris[index]
        guard
            let components = proxyManager.extractComponents(from: uri),
            let parsed = MTProxySecret.parse(components.secret)
        else {
            proxyManager.handleProxyFailure(for: uri)
            return attemptProxy(at: index + 1, uris: uris, network: network, sharedContext: sharedContext)
        }
        let settings = ProxyServerSettings(
            host: components.host,
            port: components.port,
            connection: .mtp(secret: parsed.serialize()),
            isDahlServer: true
        )
        return updateProxySettingsInteractively(accountManager: sharedContext.accountManager) { old in
            var new = old
            let baseAppBundleId = Bundle.main.bundleIdentifier!
            let buildConfig = BuildConfig(baseAppBundleId: baseAppBundleId)
            new.servers.removeAll { $0.isDahlServer || $0.host == buildConfig.dProxyServer }
            new.servers.insert(settings, at: 0)
            new.enabled = true
            new.activeServer = settings
            return new
        }
        |> mapToSignal { _ in
            network.context.updateApiEnvironment { environment in
                let current = environment?.socksProxySettings
                let updateNetwork: Bool
                let updated = settings.mtProxySettings
                if let current = current {
                    updateNetwork = !current.isEqual(updated)
                } else {
                    updateNetwork = true
                }
                if updateNetwork {
                    network.dropConnectionStatus()
                    return environment?.withUpdatedSocksProxySettings(updated)
                } else {
                    return nil
                }
            }
                        
            return network.contextProxyId
            |> take(2)
            |> last
        }
        |> mapToSignal { [weak self] _ in
            guard let self = self else {
                return .single(false)
            }
            return self.checkConnection(network: network)
            |> deliverOnMainQueue
        }
        |> mapToSignal { [weak self] success -> Signal<Bool, NoError> in
            guard let self = self, let proxyManager = self.proxyManager else {
                return .single(false)
            }
            if success {
                proxyManager.reportSuccess(for: uri)
                self.statusPromise.set(.single(.success))
                return .single(true)
            } else {
                proxyManager.handleProxyFailure(for: uri)
                return self.attemptProxy(at: index + 1, uris: uris, network: network, sharedContext: sharedContext)
            }
        }
    }

}
