import TextFormat
import TelegramCore
import AccountContext
import UIKit
import Pasteboard
import CoreServices
import ChatPresentationInterfaceState

public func chatTextInputAddMentionAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    let inputText = NSMutableAttributedString(attributedString: state.inputText)
    
    let range = NSMakeRange(state.selectionRange.startIndex, state.selectionRange.endIndex - state.selectionRange.startIndex)
    
    let replacementText = "@"
    
    inputText.replaceCharacters(in: range, with: replacementText)
    
    let selectionPosition = range.lowerBound + (replacementText as NSString).length
    
    return ChatTextInputState(inputText: inputText, selectionRange: selectionPosition ..< selectionPosition)
}

public func chatTextInputSelectAll(_ state: ChatTextInputState) -> ChatTextInputState {
    let inputText = NSMutableAttributedString(attributedString: state.inputText)
    return ChatTextInputState(inputText: inputText, selectionRange: 0 ..< inputText.length)
}

public func chatTextInputCopy(_ state: ChatTextInputState) -> ChatTextInputState {
    let inputText = NSMutableAttributedString(attributedString: state.inputText)
    
    let range: NSRange
    if state.selectionRange.isEmpty {
        range = NSMakeRange(0, inputText.length)
    } else {
        range = NSMakeRange(state.selectionRange.startIndex, state.selectionRange.endIndex - state.selectionRange.startIndex)
    }
    let copiedText = inputText.attributedSubstring(from: range)
    storeInputTextInPasteboard(copiedText)
    
    return ChatTextInputState(inputText: inputText, selectionRange: state.selectionRange)
}

public func chatTextInputCut(_ state: ChatTextInputState) -> ChatTextInputState {
    let inputText = NSMutableAttributedString(attributedString: state.inputText)
    
    let range: NSRange
    if state.selectionRange.isEmpty {
        range = NSMakeRange(0, inputText.length)
    } else {
        range = NSMakeRange(state.selectionRange.startIndex, state.selectionRange.endIndex - state.selectionRange.startIndex)
    }
    let copiedText = inputText.attributedSubstring(from: range)
    storeInputTextInPasteboard(copiedText)
    
    let replacementText = ""
    inputText.replaceCharacters(in: range, with: replacementText)
    
    let selectionPosition = range.lowerBound + (replacementText as NSString).length
    
    return ChatTextInputState(inputText: inputText, selectionRange: selectionPosition ..< selectionPosition)
}

public func chatTextInputPaste(_ state: ChatTextInputState) -> ChatTextInputState {
    let inputText = NSMutableAttributedString(attributedString: state.inputText)
    
    let range = NSMakeRange(state.selectionRange.startIndex, state.selectionRange.endIndex - state.selectionRange.startIndex)
    
    let pasteboard = UIPasteboard.general
    
    var attributedString: NSAttributedString?
    if let data = pasteboard.data(forPasteboardType: "private.telegramtext"), let value = chatInputStateStringFromAppSpecificString(data: data) {
        attributedString = value
    } else if let data = pasteboard.data(forPasteboardType: kUTTypeRTF as String) {
        attributedString = chatInputStateStringFromRTF(data, type: NSAttributedString.DocumentType.rtf)
    } else if let data = pasteboard.data(forPasteboardType: "com.apple.flat-rtfd") {
        attributedString = chatInputStateStringFromRTF(data, type: NSAttributedString.DocumentType.rtfd)
    }
    
    let selectionPosition: Int
    if let attributedString {
        inputText.replaceCharacters(in: range, with: attributedString)
        
        selectionPosition = range.lowerBound + attributedString.length
    } else {
        selectionPosition = range.lowerBound
    }
    
    return ChatTextInputState(inputText: inputText, selectionRange: selectionPosition ..< selectionPosition)
}

public func dChatTextInputAddBoldAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    var state = dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.bold)
    state = chatTextInputRemoveAttribute(state, attributes: [
        ChatTextInputAttributes.monospace
    ])
    return state
}

public func dChatTextInputAddItalicAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    return dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.italic)
}

public func dChatTextInputAddSpoilerAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    return dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.spoiler)
}

public func dChatTextInputAddQuoteAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    return dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.block)
}

public func dChatTextInputAddMonospaceAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    var state = dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.monospace)
    state = chatTextInputRemoveAttribute(state, attributes: [
        ChatTextInputAttributes.bold
    ])
    return state
}

public func dChatTextInputAddStrikethroughAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    var state = dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.strikethrough)
    state = chatTextInputRemoveAttribute(state, attributes: [
        ChatTextInputAttributes.underline
    ])
    return state
}

public func dChatTextInputAddUnderlineAttribute(_ state: ChatTextInputState) -> ChatTextInputState {
    var state = dChatTextInputAddAttribute(state, attribute: ChatTextInputAttributes.underline)
    state = chatTextInputRemoveAttribute(state, attributes: [
        ChatTextInputAttributes.strikethrough
    ])
    return state
}

private func dChatTextInputAddAttribute(
    _ state: ChatTextInputState,
    attribute: NSAttributedString.Key
) -> ChatTextInputState {
    var state = state
    let appliedAttributes = appliedAttributes(inputState: state)
    let attributeSelected = isSelectedTextAttribute(
        for: attribute,
        appliedAttributes: appliedAttributes,
        selectedRange: state.selectionRange.toNSRange()
    )
    if attributeSelected {
        state = chatTextInputRemoveAttribute(state, attributes: [
            attribute
        ])
    } else {
        state = chatTextInputAddFormattingAttribute(state, attribute: attribute, value: nil)
    }
    return state
}

private func chatTextInputRemoveAttribute(_ state: ChatTextInputState, attributes: [NSAttributedString.Key]) -> ChatTextInputState {
    let result = NSMutableAttributedString(attributedString: state.inputText)
    attributes.forEach { attribute in
        result.removeAttribute(
            attribute,
            range: state.selectionRange.toNSRange()
        )
    }
    return ChatTextInputState(
        inputText: result,
        selectionRange: state.selectionRange
    )
}

private extension Range<Int> {
    func toNSRange() -> NSRange {
        return NSRange(location: self.lowerBound, length: self.count)
    }
}
