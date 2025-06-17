import Foundation
import SwiftSignalKit
import Postbox
import TelegramCore
import AccountContext
import TelegramUIPreferences

final class OnlineLockManager {
    private var accounts: [(Account, Bool)]?
    
    private var accountsDisposable: Disposable?
    private var settingsDisposable: Disposable?
    private var currentBlockState: Bool = false
    
    init(context: Signal<AccountContext, NoError>, sharedContext: Signal<SharedApplicationContext, NoError>) {
        self.accountsDisposable = (sharedContext
        |> mapToSignal { sharedAccountContext -> Signal<[(Account, Bool)], NoError> in
            return sharedAccountContext.sharedContext.activeAccountContexts
            |> map { _, accounts, _ in
                return accounts.map { _, accountContext, someInt in
                    let account = accountContext.account
                    return (account, false)
                }
            }
        }
        |> deliverOnMainQueue).start(next: { [weak self] accounts in
            guard let strongSelf = self else {
                return
            }
            let wasEmpty = strongSelf.accounts == nil
            strongSelf.accounts = accounts
            
            if !wasEmpty {
                strongSelf.applyBlockState(strongSelf.currentBlockState)
            }
        })
        
        self.settingsDisposable = (
            (
                context
                |> mapToSignal { context -> Signal<Bool, NoError> in
                    context.account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
                    |> map { view -> DalSettings in
                        return view.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self) ?? .defaultSettings
                    } |> map { _ -> Bool in
                        return DalSettings.defaultSettings.offlineMode
                    }
                }
                |> distinctUntilChanged
                |> deliverOnMainQueue
            ).start(next: { [weak self] shouldBlock in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.currentBlockState = shouldBlock
                strongSelf.applyBlockState(shouldBlock)
            })
        )
    }
    
    deinit {
        self.accountsDisposable?.dispose()
        self.settingsDisposable?.dispose()
    }
    
    private func applyBlockState(_ block: Bool) {
        guard let accounts = self.accounts else {
            return
        }
        
        for (account, _) in accounts {
            account.blockOnlinePresence.set(.single(block))
        }
    }
}
