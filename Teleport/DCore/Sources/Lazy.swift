import Foundation

public final class Lazy<Value>: @unchecked Sendable {
    
    // MARK: - Private properties
    
    private let initializer: () -> Value
    private var initializedValue: Value?
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    public init(_ initializer: @autoclosure @escaping () -> Value) {
        self.initializer = initializer
    }
    
    public init(_ initializer: @escaping () -> Value) {
        self.initializer = initializer
    }
    
    // MARK: - Public methods
    
    public func callAsFunction() -> Value {
        return getValue(initializer)
    }
    
    // MARK: - Private methods
    
    private func getValue(_ initializer: () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        
        if let initializedValue {
            return initializedValue
        }
        
        if let initializedValue {
            return initializedValue
        }
        
        let result = initializer()
        initializedValue = result
        
        return result
    }
}

extension Lazy: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        let initializedValue = self.initializedValue
        let value = initializedValue.flatMap(String.init(describing:)) ?? "nil"
        return "Lazy(\(value))"
    }
    
    public var debugDescription: String {
        let initializedValue = self.initializedValue
        let value = initializedValue.flatMap(String.init(describing:)) ?? "nil"
        return "Lazy(\(value): \(Value.self))"
    }
}
