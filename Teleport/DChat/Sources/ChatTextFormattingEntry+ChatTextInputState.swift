import UIKit
import ChatInterfaceState
import CoreServices
import TextFormat
import AccountContext

public func chatTextFormattingEntries(forState state: ChatInterfaceState, undoManager: UndoManager?) -> [ChatTextFormattingEntry] {
    let inputState = state.effectiveInputState
    let appliedAttributes = appliedAttributes(inputState: inputState)
    let nsRange = NSRange(location: inputState.selectionRange.lowerBound, length: inputState.selectionRange.count)
    
    var entries = [ChatTextFormattingEntry]()
    entries.append(ChatTextFormattingEntry(tool: .mention, isEnabled: true, isSelected: false))
    entries.append(ChatTextFormattingEntry(tool: .undo, isEnabled: undoManager?.canUndo ?? false, isSelected: false))
    entries.append(ChatTextFormattingEntry(tool: .redo, isEnabled: undoManager?.canRedo ?? false, isSelected: false))
    entries.append(ChatTextFormattingEntry(tool: .copy, isEnabled: !inputState.selectionRange.isEmpty, isSelected: false))
    entries.append(ChatTextFormattingEntry(
        tool: .paste,
        isEnabled: UIPasteboard.general.contains(
            pasteboardTypes: [kUTTypeUTF8PlainText as String, kUTTypeRTF as String, "private.telegramtext"]
        ),
        isSelected: false
    ))
    entries.append(ChatTextFormattingEntry(tool: .cut, isEnabled: !inputState.selectionRange.isEmpty, isSelected: false))
    entries.append(ChatTextFormattingEntry(tool: .selectAll, isEnabled: !inputState.inputText.string.isEmpty, isSelected: false))
    entries.append(ChatTextFormattingEntry(tool: .link, isEnabled: !inputState.selectionRange.isEmpty, isSelected: false))
    entries.append(
        ChatTextFormattingEntry(
            tool: .bold,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.bold,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(
        ChatTextFormattingEntry(
            tool: .italic,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.italic,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(
        ChatTextFormattingEntry(
            tool: .spoiler,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.spoiler,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(
        ChatTextFormattingEntry(
            tool: .quote,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.block,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(
        ChatTextFormattingEntry(
            tool: .monospace,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.monospace,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(
        ChatTextFormattingEntry(
            tool: .strikethrough,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.strikethrough,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(
        ChatTextFormattingEntry(
            tool: .underline,
            isEnabled: !inputState.selectionRange.isEmpty,
            isSelected: isSelectedTextAttribute(
                for: ChatTextInputAttributes.underline,
                appliedAttributes: appliedAttributes,
                selectedRange: nsRange
            )
        )
    )
    entries.append(ChatTextFormattingEntry(tool: .regular, isEnabled: !inputState.selectionRange.isEmpty, isSelected: false))
    return entries
}

func isSelectedTextAttribute(
    for attribute: NSAttributedString.Key,
    appliedAttributes: [(NSRange, NSAttributedString.Key)],
    selectedRange: NSRange
) -> Bool {
    let matching = appliedAttributes
        .filter { $0.1 == attribute }
        .sorted { $0.0.location < $1.0.location }
    
    guard !matching.isEmpty else {
        return false
    }
    
    var currentLocation = selectedRange.location
    
    for item in matching {
        if item.0.location != currentLocation {
            return false
        }
        currentLocation += item.0.length
    }
    
    return currentLocation == selectedRange.location + selectedRange.length
}

func appliedAttributes(
    inputState: ChatTextInputState
) -> [(NSRange, NSAttributedString.Key)] {
    var appliedAttributes: [(NSRange, NSAttributedString.Key)] = []
    let nsRange = NSRange(location: inputState.selectionRange.lowerBound, length: inputState.selectionRange.count)
    if !inputState.selectionRange.isEmpty {
        inputState.inputText.enumerateAttributes(in: nsRange, options: .longestEffectiveRangeNotRequired) { attributes, range, stop in
            for (key, _) in attributes {
                appliedAttributes.append((range, key))
            }
        }
    }
    return appliedAttributes
}
