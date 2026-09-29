import Cocoa
import FlutterMacOS

@available(macOS 11.0, *)
class CupertinoNativePopupButtonFactory: NSObject, FlutterPlatformViewFactory {
    private weak var messenger: FlutterBinaryMessenger?
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        return CupertinoNativePopupButtonView(
            frame: .zero,
            viewId: viewId,
            args: args,
            messenger: messenger
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(macOS 11.0, *)
// On macOS the platform view IS the NSView (no FlutterPlatformView wrapper).
class CupertinoNativePopupButtonView: NSView {
    private let containerView: NSView
    private let popUpButton: NSPopUpButton
    private let channel: FlutterMethodChannel
    private var isDark: Bool = false
    private var tintColor: NSColor?
    private var buttonStyle: String = "plain"
    private var options: [String] = []
    private var selectedIndex: Int = 0
    private var prefix: String? = nil
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger?) {
        containerView = NSView(frame: frame)
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor
        
        let argsMap = args as? [String: Any] ?? [:]
        
        // Parse options and selected index
        options = (argsMap["labels"] as? [String]) ?? []
        selectedIndex = (argsMap["selectedIndex"] as? Int) ?? 0
        
        // Parse prefix for button label
        if let prefixText = argsMap["prefix"] as? String, !prefixText.isEmpty {
            prefix = prefixText
        }
        
        // Create NSPopUpButton
        popUpButton = NSPopUpButton(frame: containerView.bounds)
        popUpButton.autoresizingMask = [.width, .height]
        
        // Set button style
        if let isRound = argsMap["round"] as? Bool, isRound {
            popUpButton.bezelStyle = .rounded
        } else {
            popUpButton.bezelStyle = .texturedSquare
        }
        
        // Populate menu items
        popUpButton.removeAllItems()
        for option in options {
            popUpButton.addItem(withTitle: option)
        }
        
        // Set initial selection
        if selectedIndex < options.count {
            popUpButton.selectItem(at: selectedIndex)
        }
        
        // Parse button content
        if let title = argsMap["buttonTitle"] as? String, !title.isEmpty {
            popUpButton.title = title
        } else if let iconName = argsMap["buttonIconName"] as? String, !iconName.isEmpty {
            let iconSize = argsMap["buttonIconSize"] as? CGFloat ?? 22
            let symbolConfig = NSImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
            if let icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?
                .withSymbolConfiguration(symbolConfig) {
                popUpButton.image = icon
                popUpButton.imagePosition = .imageOnly
            }
        }
        
        // Apply button style
        if let style = argsMap["buttonStyle"] as? String {
            buttonStyle = style
        }
        
        // Create channel for callbacks
        channel = FlutterMethodChannel(
            name: "CupertinoNativePopupButton_\(viewId)",
            binaryMessenger: messenger!
        )
        
        super.init(frame: frame)
        
        containerView.autoresizingMask = [.width, .height]
        addSubview(containerView)
        containerView.addSubview(popUpButton)
        
        // Apply styling
        applyButtonStyle(style: buttonStyle)
        
        // Set up button action
        popUpButton.target = self
        popUpButton.action = #selector(selectionChanged(_:))
        
        // Apply tint color
        if let styleDict = argsMap["style"] as? [String: Any],
           let tint = styleDict["tint"] as? Int {
            let color = NSColor(argb: tint)
            popUpButton.contentTintColor = color
            tintColor = color
        }
        
        // Parse dark mode
        isDark = argsMap["isDark"] as? Bool ?? false
        if isDark {
            containerView.appearance = NSAppearance(named: .darkAqua)
        }
        
        // Set up method channel handler
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    @objc private func selectionChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        if index >= 0 {
            selectedIndex = index
            updateButtonTitle()
            // Notify Flutter
            channel.invokeMethod("optionSelected", arguments: ["index": index])
        }
    }
    
    private func updateButtonTitle() {
        if selectedIndex < options.count {
            let selectedOption = options[selectedIndex]
            let title = prefix != nil ? "\(prefix!)\(selectedOption)" : selectedOption
            popUpButton.title = title
        }
    }
    
    private func applyButtonStyle(style: String) {
        switch style {
        case "gray":
            popUpButton.bezelColor = NSColor.systemGray.withAlphaComponent(0.3)
        case "tinted":
            if let tint = tintColor {
                popUpButton.bezelColor = tint.withAlphaComponent(0.2)
            } else {
                popUpButton.bezelColor = NSColor.systemBlue.withAlphaComponent(0.2)
            }
        case "filled":
            if let tint = tintColor {
                popUpButton.bezelColor = tint
                popUpButton.contentTintColor = .white
            } else {
                popUpButton.bezelColor = NSColor.systemBlue
                popUpButton.contentTintColor = .white
            }
        case "glass":
            popUpButton.bezelColor = NSColor.windowBackgroundColor.withAlphaComponent(0.7)
        default: // plain
            popUpButton.isBordered = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSelection":
            if let args = call.arguments as? [String: Any],
               let index = args["selectedIndex"] as? Int {
                selectedIndex = index
                popUpButton.selectItem(at: index)
            }
            result(nil)
            
        case "setStyle":
            if let args = call.arguments as? [String: Any] {
                if let tint = args["tint"] as? Int {
                    tintColor = NSColor(argb: tint)
                    popUpButton.contentTintColor = tintColor
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
            let size = popUpButton.intrinsicContentSize
            result(["width": size.width, "height": size.height])
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func updateAppearance() {
        containerView.appearance = isDark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
    }
    
    private func updateButtonStyle() {
        applyButtonStyle(style: buttonStyle)
    }
}

// Helper extension for ARGB color conversion
extension NSColor {
    convenience init(argb: Int) {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
