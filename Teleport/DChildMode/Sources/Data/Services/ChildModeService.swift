import Foundation
import SwiftSignalKit
import TelegramCore

public protocol ChildModeService: AnyObject {
    /// Добавить объект в белый список
    func add(item: DWhitelistItem) -> Signal<Void, Error>
    /// Кэш‑стрим. Мгновенно отдаёт (enabled, peerIds) из памяти/диска.
    func whitelist(forceUpdate: Bool) -> Signal<(Bool, [EnginePeer.Id]), NoError>
    /// Принудительно обновить whitelist с сервера
    func refresh() -> Signal<Bool, NoError>
    /// Очистить кэш (при логауте)
    func clearCache()
    
    func getCache() -> ChildModeCache?
}
