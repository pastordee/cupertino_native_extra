import Flutter
import UIKit

class CupertinoCustomSheetHandler: NSObject {
    private let channel: FlutterMethodChannel
    private weak var viewController: UIViewController?
    private weak var flutterEngine: FlutterEngine?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController) {
        self.channel = FlutterMethodChannel(name: "cupertino_native_custom_sheet", binaryMessenger: messenger)
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
                // Create custom header sheet view controller
                let sheetVC = CupertinoCustomSheetViewController()
                sheetVC.channel = self.channel // Pass the channel for callbacks
                
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
                if let itemRowsData = args["itemRows"] as? [[String: Any]] {
                    // Keep the full row dictionaries with styling properties
                    sheetVC.itemRows = itemRowsData
                }
                if let inlineActionsData = args["inlineActions"] as? [[String: Any]] {
                    // Each element in inlineActionsData is a dictionary with "actions" key and optional styling properties
                    sheetVC.inlineActions = inlineActionsData
                }
                sheetVC.isSheetModal = isModal
                
                // Apply custom header styling
                if let size = args["headerTitleSize"] as? CGFloat {
                    sheetVC.headerTitleSize = size
                }
                if let weightString = args["headerTitleWeight"] as? String {
                    sheetVC.headerTitleWeight = Self.fontWeightFromString(weightString)
                }
                if let colorValue = args["headerTitleColor"] as? Int {
                    sheetVC.headerTitleColor = Self.colorFromARGB(colorValue)
                }
                if let alignment = args["headerTitleAlignment"] as? String {
                    sheetVC.headerTitleAlignment = alignment == "center" ? .center : .left
                }
                if let subtitleText = args["subtitle"] as? String {
                    sheetVC.subtitle = subtitleText
                }
                if let size = args["subtitleSize"] as? CGFloat {
                    sheetVC.subtitleSize = size
                }
                if let colorValue = args["subtitleColor"] as? Int {
                    sheetVC.subtitleColor = Self.colorFromARGB(colorValue)
                }
                if let height = args["headerHeight"] as? CGFloat {
                    sheetVC.headerHeight = height
                }
                if let colorValue = args["headerBackgroundColor"] as? Int {
                    sheetVC.headerBackgroundColor = Self.colorFromARGB(colorValue)
                }
                if let showDivider = args["showHeaderDivider"] as? Bool {
                    sheetVC.showHeaderDivider = showDivider
                }
                if let colorValue = args["headerDividerColor"] as? Int {
                    sheetVC.headerDividerColor = Self.colorFromARGB(colorValue)
                }
                if let position = args["closeButtonPosition"] as? String {
                    sheetVC.closeButtonPosition = position
                }
                if let icon = args["closeButtonIcon"] as? String {
                    sheetVC.closeButtonIcon = icon
                }
                if let size = args["closeButtonSize"] as? CGFloat {
                    sheetVC.closeButtonSize = size
                }
                if let colorValue = args["closeButtonColor"] as? Int {
                    sheetVC.closeButtonColor = Self.colorFromARGB(colorValue)
                }
                
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
                        
                        // Additionally, ensure the sheet presentation doesn't block interaction
                        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
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
    
    // Helper to convert font weight string to UIFont.Weight
    private static func fontWeightFromString(_ weightString: String) -> UIFont.Weight {
        switch weightString.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular
        }
    }
    
    // Helper to convert ARGB int to UIColor
    static func colorFromARGB(_ argb: Int) -> UIColor {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}


// MARK: - Custom Sheet View Controller (with custom header)
@available(iOS 15.0, *)
class CupertinoCustomSheetViewController: UIViewController, UISheetPresentationControllerDelegate, UIGestureRecognizerDelegate {
    var sheetTitle: String?
    var sheetMessage: String?
    var items: [[String: Any]] = []
    var itemRows: [[String: Any]] = [] // Array of row dictionaries, each with "items" array and optional styling
    var inlineActions: [[String: Any]] = [] // Array of action group dictionaries, each with "actions" array and styling properties
    var onDismiss: ((Int?) -> Void)?
    var isSheetModal: Bool = true
    var flutterViewController: FlutterViewController?
    var channel: FlutterMethodChannel?
    
    // Header styling properties
    var headerTitleSize: CGFloat = 20
    var headerTitleWeight: UIFont.Weight = .semibold
    var headerTitleColor: UIColor?
    var headerTitleAlignment: NSTextAlignment = .left // .left or .center
    var subtitle: String?
    var subtitleSize: CGFloat = 13
    var subtitleColor: UIColor?
    var headerHeight: CGFloat = 56
    var headerBackgroundColor: UIColor?
    var showHeaderDivider: Bool = true
    var headerDividerColor: UIColor?
    var closeButtonPosition: String = "trailing" // "leading" or "trailing"
    var closeButtonIcon: String = "xmark"
    var closeButtonSize: CGFloat = 17
    var closeButtonColor: UIColor?
    
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

    // UISheetPresentationControllerDelegate methods
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !isSheetModal
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        // This is called when detent changes
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if !isSheetModal {
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: view)
                let contentOffset = scrollView.contentOffset.y
                let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
                
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
        
        // Create custom header with title and close button
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.backgroundColor = headerBackgroundColor ?? .systemBackground
        view.addSubview(headerView)
        
        // Title and subtitle stack
        let titleStack = UIStackView()
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.alignment = headerTitleAlignment == .center ? .center : .leading
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = sheetTitle ?? "Sheet"
        titleLabel.font = .systemFont(ofSize: headerTitleSize, weight: headerTitleWeight)
        titleLabel.textColor = headerTitleColor ?? .label
        titleLabel.textAlignment = headerTitleAlignment
        titleStack.addArrangedSubview(titleLabel)
        
        // Subtitle label (if provided)
        var subtitleLabel: UILabel?
        if let subtitleText = subtitle {
            let label = UILabel()
            label.text = subtitleText
            label.font = .systemFont(ofSize: subtitleSize)
            label.textColor = subtitleColor ?? .secondaryLabel
            label.textAlignment = headerTitleAlignment
            titleStack.addArrangedSubview(label)
            subtitleLabel = label
        }
        
        headerView.addSubview(titleStack)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        if let closeImage = UIImage(systemName: closeButtonIcon) {
            let config = UIImage.SymbolConfiguration(pointSize: closeButtonSize, weight: .regular)
            closeButton.setImage(closeImage.withConfiguration(config), for: .normal)
        }
        closeButton.tintColor = closeButtonColor ?? .label
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        headerView.addSubview(closeButton)
        
        // Separator line
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = headerDividerColor ?? .separator
        separator.isHidden = !showHeaderDivider
        headerView.addSubview(separator)
        
        // Create title constraints based on alignment
        var titleConstraints: [NSLayoutConstraint] = []
        
        if headerTitleAlignment == .center {
            // Center alignment - title is centered horizontally
            titleConstraints = [
                titleStack.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                titleStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                titleStack.leadingAnchor.constraint(greaterThanOrEqualTo: headerView.leadingAnchor, constant: 56),
                titleStack.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -56)
            ]
        } else {
            // Left alignment - title is on the left side
            let leadingConstant: CGFloat = closeButtonPosition == "leading" ? 56 : 16
            titleConstraints = [
                titleStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: leadingConstant),
                titleStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                titleStack.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -8)
            ]
        }
        
        NSLayoutConstraint.activate([
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
        ] + titleConstraints + [
            // Close button constraints (position depends on closeButtonPosition)
            closeButtonPosition == "leading" ?
                closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16) :
                closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Separator constraints
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        // Create scroll view for content
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self as? UIScrollViewDelegate
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true  // Allow scrolling even when content is small
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
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
        
        // Add inline action rows (horizontal button groups)
        for (rowIndex, actionGroup) in inlineActions.enumerated() {
            // Extract row-level styling properties with proper type conversion
            let spacing: CGFloat
            if let spacingValue = actionGroup["spacing"] as? NSNumber {
                spacing = CGFloat(spacingValue.doubleValue)
            } else {
                spacing = 12
            }
            
            let horizontalPadding: CGFloat
            if let paddingValue = actionGroup["horizontalPadding"] as? NSNumber {
                horizontalPadding = CGFloat(paddingValue.doubleValue)
            } else {
                horizontalPadding = 16
            }
            
            let verticalPadding: CGFloat
            if let paddingValue = actionGroup["verticalPadding"] as? NSNumber {
                verticalPadding = CGFloat(paddingValue.doubleValue)
            } else {
                verticalPadding = 0
            }
            
            let rowHeight: CGFloat
            if let heightValue = actionGroup["height"] as? NSNumber {
                rowHeight = CGFloat(heightValue.doubleValue)
            } else {
                rowHeight = 72
            }
            
            guard let actions = actionGroup["actions"] as? [[String: Any]] else { continue }
            
            // Create scroll view for horizontal scrolling
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            
            let actionRow = UIStackView()
            actionRow.axis = .horizontal
            actionRow.distribution = .fill
            actionRow.spacing = spacing
            actionRow.translatesAutoresizingMaskIntoConstraints = false
            
            for (actionIndex, action) in actions.enumerated() {
                let actionButton = createInlineActionButton(action: action, rowIndex: rowIndex, actionIndex: actionIndex)
                actionRow.addArrangedSubview(actionButton)
                
                // Get custom width or use default
                let buttonWidth: CGFloat
                if let widthValue = action["width"] as? NSNumber {
                    buttonWidth = CGFloat(widthValue.doubleValue)
                } else {
                    buttonWidth = 70
                }
                
                NSLayoutConstraint.activate([
                    actionButton.widthAnchor.constraint(equalToConstant: buttonWidth)
                ])
            }
            
            scrollView.addSubview(actionRow)
            
            // Wrap the scroll view in a container with padding
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalPadding),
                scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalPadding),
                scrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: verticalPadding),
                scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -verticalPadding),
                scrollView.heightAnchor.constraint(equalToConstant: rowHeight),
                
                actionRow.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                actionRow.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                actionRow.topAnchor.constraint(equalTo: scrollView.topAnchor),
                actionRow.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                actionRow.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            contentStack.addArrangedSubview(container)
        }
        
        // Add items (custom header sheet controller)
        for (index, item) in items.enumerated() {
            if let title = item["title"] as? String {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                
                // Get custom styling properties
                let fontSize = (item["fontSize"] as? NSNumber)?.doubleValue ?? 17
                let itemHeight = (item["height"] as? NSNumber)?.doubleValue ?? 50
                let iconSize = (item["iconSize"] as? NSNumber)?.doubleValue ?? 22
                
                // Apply font weight if provided
                var font: UIFont
                if let fontWeightValue = item["fontWeight"] as? Int {
                    let weight: UIFont.Weight = {
                        switch fontWeightValue {
                        case 100: return .ultraLight
                        case 200: return .thin
                        case 300: return .light
                        case 400: return .regular
                        case 500: return .medium
                        case 600: return .semibold
                        case 700: return .bold
                        case 800: return .heavy
                        case 900: return .black
                        default: return .regular
                        }
                    }()
                    font = .systemFont(ofSize: fontSize, weight: weight)
                } else {
                    font = .systemFont(ofSize: fontSize)
                }
                button.titleLabel?.font = font
                
                button.contentHorizontalAlignment = .leading
                button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                
                // Check for custom background color first
                if let backgroundColorValue = item["backgroundColor"] as? Int {
                    button.backgroundColor = CupertinoCustomSheetHandler.colorFromARGB(backgroundColorValue)
                } else {
                    button.backgroundColor = itemBackgroundColor ?? .clear
                }
                
                button.layer.cornerRadius = 10
                button.tag = index
                button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
                
                // Check for custom text color first
                if let textColorValue = item["textColor"] as? Int {
                    button.setTitleColor(CupertinoCustomSheetHandler.colorFromARGB(textColorValue), for: .normal)
                } else if let textColor = itemTextColor {
                    button.setTitleColor(textColor, for: .normal)
                }
                
                // Check for custom icon color first
                if let iconColorValue = item["iconColor"] as? Int {
                    button.tintColor = CupertinoCustomSheetHandler.colorFromARGB(iconColorValue)
                } else if let tintColor = itemTintColor {
                    button.tintColor = tintColor
                }
                
                if let iconName = item["icon"] as? String, let icon = UIImage(systemName: iconName) {
                    let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
                    button.setImage(icon.withConfiguration(config), for: .normal)
                    // Get icon-label spacing from item data, default to 8
                    let iconLabelSpacing = item["iconLabelSpacing"] as? Double ?? 8.0
                    // Use both imageEdgeInsets and titleEdgeInsets to properly space them
                    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(iconLabelSpacing))
                    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(iconLabelSpacing), bottom: 0, right: 0)
                }
                
                contentStack.addArrangedSubview(button)
                
                NSLayoutConstraint.activate([
                    button.heightAnchor.constraint(equalToConstant: itemHeight)
                ])
            }
        }
        
        // Add item rows (horizontal groups of vertical-style items)
        for (rowIndex, itemRowDict) in itemRows.enumerated() {
            // Extract row-level styling properties
            let rowSpacing = (itemRowDict["spacing"] as? NSNumber)?.doubleValue ?? 8
            let rowHeight = (itemRowDict["height"] as? NSNumber)?.doubleValue ?? 50
            
            guard let rowItems = itemRowDict["items"] as? [[String: Any]] else { continue }
            
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = rowSpacing
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            
            for (itemIndex, item) in rowItems.enumerated() {
                if let title = item["title"] as? String {
                    let button = UIButton(type: .system)
                    button.setTitle(title, for: .normal)
                    
                    // Get custom styling properties
                    let fontSize = (item["fontSize"] as? NSNumber)?.doubleValue ?? 17
                    let iconSize = (item["iconSize"] as? NSNumber)?.doubleValue ?? 22
                    
                    // Apply font weight if provided
                    var font: UIFont
                    if let fontWeightValue = item["fontWeight"] as? Int {
                        let weight: UIFont.Weight = {
                            switch fontWeightValue {
                            case 100: return .ultraLight
                            case 200: return .thin
                            case 300: return .light
                            case 400: return .regular
                            case 500: return .medium
                            case 600: return .semibold
                            case 700: return .bold
                            case 800: return .heavy
                            case 900: return .black
                            default: return .regular
                            }
                        }()
                        font = .systemFont(ofSize: fontSize, weight: weight)
                    } else {
                        font = .systemFont(ofSize: fontSize)
                    }
                    button.titleLabel?.font = font
                    
                    button.contentHorizontalAlignment = .center
                    button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                    
                    // Check for custom background color first
                    if let backgroundColorValue = item["backgroundColor"] as? Int {
                        button.backgroundColor = CupertinoCustomSheetHandler.colorFromARGB(backgroundColorValue)
                    } else {
                        button.backgroundColor = itemBackgroundColor ?? .clear
                    }
                    
                    button.layer.cornerRadius = 10
                    // Encode row and item index into the tag: (rowIndex << 16) | itemIndex
                    button.tag = (rowIndex << 16) | itemIndex
                    button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
                    
                    // Check for custom text color first
                    if let textColorValue = item["textColor"] as? Int {
                        button.setTitleColor(CupertinoCustomSheetHandler.colorFromARGB(textColorValue), for: .normal)
                    } else if let textColor = itemTextColor {
                        button.setTitleColor(textColor, for: .normal)
                    }
                    
                    // Check for custom icon color first
                    if let iconColorValue = item["iconColor"] as? Int {
                        button.tintColor = CupertinoCustomSheetHandler.colorFromARGB(iconColorValue)
                    } else if let tintColor = itemTintColor {
                        button.tintColor = tintColor
                    }
                    
                    if let iconName = item["icon"] as? String, let icon = UIImage(systemName: iconName) {
                        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
                        button.setImage(icon.withConfiguration(config), for: .normal)
                        // Get icon-label spacing from item data, default to 8
                        let iconLabelSpacing = item["iconLabelSpacing"] as? Double ?? 8.0
                        // Use both imageEdgeInsets and titleEdgeInsets to properly space them
                        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(iconLabelSpacing))
                        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(iconLabelSpacing), bottom: 0, right: 0)
                    }
                    
                    rowStack.addArrangedSubview(button)
                    
                    NSLayoutConstraint.activate([
                        button.heightAnchor.constraint(equalToConstant: rowHeight)
                    ])
                }
            }
            
            contentStack.addArrangedSubview(rowStack)
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // ScrollView below header
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content stack
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
        
        // For non-modal sheets, ensure background is fully interactive
        if !isSheetModal, let presentationController = presentationController,
           let containerView = presentationController.containerView {
            // Enable user interaction on the container
            containerView.isUserInteractionEnabled = true
            
            // Find and configure the dimming view to allow touches to pass through
            for subview in containerView.subviews {
                if String(describing: type(of: subview)).contains("UIDimmingView") {
                    subview.isUserInteractionEnabled = false
                    print("✅ Disabled interaction on dimming view for non-modal sheet")
                }
            }
        }
    }
    
    private func createInlineActionButton(action: [String: Any], rowIndex: Int, actionIndex: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Store indices in the button's tag for callback
        // Encode rowIndex in upper 16 bits, actionIndex in lower 16 bits
        button.tag = (rowIndex << 16) | actionIndex
        button.addTarget(self, action: #selector(inlineActionTapped(_:)), for: .touchUpInside)
        
        // Get custom styling properties with proper type conversion
        let iconSize: CGFloat
        if let sizeValue = action["iconSize"] as? NSNumber {
            iconSize = CGFloat(sizeValue.doubleValue)
        } else {
            iconSize = 24
        }
        
        let labelSize: CGFloat
        if let sizeValue = action["labelSize"] as? NSNumber {
            labelSize = CGFloat(sizeValue.doubleValue)
        } else {
            labelSize = 13
        }
        
        let cornerRadius: CGFloat
        if let radiusValue = action["cornerRadius"] as? NSNumber {
            cornerRadius = CGFloat(radiusValue.doubleValue)
        } else {
            cornerRadius = 12
        }
        
        let iconLabelSpacing: CGFloat
        if let spacingValue = action["iconLabelSpacing"] as? NSNumber {
            iconLabelSpacing = CGFloat(spacingValue.doubleValue)
        } else {
            iconLabelSpacing = 6
        }
        
        // Create vertical stack for icon + label
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = iconLabelSpacing
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        if let iconName = action["icon"] as? String, let icon = UIImage(systemName: iconName) {
            let imageView = UIImageView(image: icon)
            let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
            imageView.image = icon.withConfiguration(config)
            imageView.tintColor = itemTintColor ?? .systemBlue
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Check if toggled
            if let isToggled = action["isToggled"] as? Bool, isToggled {
                imageView.tintColor = .systemYellow
            }
            
            stack.addArrangedSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 28),
                imageView.heightAnchor.constraint(equalToConstant: 28)
            ])
        }
        
        // Label
        if let label = action["label"] as? String {
            let labelView = UILabel()
            labelView.text = label
            labelView.font = .systemFont(ofSize: labelSize)
            labelView.textColor = itemTextColor ?? .label
            labelView.textAlignment = .center
            labelView.numberOfLines = 1
            stack.addArrangedSubview(labelView)
        }
        
        button.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -4)
        ])
        
        // Background styling - check for custom backgroundColor first
        if let backgroundColorValue = action["backgroundColor"] as? Int {
            button.backgroundColor = CupertinoCustomSheetHandler.colorFromARGB(backgroundColorValue)
        } else {
            button.backgroundColor = itemBackgroundColor ?? .secondarySystemBackground
        }
        button.layer.cornerRadius = cornerRadius
        
        // Handle enabled state
        if let enabled = action["enabled"] as? Bool, !enabled {
            button.isEnabled = false
            button.alpha = 0.5
        }
        
        return button
    }
    
    @objc private func inlineActionTapped(_ sender: UIButton) {
        // Decode rowIndex and actionIndex from tag
        let rowIndex = sender.tag >> 16
        let actionIndex = sender.tag & 0xFFFF
        
        // Send callback to Flutter
        channel?.invokeMethod("onInlineActionSelected", arguments: [
            "rowIndex": rowIndex,
            "actionIndex": actionIndex
        ])
        
        // Check if this action should dismiss the sheet
        if rowIndex < inlineActions.count,
           let actionGroup = inlineActions[rowIndex] as? [String: Any],
           let actions = actionGroup["actions"] as? [[String: Any]],
           actionIndex < actions.count,
           let action = actions[actionIndex] as? [String: Any] {
            
            let dismissOnTap = action["dismissOnTap"] as? Bool ?? true
            if dismissOnTap {
                dismiss(animated: true)
            }
        }
    }
    
    @objc private func itemTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            selectedIndex = button.tag
            
            let totalRegularItems = items.count
            
            // Check if this is a regular item or an item row item
            if button.tag < totalRegularItems {
                // Regular item
                let item = items[button.tag]
                let dismissOnTap = item["dismissOnTap"] as? Bool ?? true
                
                // Invoke callback immediately when item is tapped
                channel?.invokeMethod("onItemSelected", arguments: ["index": button.tag])
                
                if dismissOnTap {
                    dismiss(animated: true)
                }
            } else {
                // Item row item - decode the tag to get row and item indices
                let itemRowIndex = (button.tag >> 16) & 0xFFFF
                let itemInRowIndex = button.tag & 0xFFFF
                
                // Check if the item should dismiss the sheet
                var dismissOnTap = true
                if itemRowIndex < itemRows.count, let rowDict = itemRows[itemRowIndex] as? [String: Any],
                   let rowItems = rowDict["items"] as? [[String: Any]],
                   itemInRowIndex < rowItems.count {
                    let item = rowItems[itemInRowIndex]
                    dismissOnTap = item["dismissOnTap"] as? Bool ?? true
                }
                
                // Invoke callback immediately when item row item is tapped
                channel?.invokeMethod("onItemRowSelected", arguments: [
                    "rowIndex": itemRowIndex,
                    "itemIndex": itemInRowIndex
                ])
                
                if dismissOnTap {
                    dismiss(animated: true)
                }
            }
        } else if let gesture = sender as? UITapGestureRecognizer, let view = gesture.view {
            selectedIndex = view.tag
            
            let totalRegularItems = items.count
            
            // Check if this is a regular item or an item row item
            if view.tag < totalRegularItems {
                // Regular item
                let item = items[view.tag]
                let dismissOnTap = item["dismissOnTap"] as? Bool ?? true
                
                // Invoke callback immediately when item is tapped
                channel?.invokeMethod("onItemSelected", arguments: ["index": view.tag])
                
                if dismissOnTap {
                    dismiss(animated: true)
                }
            } else {
                // Item row item - decode the tag to get row and item indices
                let itemRowIndex = (view.tag >> 16) & 0xFFFF
                let itemInRowIndex = view.tag & 0xFFFF
                
                // Check if the item should dismiss the sheet
                var dismissOnTap = true
                if itemRowIndex < itemRows.count, let rowDict = itemRows[itemRowIndex] as? [String: Any],
                   let rowItems = rowDict["items"] as? [[String: Any]],
                   itemInRowIndex < rowItems.count {
                    let item = rowItems[itemInRowIndex]
                    dismissOnTap = item["dismissOnTap"] as? Bool ?? true
                }
                
                // Invoke callback immediately when item row item is tapped
                channel?.invokeMethod("onItemRowSelected", arguments: [
                    "rowIndex": itemRowIndex,
                    "itemIndex": itemInRowIndex
                ])
                
                if dismissOnTap {
                    dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?(nil)
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
