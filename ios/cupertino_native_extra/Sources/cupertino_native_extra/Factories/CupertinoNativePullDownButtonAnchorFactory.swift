import UIKit
import Flutter

@available(iOS 14.0, *)
class CupertinoNativePullDownButtonAnchorFactory: NSObject, FlutterPlatformViewFactory {
    private weak var messenger: FlutterBinaryMessenger?
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return CupertinoNativePullDownButtonAnchorView(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 14.0, *)
class CupertinoNativePullDownButtonAnchorView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private let button: UIButton
    private let channel: FlutterMethodChannel
    private var isDark: Bool = false
    private var tintColor: UIColor?
    private var buttonStyle: String = "plain"
    private var menuItems: [UIMenuElement] = []
    // Store menu data for alert presentation
    private var labels: [String] = []
    private var symbols: [String] = []
    private var isDivider: [Bool] = []
    private var enabled: [Bool] = []
    private var isDestructive: [Bool] = []
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger?) {
        containerView = UIView(frame: frame)
        containerView.backgroundColor = .clear
        
        let argsMap = args as? [String: Any] ?? [:]
        
        // Create button using UIButton.system - EXACT same as CNPopupMenuButton
        button = UIButton(type: .system)
        button.frame = containerView.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Parse button content
        let isRound = argsMap["round"] as? Bool ?? false
        
        if let title = argsMap["buttonTitle"] as? String {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        } else if let iconName = argsMap["buttonIconName"] as? String {
            let iconSize = argsMap["buttonIconSize"] as? CGFloat ?? 22
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
            if let icon = UIImage(systemName: iconName)?.withConfiguration(symbolConfig) {
                button.setImage(icon, for: .normal)
            }
        }
        
        // Apply button style
        if let style = argsMap["buttonStyle"] as? String {
            buttonStyle = style
        }
        
        if isRound {
            button.layer.cornerRadius = frame.height / 2
            button.clipsToBounds = true
        }
        
        // Store menu data for alert presentation
        labels = (argsMap["labels"] as? [String]) ?? []
        symbols = (argsMap["sfSymbols"] as? [String]) ?? []
        isDivider = (argsMap["isDivider"] as? [Bool]) ?? []
        enabled = (argsMap["enabled"] as? [Bool]) ?? []
        isDestructive = (argsMap["isDestructive"] as? [Bool]) ?? []
        
        // Create channel for callbacks
        channel = FlutterMethodChannel(
            name: "CupertinoNativePullDownButtonAnchor_\(viewId)",
            binaryMessenger: messenger!
        )
        
        // Create menu items (for reference, though we'll use alert controller)
        menuItems = Self.createMenuItems(from: argsMap, viewId: viewId, messenger: messenger)
        
        super.init()
        
        containerView.addSubview(button)
        
        // Apply styling after button is created
        applyButtonStyle(style: buttonStyle, isRound: isRound)
        
        // Instead of using showsMenuAsPrimaryAction (which requires 2 taps in some contexts),
        // we'll manually present the menu on tap for immediate response
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        // Apply tint color
        if let styleDict = argsMap["style"] as? [String: Any],
           let tint = styleDict["tint"] as? Int {
            let color = UIColor(argb: tint)
            button.tintColor = color
            tintColor = color
        }
        
        // Parse dark mode
        isDark = argsMap["isDark"] as? Bool ?? false
        if isDark {
            containerView.overrideUserInterfaceStyle = .dark
        }
        
        // Set up method channel handler
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        // Present menu immediately on first tap
        presentMenu(for: sender)
    }
    
    private func presentMenu(for button: UIButton) {
        // Try to find view controller for presentation
        var responder: UIResponder? = containerView
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                // Present as UIAlertController with action sheet style
                // This provides immediate presentation on first tap
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                // Build actions from stored menu data
                for i in 0..<labels.count {
                    // Skip dividers
                    if i < isDivider.count && isDivider[i] {
                        continue
                    }
                    
                    let label = labels[i]
                    let symbolName = i < symbols.count ? symbols[i] : ""
                    let isEnabled = i < enabled.count ? enabled[i] : true
                    let destructive = i < isDestructive.count ? isDestructive[i] : false
                    
                    let style: UIAlertAction.Style = destructive ? .destructive : .default
                    let alertAction = UIAlertAction(title: label, style: style) { [weak self] _ in
                        // Invoke Flutter callback
                        self?.channel.invokeMethod("itemSelected", arguments: ["index": i])
                    }
                    alertAction.isEnabled = isEnabled
                    
                    // Set image if available (iOS 13+)
                    if !symbolName.isEmpty, let image = UIImage(systemName: symbolName) {
                        alertAction.setValue(image, forKey: "image")
                    }
                    
                    alert.addAction(alertAction)
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                // Configure popover for iPad (shows with arrow)
                if let popover = alert.popoverPresentationController {
                    popover.sourceView = button
                    popover.sourceRect = button.bounds
                    popover.permittedArrowDirections = [.up, .down]
                }
                
                viewController.present(alert, animated: true)
                return
            }
            responder = nextResponder
        }
    }
    
    private func rebuildMenu() {
        // Keep menu reference but we'll present it manually
        // This ensures the menu items are available for manual presentation
    }
    
    private func applyButtonStyle(style: String, isRound: Bool) {
        switch style {
        case "gray":
            button.backgroundColor = UIColor.systemGray5
        case "tinted":
            if let tint = tintColor {
                button.backgroundColor = tint.withAlphaComponent(0.2)
            } else {
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            }
        case "filled":
            if let tint = tintColor {
                button.backgroundColor = tint
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.systemBlue
                button.setTitleColor(.white, for: .normal)
            }
        case "glass":
            button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        default: // plain
            button.backgroundColor = .clear
        }
    }
    
    func view() -> UIView {
        return containerView
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let isDark = args["isDark"] as? Bool {
                self.isDark = isDark
                updateAppearance()
            }
            result(nil)
            
        case "setStyle":
            if let args = call.arguments as? [String: Any] {
                if let tint = args["tint"] as? Int {
                    tintColor = UIColor(argb: tint)
                    button.tintColor = tintColor
                }
                if let style = args["buttonStyle"] as? String {
                    buttonStyle = style
                    updateButtonStyle()
                }
            }
            result(nil)
            
        case "setPressed":
            // Handle pressed state if needed
            result(nil)
            
        case "getIntrinsicSize":
            let size = button.intrinsicContentSize
            result(["width": size.width, "height": size.height])
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func updateAppearance() {
        containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    
    private func updateButtonStyle() {
        // Re-apply the button style without using Configuration API
        let isRound = button.layer.cornerRadius > 0
        applyButtonStyle(style: buttonStyle, isRound: isRound)
    }
    
    private static func createMenuItems(from args: [String: Any], viewId: Int64, messenger: FlutterBinaryMessenger?) -> [UIMenuElement] {
        guard let labels = args["labels"] as? [String],
              let symbols = args["sfSymbols"] as? [String],
              let isDivider = args["isDivider"] as? [Bool],
              let enabled = args["enabled"] as? [Bool],
              let isDestructive = args["isDestructive"] as? [Bool] else {
            return []
        }
        
        let channel = FlutterMethodChannel(
            name: "CupertinoNativePullDownButtonAnchor_\(viewId)",
            binaryMessenger: messenger!
        )
        
        var menuElements: [UIMenuElement] = []
        
        for i in 0..<labels.count {
            if isDivider[i] {
                // Skip dividers in this context - UIMenu handles grouping
                continue
            }
            
            let label = labels[i]
            let symbolName = symbols[i]
            let isEnabled = enabled[i]
            let destructive = isDestructive[i]
            
            var image: UIImage?
            if !symbolName.isEmpty {
                image = UIImage(systemName: symbolName)
            }
            
            let action = UIAction(
                title: label,
                image: image,
                attributes: destructive ? [.destructive] : (isEnabled ? [] : [.disabled])
            ) { _ in
                channel.invokeMethod("itemSelected", arguments: ["index": i])
            }
            
            menuElements.append(action)
        }
        
        return menuElements
    }
}

// Helper extension for ARGB color conversion
extension UIColor {
    convenience init(argb: Int) {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
