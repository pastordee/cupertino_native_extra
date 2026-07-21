import UIKit
import Flutter

@available(iOS 14.0, *)
class CupertinoNativePopupButtonFactory: NSObject, FlutterPlatformViewFactory {
    private weak var messenger: FlutterBinaryMessenger?
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return CupertinoNativePopupButtonView(
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
class CupertinoNativePopupButtonView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private let button: UIButton
    private let channel: FlutterMethodChannel
    private var isDark: Bool = false
    private var tintColor: UIColor?
    private var buttonStyle: String = "plain"
    private var options: [String] = []
    private var selectedIndex: Int = 0
    private var prefix: String? = nil
    private var dividerIndices: [Int] = []
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger?) {
        containerView = UIView(frame: frame)
        containerView.backgroundColor = .clear
        
        let argsMap = args as? [String: Any] ?? [:]
        
        // Create button using UIButton.system
        button = UIButton(type: .system)
        // Don't set frame yet - will be sized after configuration
        
        // Parse button content
        let isRound = argsMap["round"] as? Bool ?? false
        
        // Parse options and selected index
        options = (argsMap["labels"] as? [String]) ?? []
        selectedIndex = (argsMap["selectedIndex"] as? Int) ?? 0
        
        // Parse divider indices
        dividerIndices = (argsMap["dividerIndices"] as? [Int]) ?? []
        
        // Parse prefix for button label
        if let prefixText = argsMap["prefix"] as? String, !prefixText.isEmpty {
            prefix = prefixText
        }
        
        // Set button title or icon
        if let iconName = argsMap["buttonIconName"] as? String, !iconName.isEmpty {
            let iconSize = argsMap["buttonIconSize"] as? CGFloat ?? 22
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
            if let icon = UIImage(systemName: iconName)?.withConfiguration(symbolConfig) {
                button.setImage(icon, for: .normal)
            }
        } else if let title = argsMap["buttonTitle"] as? String, !title.isEmpty {
            // Use configuration API for iOS 15+ to properly show title with menu
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.title = title
                config.baseForegroundColor = .label
                config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = .systemFont(ofSize: 17, weight: .regular)
                    return outgoing
                }
                button.configuration = config
                button.sizeToFit()
            } else {
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
                button.sizeToFit()
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
        
        // Create channel for callbacks
        channel = FlutterMethodChannel(
            name: "CupertinoNativePopupButton_\(viewId)",
            binaryMessenger: messenger!
        )
        
        super.init()
        
        // Size button to fit content first
        button.sizeToFit()
        
        // Update container to match button size
        let buttonSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.height))
        containerView.frame.size = buttonSize
        button.frame = containerView.bounds
        
        containerView.addSubview(button)
        
        // Apply styling
        applyButtonStyle(style: buttonStyle, isRound: isRound)
        
        // Set up UIMenu for the button
        setupMenu()
        
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
    
    
    private func setupMenu() {
        if dividerIndices.isEmpty {
            // Simple menu without sections
            var menuItems: [UIAction] = []
            
            for (index, option) in options.enumerated() {
                let action = UIAction(
                    title: option,
                    state: index == selectedIndex ? .on : .off
                ) { [weak self] _ in
                    self?.handleOptionSelected(index: index)
                }
                menuItems.append(action)
            }
            
            let menu = UIMenu(title: "", children: menuItems)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        } else {
            // Menu with sections separated by dividers
            var sections: [[UIAction]] = [[]]
            var currentSection = 0
            
            for (index, option) in options.enumerated() {
                // Check if we should start a new section
                if dividerIndices.contains(index) {
                    sections.append([])
                    currentSection += 1
                }
                
                let action = UIAction(
                    title: option,
                    state: index == selectedIndex ? .on : .off
                ) { [weak self] _ in
                    self?.handleOptionSelected(index: index)
                }
                sections[currentSection].append(action)
            }
            
            // Create menu sections
            var menuChildren: [UIMenuElement] = []
            for section in sections {
                if !section.isEmpty {
                    let menuSection = UIMenu(title: "", options: .displayInline, children: section)
                    menuChildren.append(menuSection)
                }
            }
            
            let menu = UIMenu(title: "", children: menuChildren)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        }
    }
    
    private func handleOptionSelected(index: Int) {
        selectedIndex = index
        updateButtonLabel()
        
        // Update menu to show new selection
        setupMenu()
        
        // Notify Flutter
        channel.invokeMethod("optionSelected", arguments: ["index": index])
    }
    
    private func updateButtonLabel() {
        // Update button title to show selected option (only for text buttons)
        if button.image(for: .normal) == nil && selectedIndex < options.count {
            let selectedOption = options[selectedIndex]
            let title = prefix != nil ? "\(prefix!)\(selectedOption)" : selectedOption
            
            if #available(iOS 15.0, *) {
                var config = button.configuration ?? UIButton.Configuration.plain()
                config.title = title
                config.baseForegroundColor = .label
                config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = .systemFont(ofSize: 17, weight: .regular)
                    return outgoing
                }
                button.configuration = config
                button.sizeToFit()
            } else {
                button.setTitle(title, for: .normal)
                button.sizeToFit()
            }
        }
    }
    
    private func applyButtonStyle(style: String, isRound: Bool) {
        if #available(iOS 15.0, *), button.configuration != nil {
            // Apply style through configuration
            var config = button.configuration!
            
            switch style {
            case "gray":
                config.background.backgroundColor = UIColor.systemGray5
            case "tinted":
                if let tint = tintColor {
                    config.background.backgroundColor = tint.withAlphaComponent(0.2)
                    config.baseForegroundColor = tint
                } else {
                    config.background.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                    config.baseForegroundColor = .systemBlue
                }
            case "filled":
                if let tint = tintColor {
                    config.background.backgroundColor = tint
                    config.baseForegroundColor = .white
                } else {
                    config.background.backgroundColor = UIColor.systemBlue
                    config.baseForegroundColor = .white
                }
            case "glass":
                config.background.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
            default: // plain
                config.background.backgroundColor = .clear
            }
            
            button.configuration = config
        } else {
            // Apply style the old way
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
    }
    
    func view() -> UIView {
        return containerView
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSelection":
            if let args = call.arguments as? [String: Any],
               let index = args["selectedIndex"] as? Int {
                selectedIndex = index
                updateButtonLabel()
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
            
        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let isDark = args["isDark"] as? Bool {
                self.isDark = isDark
                updateAppearance()
            }
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
        let isRound = button.layer.cornerRadius > 0
        applyButtonStyle(style: buttonStyle, isRound: isRound)
    }
}
