import UIKit
import ComponentFlow
import TelegramPresentationData

final class ChatTextFormattingPanelItemView: UIView {
    
    // MARK: - Public properties
    
    var highlight: Bool {
        get {
            return _highlight
        }
        set {
            setHighlight(newValue, animated: false)
        }
    }
    
    var selected: Bool {
        get {
            return _selected
        }
        set {
            setSelected(newValue, animated: false)
        }
    }
    
    var enabled: Bool = true {
        didSet {
            isUserInteractionEnabled = enabled
            if enabled != oldValue {
                setSelected(false, animated: false)
            }
            updateIconColor()
        }
    }
    
    // MARK: - Private properties
    
    private var _highlight: Bool = false
    
    private var _selected: Bool = false
    
    private var theme: PresentationTheme?
    
    // MARK: - Private UI elements
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.opacity = 0.0
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(selectionView)
        addSubview(iconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionView.frame = bounds
        let iconImageSide: CGFloat = 24
        iconImageView.frame = CGRect(
            origin: CGPoint(
                x: bounds.center.x - iconImageSide / 2,
                y: bounds.center.y - iconImageSide / 2
            ),
            size: CGSize(
                width: iconImageSide,
                height: iconImageSide
            )
        )
    }
    
    // MARK: - Public methods
    
    func setImage(_ image: UIImage?, animated: Bool) {
        guard iconImageView.image?.isEqual(image) != true else {
            return
        }
        let animations: () -> Void = { [weak self] in
            self?.iconImageView.image = image
        }
        if animated {
            UIView.transition(with: self.iconImageView, duration: 0.1, options: .transitionCrossDissolve, animations: animations)
        } else {
            animations()
        }
    }
    
    func setHighlight(_ highlight: Bool, animated: Bool) {
        guard highlight != _highlight else { return }
        self._highlight = highlight
        let transition: ComponentTransition = animated ? .easeInOut(duration: 0.2) : .immediate
        transition.setScale(view: iconImageView, scale: highlight ? 0.8 : 1.0)
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        guard selected != _selected else { return }
        self._selected = selected
        let transition: ComponentTransition = animated ? .easeInOut(duration: 0.2) : .immediate
        if selected {
            if animated {
                ComponentTransition.immediate.setAlpha(view: selectionView, alpha: 0.0)
                ComponentTransition.immediate.setScale(layer: selectionView.layer, scale: 0.8)
            }
            transition.setAlpha(view: selectionView, alpha: 1.0)
            if animated {
                selectionView.layer.animateKeyframes(values: [1.0 as NSNumber, 0.75 as NSNumber, 1.0 as NSNumber], duration: 0.2, keyPath: "transform.scale")
            }
        } else {
            if animated {
                ComponentTransition.immediate.setAlpha(view: selectionView, alpha: 1.0)
                ComponentTransition.immediate.setScale(layer: selectionView.layer, scale: 1.0)
            }
            transition.setAlpha(view: selectionView, alpha: 0.0)
            if animated {
                selectionView.layer.animateSpring(from: 0.1 as NSNumber, to: 1.0 as NSNumber, keyPath: "transform.scale", duration: 0.5, damping: 92.0)
            }
        }
        self.updateIconColor()
    }
    
    func updateTheme(_ theme: PresentationTheme) {
        guard self.theme !== theme else { return }
        
        self.theme = theme
        
        let selectedColor = theme.chat.inputMediaPanel.panelHighlightedIconBackgroundColor.withAlphaComponent(0.2)
        selectionView.backgroundColor = selectedColor
        
        updateIconColor()
    }
    
    private func updateIconColor() {
        guard let theme else { return }

        let iconColor: UIColor
        if enabled {
            iconColor = selected ? theme.chat.inputMediaPanel.panelIconColor.withAlphaComponent(1.0) : theme.chat.inputMediaPanel.panelIconColor
        } else {
            iconColor = theme.chat.inputPanel.panelControlDisabledColor.withAlphaComponent(0.4)
        }
        
        iconImageView.tintColor = iconColor
    }
}
