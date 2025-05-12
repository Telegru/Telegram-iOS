import UIKit
import RMIntro
import SSignalKit
import LegacyComponents
import SafariServices
import TelegramPresentationData

private enum DeviceScreen: Int {
    case inch35 = 0, inch4, inch47, inch55, inch65, iPad, iPadPro
}

private final class DIntroView: UIView {
    var onLayout: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}

public final class DIntroViewController: UIViewController {
    
    // Public properties
    
    public var defaultFrame: CGRect = .zero
    public var isEnabled: Bool = true {
        didSet {
            alternativeLanguageButton.isEnabled = isEnabled
        }
    }
    public var startMessagingInAlternativeLanguage: ((String) -> Void)?
    public var createStartButton: ((CGFloat) -> UIView)!
    
    // Orientation
    
    public override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        return .portrait
    }
    
    // Private properties
    
    private var loadedView: Bool = false
    private var localizationsDisposable: SDisposable?
    private var deviceScreen: DeviceScreen {
        let viewSize = view.frame.size
        let max = Int(max(viewSize.width, viewSize.height))
        var deviceScreen = DeviceScreen.inch55
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch max {
            case 1366:
                deviceScreen = .iPadPro
                
            default:
                deviceScreen = .iPad
            }
        } else {
            switch max {
            case 480:
                deviceScreen = .inch35
                
            case 568:
                deviceScreen = .inch4
                
            case 667:
                deviceScreen = .inch47
                
            case 896:
                deviceScreen = .inch65
            
            default: break
            }
        }
        
        return deviceScreen
    }
    
    // UI
    private var startButton: UIView?
    private lazy var pageViewController = DIntroPageViewController()
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.tintColor = .white
        control.isUserInteractionEnabled = false
        control.numberOfPages = pageViewController.numberOfPages
        if #available(iOS 14.0, *) {
            control.allowsContinuousInteraction = false
        }
        return control
    }()
    private lazy var alternativeLanguageButton: TGModernButton = {
        let button = TGModernButton()
        button.modernHighlight = true
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 18.0)
        button.isHidden = true
        button.addTarget(self, action: #selector(alternativeLanguageButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var consentLabel: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.delegate = self
        
        setupConsentText(textView, consentText: "Intro.Consent.FormattedText".tp_loc(), privacyPolicyText: "Intro.Consent.PrivacyPolicy".tp_loc(), termsOfServiceText: "Intro.Consent.TermsOfService".tp_loc())
        
        textView.isUserInteractionEnabled = true
        return textView
    }()
    
    private let privacyPolicyURL = URL(string: "https://dahlmessenger.com/privacy")!
    private let termsOfServiceURL = URL(string: "https://dahlmessenger.com/tos")!
    
    deinit {
        localizationsDisposable?.dispose()
    }
    
    public init(suggestedLocalizationSignal: SSignal) {
        isEnabled = true
        
        super.init(nibName: nil, bundle: nil)
        
        localizationsDisposable = suggestedLocalizationSignal.deliver(on: .main())
            .startStrict(next: { [weak self] _ in
                guard let self else {
                    return
                }
                alternativeLanguageButton.setTitle("Intro.Continue".tp_loc(), for: .normal)
                alternativeLanguageButton.isHidden = false
                alternativeLanguageButton.sizeToFit()
                setupConsentText(self.consentLabel, consentText: "Intro.Consent.FormattedText".tp_loc(), privacyPolicyText: "Intro.Consent.PrivacyPolicy".tp_loc(), termsOfServiceText: "Intro.Consent.TermsOfService".tp_loc())
                
                if isViewLoaded {
                    alternativeLanguageButton.alpha = 0.0
                    UIView.animate(withDuration: 0.3) {
                        self.alternativeLanguageButton.alpha = self.isEnabled ? 1.0 : 0.6
                        self.viewWillLayoutSubviews()
                    }
                }
            }, file: #file, line: #line)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = DIntroView(frame: defaultFrame)
        
        (view as? DIntroView)?.onLayout = { [weak self] in
            self?.updateLayout()
        }
        viewDidLoad()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard !loadedView else { return }
        loadedView = true
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        addSubviews()
        
        pageViewController.pageChangingHandler = { [weak self] page in
            self?.pageControl.currentPage = page
        }
    }
    
    private func addSubviews() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(alternativeLanguageButton)
        view.addSubview(pageControl)
        view.addSubview(consentLabel)
    }
    
    private func setupConsentText(_ textView: UITextView,
                                  consentText: String,
                                  privacyPolicyText: String,
                                  termsOfServiceText: String
    ) {
        let accentTextColor: UIColor = UIColor(hexString: "#7B86C3")!
        let textColor: UIColor = .white
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.dataDetectorTypes = []
        textView.linkTextAttributes = [
            .foregroundColor: accentTextColor,
        ]

        let text = consentText
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: textColor,
            .paragraphStyle: {
                let p = NSMutableParagraphStyle()
                p.alignment = .center
                p.lineSpacing = 0
                return p
            }()
        ])
        if let range = text.range(of: privacyPolicyText) {
            let ns = NSRange(range, in: text)
            attr.addAttribute(.link, value: privacyPolicyURL, range: ns)
        }
        if let range = text.range(of: termsOfServiceText) {
            let ns = NSRange(range, in: text)
            attr.addAttribute(.link, value: termsOfServiceURL, range: ns)
        }

        textView.attributedText = attr
    }
    
    private func openURL(_ url: URL) {
        if #available(iOS 13.0, *), let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            let topViewController = getTopViewController(rootViewController)
            
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredControlTintColor = .white
            safariVC.modalPresentationStyle = .pageSheet
            topViewController.present(safariVC, animated: true)
        } else {
            UIApplication.shared.open(url)
        }
    }
    
    private func updateLayout() {
        var startButtonY: CGFloat = 0
        var languageButtonSpread: CGFloat = 60.0
        var languageButtonOffset: CGFloat = 26.0
        var consentLabelOffset: CGFloat = 20.0
        var pageControlOffset: CGFloat = 85.0
        var bottomOffset: CGFloat = 20.0

        switch deviceScreen {
        case .iPad, .iPadPro:
            startButtonY = 120
        case .inch35:
            startButtonY = 75
            if !alternativeLanguageButton.isHidden {
                startButtonY -= 30.0
            }
            languageButtonSpread = 65
            languageButtonOffset = 8
            consentLabelOffset = 0
            pageControlOffset = 65
            bottomOffset = 0
        case .inch4:
            pageControlOffset = 65
            startButtonY = 75
            languageButtonSpread = 50.0
            languageButtonOffset = 12
            consentLabelOffset = 10
            bottomOffset = 0
        case .inch47:
            pageControlOffset = 65
            startButtonY = 75 + 5
            languageButtonOffset = 15
            consentLabelOffset = 10
            bottomOffset = 0
        case .inch55:
            startButtonY = 75 + 20
        case .inch65:
            startButtonY = 75 + 30
        }
        
        if !alternativeLanguageButton.isHidden {
            startButtonY += languageButtonSpread
        }
        
        pageViewController.view.frame = view.bounds
        
        let maxConsentWidth = min(500.0, view.bounds.size.width - 48.0)
        let consentSize = consentLabel.sizeThatFits(CGSize(width: maxConsentWidth, height: CGFloat.greatestFiniteMagnitude))
            
        let startButtonWidth: CGFloat = min(430.0 - 48.0, view.bounds.size.width - 48.0)
        let startButton = createStartButton(startButtonWidth)
        if startButton.superview == nil {
            self.startButton = startButton
            view.addSubview(startButton)
        }
                
        startButtonY = max(startButtonY, (consentSize.height + consentLabelOffset + alternativeLanguageButton.frame.size.height + languageButtonOffset + 50.0 + bottomOffset))
        
        self.startButton?.frame = CGRect(
            x: (self.view.bounds.size.width - startButtonWidth) / 2.0,
            y: view.bounds.size.height - startButtonY,
            width: startButtonWidth,
            height: 50.0
        )
        
        alternativeLanguageButton.frame = CGRect(
            x: (self.view.bounds.size.width - alternativeLanguageButton.frame.size.width) / 2.0,
            y: self.startButton!.frame.maxY + languageButtonOffset,
            width: alternativeLanguageButton.frame.size.width,
            height: alternativeLanguageButton.frame.size.height
        )
        
        consentLabel.frame = CGRect(
            x: (view.bounds.size.width - maxConsentWidth) / 2.0,
            y: self.alternativeLanguageButton.frame.maxY + consentLabelOffset,
            width: maxConsentWidth,
            height: consentSize.height
        )
        
        pageControl.frame = CGRect(
            x: 0,
            y: self.startButton!.frame.origin.y - pageControlOffset,
            width: view.bounds.size.width,
            height: 33
        )
    }
    
    @objc
    private func alternativeLanguageButtonPressed() {
        let language = Locale.current.languageCode == "ru" ? "en" : "ru"
        startMessagingInAlternativeLanguage?(language)
    }
    
    private func getTopViewController(_ viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return getTopViewController(presented)
        }
        
        if let navigationController = viewController as? UINavigationController {
            if let visibleViewController = navigationController.visibleViewController {
                return getTopViewController(visibleViewController)
            }
            return navigationController
        }
        
        if let tabBarController = viewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return getTopViewController(selectedViewController)
            }
            return tabBarController
        }
        
        return viewController
    }
}

extension DIntroViewController: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openURL(URL)
        return false
    }
}
