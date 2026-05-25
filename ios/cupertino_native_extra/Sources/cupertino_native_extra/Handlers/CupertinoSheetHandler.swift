import Flutter
import UIKit

class CupertinoSheetHandler: NSObject {
    private let channel: FlutterMethodChannel
    private weak var viewController: UIViewController?
    private weak var flutterEngine: FlutterEngine?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController) {
        self.channel = FlutterMethodChannel(name: "cupertino_native_sheet", binaryMessenger: messenger)
        self.viewController = viewController
        
        // Get the FlutterEngine from the root view controller
        if let flutterVC = viewController as? FlutterViewController {
            self.flutterEngine = flutterVC.engine
        }
        
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showSheet":
            showSheet(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let viewController = self.viewController else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "View controller not available", details: nil))
                return
            }
            
            // Sheet presentation controller is only available in iOS 15.0+
            if #available(iOS 15.0, *) {
                // Create standard sheet view controller (no custom header support)
                let sheetVC = CupertinoSheetViewController()
                
                // Ensure the sheet matches the presenting controller's appearance
                if #available(iOS 13.0, *) {
                    let resolvedStyle = viewController.view.window?.traitCollection.userInterfaceStyle ?? viewController.traitCollection.userInterfaceStyle
                    if resolvedStyle != .unspecified {
                        sheetVC.overrideUserInterfaceStyle = resolvedStyle
                    }
                }

                // Check if nonmodal
                let isModal = args["isModal"] as? Bool ?? true
                
                // Configure sheet properties
                if let title = args["title"] as? String {
                    sheetVC.sheetTitle = title
                }
                if let message = args["message"] as? String {
                    sheetVC.sheetMessage = message
                }
                if let items = args["items"] as? [[String: Any]] {
                    sheetVC.items = items
                }
                sheetVC.isSheetModal = isModal
                
                // Item styling
                if let colorValue = args["itemBackgroundColor"] as? Int {
                    sheetVC.itemBackgroundColor = Self.colorFromARGB(colorValue)
                }
                if let colorValue = args["itemTextColor"] as? Int {
                    sheetVC.itemTextColor = Self.colorFromARGB(colorValue)
                }
                if let colorValue = args["itemTintColor"] as? Int {
                    sheetVC.itemTintColor = Self.colorFromARGB(colorValue)
                }
                
                // Pass the channel for callbacks
                sheetVC.channel = self.channel
                
                // Configure presentation style
                if let sheet = sheetVC.sheetPresentationController {
                    // Set delegate first for nonmodal behavior
                    if !isModal {
                        sheet.delegate = sheetVC
                        sheetVC.isModalInPresentation = false
                    }
                    
                    // Configure detents
                    var detents: [UISheetPresentationController.Detent] = []
                    var detentIdentifiers: [UISheetPresentationController.Detent.Identifier] = []
                    
                    if let detentArray = args["detents"] as? [[String: Any]] {
                        for detentInfo in detentArray {
                            if let type = detentInfo["type"] as? String {
                                switch type {
                                case "medium":
                                    detents.append(.medium())
                                    detentIdentifiers.append(.medium)
                                case "large":
                                    detents.append(.large())
                                    detentIdentifiers.append(.large)
                                case "custom":
                                    if let height = detentInfo["height"] as? Double {
                                        if #available(iOS 16.0, *) {
                                            let customIdentifier = UISheetPresentationController.Detent.Identifier("custom_\(height)")
                                            let customDetent = UISheetPresentationController.Detent.custom(identifier: customIdentifier) { context in
                                                return CGFloat(height)
                                            }
                                            detents.append(customDetent)
                                            detentIdentifiers.append(customIdentifier)
                                        } else {
                                            // Fallback to medium for iOS 15
                                            detents.append(.medium())
                                            detentIdentifiers.append(.medium)
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    } else if let detentStrings = args["detents"] as? [String] {
                        // Fallback for old string-based format
                        for detentString in detentStrings {
                            switch detentString {
                            case "medium":
                                detents.append(.medium())
                                detentIdentifiers.append(.medium)
                            case "large":
                                detents.append(.large())
                                detentIdentifiers.append(.large)
                            default:
                                break
                            }
                        }
                    }
                    
                    if detents.isEmpty {
                        detents = [.large()] // Default to large
                        detentIdentifiers = [.large]
                    }
                    sheet.detents = detents
                    
                    // CRITICAL: For nonmodal sheets, set largestUndimmedDetentIdentifier
                    // This is the UIKit equivalent of SwiftUI's presentationBackgroundInteraction
                    // It removes the dimming view for detents up to and including this identifier
                    // allowing background interaction (like in Notes app)
                    if !isModal {
                        // For nonmodal, we want to allow interaction at ALL detents
                        // So we set it to the largest detent in the array
                        if let largestDetent = detentIdentifiers.last {
                            sheet.largestUndimmedDetentIdentifier = largestDetent
                            print("✅ Nonmodal sheet: largestUndimmedDetentIdentifier set to \(largestDetent)")
                        }
                    } else {
                        print("🔒 Modal sheet: background interaction disabled")
                    }
                    
                    // Configure grabber
                    if let prefersGrabber = args["prefersGrabberVisible"] as? Bool {
                        sheet.prefersGrabberVisible = prefersGrabber
                    }
                    
                    // Configure dismiss behavior
                    if let prefersEdgeAttached = args["prefersEdgeAttachedInCompactHeight"] as? Bool {
                        sheet.prefersEdgeAttachedInCompactHeight = prefersEdgeAttached
                    }
                    
                    if let widthFollowsPreferred = args["widthFollowsPreferredContentSizeWhenEdgeAttached"] as? Bool {
                        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferred
                    }
                    
                    // Configure corner radius
                    if let cornerRadius = args["preferredCornerRadius"] as? Double {
                        sheet.preferredCornerRadius = CGFloat(cornerRadius)
                    }
                }
                
                // Set up dismiss callback
                sheetVC.onDismiss = { [weak self] selectedIndex in
                    self?.channel.invokeMethod("onDismiss", arguments: ["selectedIndex": selectedIndex ?? -1])
                }
                
                // Present the sheet
                viewController.present(sheetVC, animated: true) {
                    result(nil)
                }
            } else {
                // iOS 14 and below - sheet presentation controller not available
                result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Sheet presentation requires iOS 15.0 or later", details: nil))
            }
        }
    }
    
    // Helper to convert ARGB int to UIColor
    private static func colorFromARGB(_ argb: Int) -> UIColor {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Standard Native Sheet View Controller (no custom header)
@available(iOS 15.0, *)
class CupertinoSheetViewController: UIViewController, UISheetPresentationControllerDelegate, UIGestureRecognizerDelegate {
    var sheetTitle: String?
    var sheetMessage: String?
    var items: [[String: Any]] = []
    var onDismiss: ((Int?) -> Void)?
    var isSheetModal: Bool = true
    var flutterViewController: FlutterViewController?
    var channel: FlutterMethodChannel?
    
    // Item styling properties
    var itemBackgroundColor: UIColor?
    var itemTextColor: UIColor?
    var itemTintColor: UIColor?
    
    private var selectedIndex: Int?
    private var scrollView: UIScrollView!
    
    private func syncAppearanceWithPresentingController() {
        guard #available(iOS 13.0, *) else { return }
        let presentingStyle = presentingViewController?.traitCollection.userInterfaceStyle
        let screenStyle = UIScreen.main.traitCollection.userInterfaceStyle
        let resolvedStyle = presentingStyle.flatMap { $0 == .unspecified ? nil : $0 } ?? (screenStyle == .unspecified ? nil : screenStyle)

        if let style = resolvedStyle {
            overrideUserInterfaceStyle = style
            view.overrideUserInterfaceStyle = style
            view.window?.overrideUserInterfaceStyle = style
        } else {
            overrideUserInterfaceStyle = .unspecified
            view.overrideUserInterfaceStyle = .unspecified
            view.window?.overrideUserInterfaceStyle = .unspecified
        }
    }

    // UISheetPresentationControllerDelegate method to enable nonmodal behavior
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // For nonmodal sheets, allow dismissal at any time
        return !isSheetModal
    }
    
    // Make the dimming view passthrough for nonmodal sheets
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        // This is called when detent changes
    }
    
    // Allow simultaneous gestures for nonmodal sheets
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // For nonmodal sheets, allow gestures to pass through when not scrolling sheet content
        if !isSheetModal {
            // If the sheet's scroll view is at the top and user is scrolling up,
            // or at bottom and scrolling down, allow the gesture to pass through
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: view)
                let contentOffset = scrollView.contentOffset.y
                let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
                
                // Allow pass-through when scrolling up at the top or down at the bottom
                if (contentOffset <= 0 && velocity.y > 0) || (contentOffset >= maxOffset && velocity.y < 0) {
                    return true
                }
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use system background color that automatically adapts to light/dark mode
        view.backgroundColor = .systemBackground
        
        // If we have a FlutterViewController for custom content, use it
        if let flutterVC = flutterViewController {
            addChild(flutterVC)
            flutterVC.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(flutterVC.view)
            
            NSLayoutConstraint.activate([
                flutterVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                flutterVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                flutterVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                flutterVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            flutterVC.didMove(toParent: self)
            return
        }
        
        // Create standard sheet content (no custom header)
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self as? UIScrollViewDelegate
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
                // Add title if present
        if let title = sheetTitle {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            titleLabel.textColor = .label  // Adapts to dark mode
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            contentStack.addArrangedSubview(titleLabel)
        }
        
        // Add message if present
        if let message = sheetMessage {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = .systemFont(ofSize: 15)
            messageLabel.textColor = .secondaryLabel
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            contentStack.addArrangedSubview(messageLabel)
        }
        
        // Add items (standard sheet controller)
        for (index, item) in items.enumerated() {
            if let title = item["title"] as? String {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17)
                button.contentHorizontalAlignment = .leading
                button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                button.backgroundColor = itemBackgroundColor ?? .clear
                button.layer.cornerRadius = 10
                button.tag = index
                button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
                
                // Apply text color if specified
                if let textColor = itemTextColor {
                    button.setTitleColor(textColor, for: .normal)
                }
                
                // Apply tint color if specified
                if let tintColor = itemTintColor {
                    button.tintColor = tintColor
                }
                
                if let iconName = item["icon"] as? String, let icon = UIImage(systemName: iconName) {
                    button.setImage(icon, for: .normal)
                    // Get icon-label spacing from item data, default to 8
                    let iconLabelSpacing = item["iconLabelSpacing"] as? Double ?? 8.0
                    // Use both imageEdgeInsets and titleEdgeInsets to properly space them
                    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(iconLabelSpacing))
                    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(iconLabelSpacing), bottom: 0, right: 0)
                }
                
                contentStack.addArrangedSubview(button)
                
                NSLayoutConstraint.activate([
                    button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
                ])
            }
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        syncAppearanceWithPresentingController()
        
        // For nonmodal sheets, ensure the container view doesn't block touches
        if !isSheetModal, let presentationController = presentationController,
           let containerView = presentationController.containerView {
            // The container view should pass through touches outside the sheet
            containerView.isUserInteractionEnabled = true
        }
    }
    
    @objc private func itemTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            selectedIndex = button.tag
        } else if let gesture = sender as? UITapGestureRecognizer, let view = gesture.view {
            selectedIndex = view.tag
        }
        
        // Invoke callback immediately when item is tapped
        if let selectedIndex = selectedIndex {
            channel?.invokeMethod("onItemSelected", arguments: ["index": selectedIndex])
        }
        
        // Check if the tapped item should dismiss the sheet
        if let selectedIndex = selectedIndex, selectedIndex < items.count {
            let item = items[selectedIndex]
            let dismissOnTap = item["dismissOnTap"] as? Bool ?? true
            
            if dismissOnTap {
                // Dismiss the sheet
                dismiss(animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            onDismiss?(selectedIndex)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncAppearanceWithPresentingController()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        syncAppearanceWithPresentingController()
    }
}

