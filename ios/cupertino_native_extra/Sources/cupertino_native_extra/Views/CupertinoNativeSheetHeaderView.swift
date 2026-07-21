import Flutter
import UIKit

/// Factory for creating CupertinoNativeSheetHeaderView instances
class CupertinoNativeSheetHeaderViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return CupertinoNativeSheetHeaderView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

/// Native iOS sheet header view that integrates with Flutter via UiKitView
///
/// This view renders the native header for a sheet, including:
/// - Title label with customizable font and color
/// - Close button (x mark) with customizable position and color
/// - Optional divider line
/// - Background blur effect
///
/// The header is designed to be used with UISheetPresentationController
/// while the content area contains Flutter widgets.
class CupertinoNativeSheetHeaderView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var channel: FlutterMethodChannel
    
    // UI Components
    private var titleLabel: UILabel!
    private var closeButton: UIButton!
    private var dividerLine: UIView?
    private var blurEffectView: UIVisualEffectView?
    
    // Configuration
    private var title: String = ""
    private var headerHeight: CGFloat = 56.0
    private var showHeaderDivider: Bool = true
    private var closeButtonPosition: String = "trailing"
    private var closeButtonIcon: String = "xmark"
    private var titleFontSize: CGFloat = 17.0
    private var titleFontWeight: UIFont.Weight = .semibold
    private var titleColor: UIColor = .label
    private var backgroundColor: UIColor? = nil
    private var dividerColor: UIColor = .separator
    private var closeButtonColor: UIColor = .label
    private var closeButtonSize: CGFloat = 17.0
    private var useBlur: Bool = true
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView(frame: frame)
        channel = FlutterMethodChannel(
            name: "cupertino_native_sheet_content_\(viewId)",
            binaryMessenger: messenger!
        )
        
        super.init()
        
        // Parse arguments
        if let arguments = args as? [String: Any] {
            parseArguments(arguments)
        }
        
        setupView()
        setupMethodChannel()
    }
    
    func view() -> UIView {
        return _view
    }
    
    private func parseArguments(_ args: [String: Any]) {
        title = args["title"] as? String ?? ""
        headerHeight = args["headerHeight"] as? CGFloat ?? 56.0
        showHeaderDivider = args["showHeaderDivider"] as? Bool ?? true
        closeButtonPosition = args["closeButtonPosition"] as? String ?? "trailing"
        closeButtonIcon = args["closeButtonIcon"] as? String ?? "xmark"
        
        // Parse custom colors
        if let bgColorValue = args["headerBackgroundColor"] as? Int64 {
            backgroundColor = UIColor(argb: bgColorValue)
            useBlur = false // Don't use blur if custom color is specified
        }
        
        if let titleColorValue = args["headerTitleColor"] as? Int64 {
            titleColor = UIColor(argb: titleColorValue) ?? .label
        }
        
        if let dividerColorValue = args["headerDividerColor"] as? Int64 {
            dividerColor = UIColor(argb: dividerColorValue) ?? .separator
        }
        
        if let buttonColorValue = args["closeButtonColor"] as? Int64 {
            closeButtonColor = UIColor(argb: buttonColorValue) ?? .label
        }
        
        // Parse font customization
        if let fontSize = args["headerTitleSize"] as? CGFloat {
            titleFontSize = fontSize
        }
        
        if let fontWeightStr = args["headerTitleWeight"] as? String {
            titleFontWeight = fontWeightFromString(fontWeightStr)
        }
        
        if let buttonSize = args["closeButtonSize"] as? CGFloat {
            closeButtonSize = buttonSize
        }
    }
    
    private func fontWeightFromString(_ weightStr: String) -> UIFont.Weight {
        switch weightStr {
        case "ultraLight": return .ultraLight
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
    
    private func setupView() {
        // Set background - either custom color or blur effect
        if let customBg = backgroundColor {
            _view.backgroundColor = customBg
        } else if useBlur {
            _view.backgroundColor = .clear
            
            // Add blur effect for glassmorphism
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = _view.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if let blurView = blurEffectView {
                _view.addSubview(blurView)
            }
        } else {
            _view.backgroundColor = .systemBackground
        }
        
        // Create container for content (sits on top of blur)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        _view.addSubview(containerView)
        
        // Title label
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: titleFontSize, weight: titleFontWeight)
        titleLabel.textColor = titleColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set icon based on SF Symbol name
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: closeButtonSize, weight: .semibold)
            let image = UIImage(systemName: closeButtonIcon, withConfiguration: config)
            closeButton.setImage(image, for: .normal)
        }
        
        closeButton.tintColor = closeButtonColor
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        // Divider line
        if showHeaderDivider {
            dividerLine = UIView()
            dividerLine?.backgroundColor = dividerColor
            dividerLine?.translatesAutoresizingMaskIntoConstraints = false
            if let divider = dividerLine {
                containerView.addSubview(divider)
            }
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Container fills the view
            containerView.topAnchor.constraint(equalTo: _view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
            
            // Title label centered
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 60),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -60),
        ])
        
        // Close button position (trailing or leading)
        if closeButtonPosition == "leading" {
            NSLayoutConstraint.activate([
                closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        } else {
            NSLayoutConstraint.activate([
                closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        // Divider at bottom
        if let divider = dividerLine {
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                divider.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                divider.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
    }
    
    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            switch call.method {
            case "updateTitle":
                if let args = call.arguments as? [String: Any],
                   let newTitle = args["title"] as? String {
                    self.updateTitle(newTitle)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing title", details: nil))
                }
                
            case "dismiss":
                self.dismissSheet()
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismissSheet()
    }
    
    private func dismissSheet() {
        // Send close event to Flutter
        channel.invokeMethod("onClose", arguments: nil)
    }
    
    private func updateTitle(_ newTitle: String) {
        title = newTitle
        titleLabel.text = newTitle
    }
}

/// Extension to help with color conversion from Flutter
extension UIColor {
    convenience init?(argb: Int64) {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
