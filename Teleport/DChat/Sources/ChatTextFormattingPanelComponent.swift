import Foundation
import UIKit
import Display
import ComponentFlow
import TelegramPresentationData
import TelegramCore
import SwiftSignalKit
import AccountContext
import AudioToolbox

public struct ChatTextFormattingPanelEnvironment: Equatable {
    public let entries: [ChatTextFormattingEntry]
    public let isKeyboardShown: Bool
    
    public init(
        entries: [ChatTextFormattingEntry],
        isKeyboardShown: Bool
    ) {
        self.entries = entries
        self.isKeyboardShown = isKeyboardShown
    }
}

private final class HoldGestureRecognizer: UITapGestureRecognizer {
    private var currentHighlightPoint: CGPoint?
    var updateHighlight: ((CGPoint?) -> Void)?
    
    override func reset() {
        super.reset()
        
        if let _ = self.currentHighlightPoint {
            self.currentHighlightPoint = nil
            self.updateHighlight?(nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        let point = touches.first?.location(in: self.view)
        if self.currentHighlightPoint == nil {
            self.currentHighlightPoint = point
            self.updateHighlight?(point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
    }
}

public final class ChatTextFormattingPanelComponent: Component {
    
    public let context: AccountContext
    public let theme: PresentationTheme
    public let strings: PresentationStrings
    public let safeInsets: UIEdgeInsets
    public let keyboardItemTapped: () -> Void
    public let toolTapped: (ChatTextFormattingTool) -> Void
    
    public init(
        context: AccountContext,
        theme: PresentationTheme,
        strings: PresentationStrings,
        safeInsets: UIEdgeInsets,
        keyboardItemTapped: @escaping () -> Void,
        toolTapped: @escaping (ChatTextFormattingTool) -> Void
    ) {
        self.context = context
        self.theme = theme
        self.strings = strings
        self.safeInsets = safeInsets
        self.keyboardItemTapped = keyboardItemTapped
        self.toolTapped = toolTapped
    }
    
    public static func ==(lhs: ChatTextFormattingPanelComponent, rhs: ChatTextFormattingPanelComponent) -> Bool {
        if lhs.theme !== rhs.theme {
            return false
        }
        if lhs.strings !== rhs.strings {
            return false
        }
        if lhs.safeInsets != rhs.safeInsets {
            return false
        }
        return true
    }
    
    private struct ItemLayout {
        let containerSize: CGSize
        let itemCount: Int
        let itemSize: CGSize
        let itemSpacing: CGFloat
        let contentSize: CGSize
        let leftInset: CGFloat
        let rightInset: CGFloat
        
        init(containerSize: CGSize, safeInsets: UIEdgeInsets, itemCount: Int) {
            self.containerSize = containerSize
            self.itemCount = itemCount
            self.itemSpacing = 11.0
            self.leftInset = 8.0 + safeInsets.left
            self.rightInset = 8.0
            self.itemSize = CGSize(width: 28.0, height: 28.0)
            
            let itemsWidth: CGFloat = self.itemSize.width * CGFloat(self.itemCount) + self.itemSpacing * CGFloat(max(0, self.itemCount - 1))
            
            self.contentSize = CGSize(width: itemsWidth + self.leftInset + self.rightInset, height: self.containerSize.height)
        }
        
        func visibleItems(for rect: CGRect) -> Range<Int>? {
            let offsetRect = rect
            var minVisibleIndex = Int(floor((offsetRect.minX - self.itemSpacing) / (self.itemSize.width + self.itemSpacing)))
            minVisibleIndex = max(0, minVisibleIndex)
            var maxVisibleIndex = Int(ceil((offsetRect.maxX - self.itemSpacing) / (self.itemSize.width + self.itemSpacing)))
            maxVisibleIndex = min(maxVisibleIndex, self.itemCount - 1)
            
            if minVisibleIndex <= maxVisibleIndex {
                return minVisibleIndex ..< (maxVisibleIndex + 1)
            } else {
                return nil
            }
        }
        
        func frame(at index: Int) -> CGRect {
            return CGRect(
                origin: CGPoint(
                    x: CGFloat(index) * (self.itemSize.width + self.itemSpacing) + self.leftInset,
                    y: floor((self.containerSize.height - self.itemSize.height) * 0.5)
                ),
                size: self.itemSize
            )
        }
    }
    
    public final class View: UIView, UIScrollViewDelegate {
        
        public typealias EnvironmentType = ChatTextFormattingPanelEnvironment
        
        private let scrollView: ContentScrollView
        
        private let separatorView: UIView
        
        private var keyboardItem: ChatTextFormattingPanelItemView
        private var visibleItemViews: [ChatTextFormattingTool: ChatTextFormattingPanelItemView] = [:]
        
        private var environment: EnvironmentType?
        private var component: ChatTextFormattingPanelComponent?
        private weak var componentState: EmptyComponentState?
        
        private var itemLayout: ItemLayout?
        private var ignoreScrolling: Bool = false
        
        private var disableInteraction: Bool = false
        
        private lazy var hapticFeedback = HapticFeedback()
        
        private final class ContentScrollView: UIScrollView {
            override func touchesShouldCancel(in view: UIView) -> Bool {
                return true
            }
        }
        
        public override init(frame: CGRect) {
            self.scrollView = ContentScrollView()
            
            self.separatorView = UIView()
            self.keyboardItem = ChatTextFormattingPanelItemView()
            
            super.init(frame: frame)
            
            self.scrollView.canCancelContentTouches = true
            self.scrollView.delaysContentTouches = false
            self.scrollView.showsVerticalScrollIndicator = false
            self.scrollView.showsHorizontalScrollIndicator = false
            self.scrollView.delegate = self
            self.scrollView.clipsToBounds = true
            self.scrollView.alwaysBounceHorizontal = true
            self.scrollView.scrollsToTop = false
            self.scrollView.contentInsetAdjustmentBehavior = .never
            
            self.addSubview(self.scrollView)
            self.addSubview(self.separatorView)
            self.addSubview(self.keyboardItem)
            
            let tapRecognizer = HoldGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
            tapRecognizer.updateHighlight = { [weak self] point in
                guard let self else { return }
                
                if let point {
                    for (_, itemView) in self.visibleItemViews {
                        let itemFrame = itemView.convert(itemView.bounds, to: self)
                        if itemFrame.contains(point) {
                            guard itemView.enabled else { break }
                            itemView.setHighlight(true, animated: true)
                            return
                        }
                    }
                    
                    let keyboardFrame = keyboardItem.convert(keyboardItem.bounds, to: self)
                    if keyboardFrame.contains(point) {
                        keyboardItem.setHighlight(true, animated: true)
                    }
                } else {
                    visibleItemViews.filter { $0.value.highlight }
                        .forEach { $0.value.setHighlight(false, animated: true) }
                    if keyboardItem.highlight {
                        keyboardItem.setHighlight(false, animated: true)
                    }
                }
            }
            
            self.addGestureRecognizer(tapRecognizer)
            
            self.disablesInteractiveKeyboardGestureRecognizer = true
            self.disablesInteractiveTransitionGestureRecognizer = true
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if !self.ignoreScrolling {
                self.updateScrolling(transition: .immediate, fromScrolling: true)
            }
        }
        
        public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if self.disableInteraction {
                for (_, itemView) in self.visibleItemViews {
                    if itemView.bounds.contains(self.convert(point, to: itemView)) {
                        return self
                    }
                }
                return nil
            }
            
            return super.hitTest(point, with: event)
        }
        
        private func updateScrolling(transition: ComponentTransition, fromScrolling: Bool) {
            guard let component = self.component, let itemLayout = self.itemLayout else {
                return
            }
            
            let visibleBounds = self.scrollView.bounds
            
            var validEntries = Set<AnyHashable>()
            let entries = environment?.entries ?? []
            
            for i in 0..<entries.count {
                let itemFrame = itemLayout.frame(at: i)
                
                if visibleBounds.intersects(itemFrame) {
                    let entry = entries[i]
                    validEntries.insert(entry.tool)
                    
                    var itemTransition = transition
                    let itemView: ChatTextFormattingPanelItemView
                    if let current = self.visibleItemViews[entry.tool] {
                        itemView = current
                    } else {
                        itemTransition = .immediate
                        itemView = ChatTextFormattingPanelItemView()
                        self.visibleItemViews[entry.tool] = itemView
                    }
                    
                    itemView.updateTheme(component.theme)
                    itemView.setImage(entry.tool.image, animated: false)
                    itemView.enabled = entry.isEnabled
                    itemView.selected = entry.isSelected
                    
                    if itemView.superview == nil {
                        self.scrollView.addSubview(itemView)
                    }
                    
                    itemTransition.setPosition(view: itemView, position: CGPoint(x: itemFrame.midX, y: itemFrame.midY))
                    itemTransition.setBounds(view: itemView, bounds: CGRect(origin: CGPoint(), size: CGSize(width: itemLayout.itemSize.width, height: itemLayout.itemSize.height)))
                    
                    let isHidden = !visibleBounds.intersects(itemFrame)
                    if isHidden != itemView.isHidden {
                        itemView.isHidden = isHidden
                    }
                }
            }
            
            var removedItemTools = [ChatTextFormattingTool]()
            for (tool, itemView) in self.visibleItemViews {
                if !validEntries.contains(tool) {
                    removedItemTools.append(tool)
                    
                    transition.attachAnimation(view: itemView, id: "remove") { [weak itemView] _ in
                        itemView?.removeFromSuperview()
                    }
                }
            }
            for tool in removedItemTools {
                self.visibleItemViews.removeValue(forKey: tool)
            }
        }
        
        func update(component: ChatTextFormattingPanelComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<ChatTextFormattingPanelEnvironment>, transition: ComponentTransition) -> CGSize {
            self.component = component
            self.componentState = state
            
            self.environment = environment[ChatTextFormattingPanelEnvironment.self].value
            
            let keyboardItemSize = CGSize(width: 28.0, height: 28.0)
            transition.setFrame(
                view: self.keyboardItem,
                frame: CGRect(
                    origin: CGPoint(x: availableSize.width - keyboardItemSize.width - component.safeInsets.right - 8.0, y: 8.0),
                    size: keyboardItemSize
                )
            )
            self.keyboardItem.updateTheme(component.theme)
            let keyboardItemImage = self.environment?.isKeyboardShown == true ? UIImage(bundleImageName: "DChat/TextFormatter/KeyboardHide") : UIImage(bundleImageName: "DChat/TextFormatter/KeyboardShow")
            
            self.keyboardItem.setImage(keyboardItemImage, animated: !transition.animation.isImmediate)
            
            transition.setFrame(
                view: self.separatorView,
                frame: CGRect(
                    origin: CGPoint(x: self.keyboardItem.frame.minX - 16.0 + UIScreenPixel, y: 8.0),
                    size: CGSize(width: UIScreenPixel, height: 28.0)
                )
            )
            self.separatorView.backgroundColor = component.theme.list.itemBlocksSeparatorColor
            
            let itemLayout = ItemLayout(containerSize: availableSize, safeInsets: component.safeInsets, itemCount: self.environment?.entries.count ?? 0)
            self.itemLayout = itemLayout
            
            let scrollViewSize = CGSize(width: self.separatorView.frame.maxX, height: availableSize.height)
            
            self.ignoreScrolling = true
            if self.scrollView.bounds.size != scrollViewSize {
                transition.setFrame(view: self.scrollView, frame: CGRect(origin: CGPoint(), size: scrollViewSize))
            }
            if self.scrollView.contentSize != itemLayout.contentSize {
                self.scrollView.contentSize = itemLayout.contentSize
            }
            self.ignoreScrolling = false
            
            self.updateScrolling(transition: transition, fromScrolling: false)
            
            return availableSize
        }
        
        @objc private func tapGesture(_ recognizer: UITapGestureRecognizer) {
            if case .ended = recognizer.state {
                guard let component = self.component else {
                    return
                }
                let location = recognizer.location(in: self)
                
                for (tool, itemView) in self.visibleItemViews {
                    let itemFrame = itemView.convert(itemView.bounds, to: self)
                    if itemFrame.contains(location) {
                        guard itemView.enabled else { break }
                        AudioServicesPlaySystemSound(0x450)
                        self.hapticFeedback.tap()
                        if tool.isSelectable {
                            itemView.setSelected(!itemView.selected, animated: true)
                        }
                        component.toolTapped(tool)
                        return
                    }
                }
                
                let keyboardFrame = keyboardItem.convert(keyboardItem.bounds, to: self)
                if keyboardFrame.contains(location) {
                    AudioServicesPlaySystemSound(0x450)
                    self.hapticFeedback.tap()
                    component.keyboardItemTapped()
                }
            }
        }
    }
    
    public func makeView() -> View {
        return View(frame: CGRect())
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<ChatTextFormattingPanelEnvironment>, transition: ComponentTransition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}
