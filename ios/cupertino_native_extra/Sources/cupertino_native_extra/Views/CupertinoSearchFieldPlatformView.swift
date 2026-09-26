// Created: 2026-09-26
import Flutter
import UIKit

/// Factory for `CupertinoNativeSearchField`.
class CupertinoSearchFieldFactory: NSObject, FlutterPlatformViewFactory {
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
    return CupertinoSearchFieldPlatformView(
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

/// Lays its pieces out whenever Flutter resizes the platform view.
private final class SearchFieldContainer: UIView {
  var onLayout: (() -> Void)?
  override func layoutSubviews() {
    super.layoutSubviews()
    onLayout?()
  }
}

/// The search field iOS 26 shows while searching (Mail, Photos, Music): a
/// real `UISearchTextField` in a glass capsule, with a round glass × beside
/// it that ends the search.
///
/// Why not `UISearchController`: it draws its results in a native view
/// controller, and a Flutter app's results can only be drawn by Flutter. So
/// the field is native and the page around it — recents, suggestions,
/// results — is Flutter (see `CNNativeSearchField`). Unlike the older
/// `CupertinoNativeSearchBar`, Dart can drive it after creation: focus,
/// unfocus, set the text, restyle.
class CupertinoSearchFieldPlatformView: NSObject, FlutterPlatformView, UISearchTextFieldDelegate {
  private let container = SearchFieldContainer()
  private let channel: FlutterMethodChannel
  private let fieldGlass: UIVisualEffectView
  private let closeGlass: UIVisualEffectView
  private let field = UISearchTextField()
  private let closeButton = UIButton(type: .system)

  private var showsClose = true
  /// Room between the field and the ×, as in Mail.
  private let gap: CGFloat = 10

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    channel = FlutterMethodChannel(
      name: "cupertino_native_search_field_\(viewId)",
      binaryMessenger: messenger
    )
    fieldGlass = UIVisualEffectView(effect: Self.glassEffect())
    closeGlass = UIVisualEffectView(effect: Self.glassEffect())
    super.init()

    container.frame = frame
    container.backgroundColor = .clear

    let dict = args as? [String: Any] ?? [:]
    showsClose = (dict["showsClose"] as? NSNumber)?.boolValue ?? true

    fieldGlass.clipsToBounds = true
    closeGlass.clipsToBounds = true
    container.addSubview(fieldGlass)
    container.addSubview(closeGlass)

    field.delegate = self
    field.borderStyle = .none
    field.backgroundColor = .clear
    field.returnKeyType = .search
    field.enablesReturnKeyAutomatically = true
    field.font = .preferredFont(forTextStyle: .body)
    field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    fieldGlass.contentView.addSubview(field)

    closeButton.setImage(
      UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)),
      for: .normal)
    closeButton.tintColor = .label
    closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    closeGlass.contentView.addSubview(closeButton)

    apply(dict)
    container.onLayout = { [weak self] in self?.layout() }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "focus":
        self.field.becomeFirstResponder()
        result(nil)
      case "unfocus":
        self.field.resignFirstResponder()
        result(nil)
      case "setText":
        let text = (call.arguments as? [String: Any])?["text"] as? String ?? ""
        self.field.text = text
        result(nil)
      case "update":
        self.apply(call.arguments as? [String: Any] ?? [:])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    if (dict["autofocus"] as? NSNumber)?.boolValue ?? false {
      // The platform view isn't in a window yet; focus once it is.
      DispatchQueue.main.async { [weak self] in
        self?.field.becomeFirstResponder()
      }
    }
  }

  func view() -> UIView { container }

  private static func glassEffect() -> UIVisualEffect {
    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.isInteractive = true
      return glass
    }
    return UIBlurEffect(style: .systemThinMaterial)
  }

  private func apply(_ dict: [String: Any]) {
    if let p = dict["placeholder"] as? String { field.placeholder = p }
    if let t = dict["text"] as? String, field.text != t { field.text = t }
    if let dark = dict["isDark"] as? NSNumber {
      container.overrideUserInterfaceStyle = dark.boolValue ? .dark : .light
    }
    if let n = dict["tint"] as? NSNumber {
      field.tintColor = Self.color(n.intValue)
    }
    if let s = dict["showsClose"] as? NSNumber {
      showsClose = s.boolValue
      layout()
    }
  }

  private func layout() {
    let b = container.bounds
    guard b.width > 0, b.height > 0 else { return }
    let h = b.height
    let closeWidth = showsClose ? h : 0
    fieldGlass.frame = CGRect(x: 0, y: 0, width: b.width - (showsClose ? closeWidth + gap : 0), height: h)
    fieldGlass.layer.cornerRadius = h / 2
    fieldGlass.layer.cornerCurve = .circular
    field.frame = fieldGlass.bounds.insetBy(dx: 12, dy: 0)
    closeGlass.isHidden = !showsClose
    closeGlass.frame = CGRect(x: b.width - closeWidth, y: 0, width: closeWidth, height: h)
    closeGlass.layer.cornerRadius = h / 2
    closeGlass.layer.cornerCurve = .circular
    closeButton.frame = closeGlass.bounds
  }

  @objc private func textChanged() {
    channel.invokeMethod("onChanged", arguments: ["text": field.text ?? ""])
  }

  @objc private func closeTapped() {
    field.resignFirstResponder()
    channel.invokeMethod("onClose", arguments: nil)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    channel.invokeMethod("onSubmitted", arguments: ["text": textField.text ?? ""])
    textField.resignFirstResponder()
    return true
  }

  /// The clear button isn't guaranteed to report an edit; report it here.
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    DispatchQueue.main.async { [weak self] in self?.textChanged() }
    return true
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    channel.invokeMethod("onFocusChanged", arguments: ["focused": true])
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    channel.invokeMethod("onFocusChanged", arguments: ["focused": false])
  }

  private static func color(_ argb: Int) -> UIColor {
    UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255)
  }
}
