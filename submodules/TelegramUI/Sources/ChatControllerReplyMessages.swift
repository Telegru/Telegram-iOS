import Foundation
import TelegramPresentationData
import AccountContext
import Postbox
import TelegramCore
import SwiftSignalKit
import Display
import TelegramPresentationData
import PresentationDataUtils
import TextFormat
import UndoUI
import ChatInterfaceState
import PremiumUI
import ReactionSelectionNode
import TopMessageReactions
import ChatMessagePaymentAlertController

extension ChatControllerImpl {
    
    func replyPrivately(message: Message) {
        guard let authorId = message.author?.id else {
            return
        }
        
        guard authorId.namespace == Namespaces.Peer.CloudUser else {
            return
        }
        
        let quoteText = message.text
        let nsRange = NSRange(location: 0, length: quoteText.count)
        
        let entities = message.textEntitiesAttribute?.entities ?? []
        let trimmedText = trimStringWithEntities(
            string: quoteText,
            entities: messageTextEntitiesInRange(entities: entities, range: nsRange, onlyQuoteable: true),
            maxLength: quoteMaxLength(appConfig: context.currentAppConfiguration.with({ $0 }))
        )
        
        var quoteData: EngineMessageReplyQuote?
        if !trimmedText.string.isEmpty {
            quoteData = EngineMessageReplyQuote(
                text: trimmedText.string,
                offset: 0,
                entities: trimmedText.entities,
                media: nil
            )
        }
        
        let _ = (context.engine.data.get(TelegramEngine.EngineData.Item.Peer.Peer(id: authorId))
                 |> deliverOnMainQueue).startStandalone(next: { [weak self] peer in
            guard let strongSelf = self, let peer = peer else {
                return
            }
            
            let navigationController = strongSelf.effectiveNavigationController
            
            let params = NavigateToChatControllerParams(
                navigationController: navigationController!,
                context: strongSelf.context,
                chatLocation: .peer(peer),
                subject: nil,
                botStart: nil,
                attachBotStart: nil,
                botAppStart: nil,
                updateTextInputState: nil,
                activateInput: nil,
                keepStack: .always,
                useExisting: true,
                useBackAnimation: false,
                purposefulAction: nil,
                scrollToEndIfExists: false,
                activateMessageSearch: nil,
                peekData: nil,
                peerNearbyData: nil,
                reportReason: nil,
                animated: true,
                forceAnimatedScroll: false,
                options: [],
                parentGroupId: nil,
                chatListFilter: nil,
                chatNavigationStack: [],
                changeColors: false,
                setupController: { _ in },
                pushController: nil,
                completion: { [replyWithQuote = quoteData] chatController in
                    if let chatControllerImpl = chatController as? ChatControllerImpl {
                        chatControllerImpl.updateChatPresentationInterfaceState(animated: false, interactive: true, { state in
                            return state.updatedInterfaceState({ interfaceState in
                                return interfaceState.withUpdatedReplyMessageSubject(
                                    ChatInterfaceState.ReplyMessageSubject(
                                        messageId: message.id,
                                        quote: replyWithQuote
                                    )
                                )
                            })
                        }, completion: { _ in
                            chatControllerImpl.chatDisplayNode.ensureInputViewFocused()
                        })
                    }
                },
                chatListCompletion: { _ in }
            )
            strongSelf.context.sharedContext.navigateToChatController(params)
        })
    }
    
}
