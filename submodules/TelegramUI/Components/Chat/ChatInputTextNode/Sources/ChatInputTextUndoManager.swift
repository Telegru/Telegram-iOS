import Foundation
import UIKit

final class ChatInputTextUndoManager: UndoManager {
    struct UndoOperation {
        let attributedString: NSAttributedString
        let selectedRange: NSRange
        let timestamp: TimeInterval
        let type: OperationType
        
        enum OperationType {
            case initial
            case textChange
            case attributeChange
            case paste
            case delete
            case space
            case punctuation
        }
    }
    
    override var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    override var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    override var undoCount: Int {
        undoStack.count
    }
    
    override var redoCount: Int {
        redoStack.count
    }
    
    override var isUndoing: Bool {
        _isUndoing
    }
    private var _isUndoing: Bool = false
    
    override var isRedoing: Bool {
        _isRedoing
    }
    private var _isRedoing: Bool = false
    
    private var undoStack: [UndoOperation] = []
    private var redoStack: [UndoOperation] = []
    var maxStackSize: Int? {
        didSet {
            if undoStack.count > maxStackSize ?? Int.max {
                undoStack.removeAll()
            }
            
            if redoStack.count > maxStackSize ?? Int.max {
                redoStack.removeAll()
            }
        }
    }
    
    weak var textView: ChatInputTextView?
    
    private let textChangeGroupingInterval: TimeInterval = 1.5
    private let pasteGroupingInterval: TimeInterval = 0.5
    private let deleteGroupingInterval: TimeInterval = 0.5
    private let attributeChangeGroupingInterval: TimeInterval = 0.5
    
    private var lastOperationTime: TimeInterval = 0
    private var currentGroupedOperations: [UndoOperation] = []
    
    override func undo() {
        guard let textView = textView, !undoStack.isEmpty, !isUndoing, !isRedoing else { return }
        _isUndoing = true
        
        let currentOperation = UndoOperation(
            attributedString: textView.attributedText ?? NSAttributedString(),
            selectedRange: textView.selectedRange,
            timestamp: Date().timeIntervalSince1970,
            type: .textChange
        )
        redoStack.append(currentOperation)
        
        let previousOperation = undoStack.removeLast()
        textView.attributedText = previousOperation.attributedString
        textView.selectedRange = previousOperation.selectedRange
        textView.customDelegate?.chatInputTextNodeDidUpdateText()
        textView.updateTextContainerInset()
        _isUndoing = false
    }
    
    override func undoNestedGroup() {
        undo()
    }
    
    override func redo() {
        guard let textView = textView, !redoStack.isEmpty, !isUndoing, !isRedoing else { return }
        _isRedoing = true
        
        let currentOperation = UndoOperation(
            attributedString: textView.attributedText ?? NSAttributedString(),
            selectedRange: textView.selectedRange,
            timestamp: Date().timeIntervalSince1970,
            type: .textChange
        )
        undoStack.append(currentOperation)
        
        let nextOperation = redoStack.removeLast()
        textView.attributedText = nextOperation.attributedString
        textView.selectedRange = nextOperation.selectedRange
        textView.customDelegate?.chatInputTextNodeDidUpdateText()
        textView.updateTextContainerInset()
        _isRedoing = false
    }
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        currentGroupedOperations.removeAll()
        lastOperationTime = 0
    }
    
    func registerUndoOperation(type: UndoOperation.OperationType = .textChange, text: String? = nil) {
        guard let textView = textView, !isUndoing, !isRedoing else { return }
        
        if let text = text, (text == " " || isPunctuation(text)) {
            if !currentGroupedOperations.isEmpty {
                commitGroupedOperations()
            }
            let currentTime = Date().timeIntervalSince1970
            lastOperationTime = currentTime
            return
        }
        
        let currentTime = Date().timeIntervalSince1970
        let currentOperation = UndoOperation(
            attributedString: textView.attributedText ?? NSAttributedString(),
            selectedRange: textView.selectedRange,
            timestamp: currentTime,
            type: type
        )
        
        if shouldGroupWithPreviousOperation(currentOperation) {
            currentGroupedOperations.append(currentOperation)
            
            if currentTime - lastOperationTime > getGroupingInterval(for: type) {
                commitGroupedOperations()
            }
        } else {
            if !currentGroupedOperations.isEmpty {
                commitGroupedOperations()
            }
            
            currentGroupedOperations = [currentOperation]
        }
        
        lastOperationTime = currentTime
    }
    
    override func removeAllActions() {
        super.removeAllActions()
        clear()
    }
    
    // MARK: - Private methods
    
    private func getGroupingInterval(for type: UndoOperation.OperationType) -> TimeInterval {
        switch type {
        case .initial:
            return 0
        case .textChange:
            return textChangeGroupingInterval
        case .paste:
            return pasteGroupingInterval
        case .delete:
            return deleteGroupingInterval
        case .attributeChange:
            return attributeChangeGroupingInterval
        case .space:
            return 0
        case .punctuation:
            return 0
        }
    }
    
    private func shouldGroupWithPreviousOperation(_ operation: UndoOperation) -> Bool {
        if let lastOperation = currentGroupedOperations.last,
           lastOperation.type != operation.type {
            return false
        }
        
        let groupingInterval = getGroupingInterval(for: operation.type)
        if operation.timestamp - lastOperationTime > groupingInterval {
            return false
        }
        
        if operation.type == .attributeChange {
            return false
        }
        
        if let lastOperation = currentGroupedOperations.last,
           (lastOperation.type == .space || lastOperation.type == .punctuation) {
            return false
        }
        
        return true
    }
    
    private func isPunctuation(_ text: String) -> Bool {
        let punctuation = CharacterSet(charactersIn: ".,!?;:")
        return text.unicodeScalars.allSatisfy { punctuation.contains($0) }
    }
    
    private func commitGroupedOperations() {
        guard !currentGroupedOperations.isEmpty else { return }
        
        let finalOperation = currentGroupedOperations.last!
        
        undoStack.append(finalOperation)
        
        redoStack.removeAll()
        
        if let maxSize = maxStackSize, undoStack.count > maxSize {
            undoStack.removeFirst()
        }
        
        currentGroupedOperations.removeAll()
    }
} 
