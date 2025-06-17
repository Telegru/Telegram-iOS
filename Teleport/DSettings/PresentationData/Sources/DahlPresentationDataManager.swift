import Foundation
import SwiftSignalKit
import Postbox
import TelegramUIPreferences
import TelegramCore

public final class DahlPresentationDataManager {
    
    public static let shared = DahlPresentationDataManager()
    
    private var userDefaults: UserDefaults
    
    private var currentAccountId: Atomic<Int64?> = Atomic(value: nil)
    
    public var squareStyle: Signal<Bool, NoError> {
        _squareStyle.get()
    }
    private var currentSquareSettings: Atomic<Bool>
    private var _squareStyle: Promise<Bool>
    
    public var vkIcons: Signal<Bool, NoError> {
        _vkIcons.get()
    }
    private var currentVKIcons: Atomic<Bool>
    private var _vkIcons: Promise<Bool>
    
    private let settingsObservingDisposable = MetaDisposable()
    
    init(userDefaults: UserDefaults = UserDefaults(suiteName: Constants.userDefaultsSuiteName) ?? .standard) {
        self.userDefaults = userDefaults
        
        let vkIcons = userDefaults.bool(forKey: "\(Constants.vkIconsKeyPrefix)\(Constants.latestValueSuffix)")
        let squareStyle = userDefaults.bool(forKey: "\(Constants.squareStyleKeyPrefix)\(Constants.latestValueSuffix)")
        
        self.currentVKIcons = Atomic(value: vkIcons)
        self.currentSquareSettings = Atomic(value: squareStyle)
        self._vkIcons = Promise(vkIcons)
        self._squareStyle = Promise(squareStyle)
    }
    
    deinit {
        settingsObservingDisposable.dispose()
    }
    
    public func didUpdateAccount(_ account: Account) {
        let userId = account.peerId.id._internalGetInt64Value()
        guard currentAccountId.with({$0}) != userId else {
            return
        }
        
        self.settingsObservingDisposable.set(nil)
        
        _ = self.currentAccountId.swap(userId)
        let newCurrentVKIcons = self.userDefaults.bool(forKey: "\(Constants.vkIconsKeyPrefix)\(userId)")
        let newCurrentSquareStyle = self.userDefaults.bool(forKey: "\(Constants.squareStyleKeyPrefix)\(userId)")
        self.userDefaults.setValue(newCurrentVKIcons, forKey: "\(Constants.vkIconsKeyPrefix)\(Constants.latestValueSuffix)")
        self.userDefaults.setValue(newCurrentSquareStyle, forKey: "\(Constants.squareStyleKeyPrefix)\(Constants.latestValueSuffix)")
        _ = self.currentVKIcons.swap(newCurrentVKIcons)
        _ = self.currentSquareSettings.swap(newCurrentSquareStyle)
        self._vkIcons.set(.single(newCurrentVKIcons))
        self._squareStyle.set(.single(newCurrentSquareStyle))
        
        let dahlSettingsSignal = account.postbox.preferencesView(keys: [ApplicationSpecificPreferencesKeys.dahlSettings])
        |> map {
            $0.values[ApplicationSpecificPreferencesKeys.dahlSettings]?.get(DalSettings.self) ?? .defaultSettings
        }
        |> distinctUntilChanged
        |> deliverOnMainQueue
        
        self.settingsObservingDisposable.set(
            dahlSettingsSignal.start(next: { [weak self] settings in
                guard let self else { return }
                self.updateVKIconsValue(settings.appearanceSettings.vkIcons)
                self.updateSquareStyleValue(settings.appearanceSettings.squareStyle)
            })
        )
    }
    
    private func updateVKIconsValue(_ value: Bool) {
        guard value != currentVKIcons.with({$0}), let currentUserId = self.currentAccountId.with({$0}) else { return }
        self.userDefaults.setValue(value, forKey: "\(Constants.vkIconsKeyPrefix)\(currentUserId)")
        self.userDefaults.setValue(value, forKey: "\(Constants.vkIconsKeyPrefix)\(Constants.latestValueSuffix)")
        _ = self.currentVKIcons.swap(value)
        self._vkIcons.set(.single(value))
    }
    
    private func updateSquareStyleValue(_ value: Bool) {
        guard value != currentSquareSettings.with({$0}), let currentUserId = self.currentAccountId.with({$0}) else { return }
        self.userDefaults.setValue(value, forKey: "\(Constants.squareStyleKeyPrefix)\(currentUserId)")
        self.userDefaults.setValue(value, forKey: "\(Constants.squareStyleKeyPrefix)\(Constants.latestValueSuffix)")
        _ = self.currentSquareSettings.swap(value)
        self._squareStyle.set(.single(value))
    }
}

extension DahlPresentationDataManager {
    fileprivate enum Constants {
        static var userDefaultsSuiteName: String {
            return "ru.dahl.DahlPresentationDataManager"
        }
        
        static var squareStyleKeyPrefix: String {
            return "square_style_"
        }
        
        static var vkIconsKeyPrefix: String {
            return "vk_icons_"
        }
        
        static var latestValueSuffix: String {
            return "latest"
        }
    }
}
