import Foundation
import AccountContext
import TelegramUIPreferences
import SwiftSignalKit
import DNetwork
import Display
import UIKit
import TPStrings

public final class AccountConfigSynchronizer {
    
    public static let shared = AccountConfigSynchronizer()
    
    private var downloadDisposable = MetaDisposable()
    private var updateSettingsDisposable = MetaDisposable()
    private var uploadSessionDisposable = MetaDisposable()
    private var sharedSettingsSynchronizationDisposable = MetaDisposable()
    
    private let apiClientFactory: APIClientFactory = APIClientFactoryImpl()
    
    private var presentNativeController: ((UIViewController) -> Void)?
    
    deinit {
        downloadDisposable.dispose()
        updateSettingsDisposable.dispose()
        uploadSessionDisposable.dispose()
    }
    
    public func startSettingsSynchronization(
        for context: AccountContext,
        presentNativeController: @escaping (UIViewController) -> Void
    ) {
        let client = apiClientFactory.sharedClient(forUserID: context.account.peerId.id._internalGetInt64Value())
        
        let isReadySignal = combineLatest(
            isUserAuthorized(for: context),
            transferSharedSettingsIfNeeded(for: context) |> map { true }
        )
        |> map { $0 && $1 }
        
        self.presentNativeController = presentNativeController
        
        downloadDisposable.set(
            (
                isReadySignal
                |> filter { $0 }
                |> take(1)
                |> mapToSignal { _ -> Signal<AccountConfigDTO, NoError> in
                    client.request(AccountConfigAPI.getConfig).mapObject(AccountConfigDTO.self)
                    |> ignoreError
                }
                |> beforeStarted { [weak self] in
                    self?.uploadSessionDisposable.set(nil)
                    self?.updateSettingsDisposable.set(nil)
                }
            )
            .start(next: { [weak self] accountConfig in
                guard let self else { return }
                self.updateSettingsIfNeeded(for: context, sessionConfig: accountConfig.sessionConfig)
            })
        )
    }
    
    // MARK: - Private methods
    
    // MARK: - Settings
    
    private func transferSharedSettingsIfNeeded(for context: AccountContext) -> Signal<Void, NoError> {
        context.account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
        |> map { view -> DalSettings? in
            return view.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self)
        }
        |> take(1)
        |> mapToSignal { settings in
            if settings != nil {
                return .single(())
            } else {
                return context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.dalSettings])
                |> map {
                    $0.entries[ApplicationSpecificSharedDataKeys.dalSettings]?.get(DalSettings.self)
                }
                |> mapToSignal { settings in
                    if let settings {
                        return updateDalSettingsInteractively(engine: context.engine) { _ in
                            settings
                        }
                    } else {
                        return .single(())
                    }
                }
            }
        }
    }
    
    private func updateSettingsIfNeeded(for context: AccountContext, sessionConfig: SessionConfigDTO) {
        updateSettingsDisposable.set(
            (
                context.account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
                |> map { view -> DalSettings in
                    return view.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self) ?? DalSettings.defaultSettings
                }
                |> take(1)
                |> map { current -> DalSettings? in
                    let isDefault = sessionConfig.isDefault
                    let newSettings = sessionConfig.config.toPlain()
                    return current != newSettings && !isDefault ? newSettings : nil
                }
                |> deliverOnMainQueue
            ).start(next: { [weak self] newSettings in
                guard let self else { return }
                if let newSettings {
                    let controller = makeRecoverSettingsAlertController(
                        for: context,
                        recoverHandler: { [weak self] in
                            _ = (
                                updateDalSettingsInteractively(
                                    engine: context.engine, { _ in
                                        return newSettings
                                    }
                                ) |> runOn(.mainQueue())
                            ).start(completed: { [weak self] in
                                self?.startLocalSettingsObserving(for: context)
                            })
                        },
                        dismissHandler: { [weak self] in
                            self?.startLocalSettingsObserving(for: context)
                        }
                    )
                    self.presentNativeController?(controller)
                } else {
                    self.startLocalSettingsObserving(for: context)
                }
            })
        )
    }
    
    private func startLocalSettingsObserving(for context: AccountContext) {
        let throttledSettingsSignal = context.account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
        |> map { view -> DalSettings in
            return view.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self) ?? .defaultSettings
        }
        |> mapToThrottled { next in
            return .single(next) |> then(.complete() |> delay(2.0, queue: .concurrentDefaultQueue()))
        }
        |> distinctUntilChanged
        |> deliverOnMainQueue
         
        uploadSessionDisposable.set(
            (
                throttledSettingsSignal
                |> mapToSignal({ [weak self] dahlSettings -> Signal<Response, NoError> in
                    guard let self else { return .complete() }
                    let dto = dahlSettings.toDTO()
                    let client = apiClientFactory.sharedClient(forUserID: context.account.peerId.id._internalGetInt64Value())
                    return client.request(AccountConfigAPI.updateSessionConfig(dto)) |> ignoreError
                })
            ).start()
        )
    }
    
    private func makeRecoverSettingsAlertController(
        for context: AccountContext,
        recoverHandler: @escaping () -> Void,
        dismissHandler: @escaping () -> Void
    ) -> UIAlertController {
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let lang = presentationData.strings.baseLanguageCode
        let theme = presentationData.theme
        let alertController = UIAlertController(
            title: "DahlSettings.Recover.Alert.Title".tp_loc(lang: lang),
            message: "DahlSettings.Recover.Alert.Subtitle".tp_loc(lang: lang),
            preferredStyle: .alert
        )
        alertController.view.tintColor = theme.actionSheet.controlAccentColor
        if #available(iOS 13.0, *) {
            alertController.overrideUserInterfaceStyle = theme.overallDarkAppearance ? .dark : .light
        }
        let recoverAction = UIAlertAction(title: "DahlSettings.Recover.Alert.Recover".tp_loc(lang: lang), style: .default) { _ in
            recoverHandler()
        }
        let cancelAction = UIAlertAction(title: "DahlSettings.Recover.Alert.Cancel".tp_loc(lang: lang), style: .destructive) { _ in
            dismissHandler()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(recoverAction)
        
        return alertController
    }
    
    // MARK: - Auth
    
    private func isUserAuthorized(for context: AccountContext) -> Signal<Bool, NoError> {
        let isUserAuthorized = Promise(false)
        let userId = context.account.peerId.id._internalGetInt64Value()
        if DAccountManager.shared.getAccessToken(for: userId) != nil {
            isUserAuthorized.set(.single(true))
        } else {
            let tokenReadySignal = Signal<Bool, NoError> { subscriber in
                let timer = SwiftSignalKit.Timer(timeout: 2.0, repeat: true, completion: { [weak context] in
                    if let context {
                        let userId = context.account.peerId.id._internalGetInt64Value()
                        subscriber.putNext(DAccountManager.shared.getAccessToken(for: userId) != nil)
                    } else {
                        subscriber.putCompletion()
                    }
                }, queue: .concurrentBackgroundQueue())
                timer.start()
                return ActionDisposable(action: {
                    timer.invalidate()
                })
            }
            isUserAuthorized.set(tokenReadySignal)
        }
        return isUserAuthorized.get()
    }
}
