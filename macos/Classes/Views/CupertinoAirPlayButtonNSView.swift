// Created: 2026-10-19
import AVKit
import Cocoa
import FlutterMacOS

/// The system AirPlay button. Clicking it opens the system route picker.
///
/// macOS has no `prioritizesVideoDevices`, so that key is ignored here.
class CupertinoAirPlayButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private let picker: AVRoutePickerView

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeAirPlayButton_\(viewId)", binaryMessenger: messenger)
    self.picker = AVRoutePickerView(frame: .zero)

    super.init(frame: .zero)

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor

    picker.isRoutePickerButtonBordered = false
    picker.translatesAutoresizingMaskIntoConstraints = false
    addSubview(picker)
    NSLayoutConstraint.activate([
      picker.leadingAnchor.constraint(equalTo: leadingAnchor),
      picker.trailingAnchor.constraint(equalTo: trailingAnchor),
      picker.topAnchor.constraint(equalTo: topAnchor),
      picker.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    if let dict = args as? [String: Any] {
      apply(dict)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          self.apply(args)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /// Applies whichever keys are present. A key sent as null clears that colour
  /// back to the system default.
  private func apply(_ args: [String: Any]) {
    if args.keys.contains("tint") {
      let color = (args["tint"] as? NSNumber).map { Self.colorFromARGB($0.intValue) }
      picker.setRoutePickerButtonColor(color, for: .normal)
      picker.setRoutePickerButtonColor(color, for: .normalHighlighted)
    }
    if args.keys.contains("activeTint") {
      let color = (args["activeTint"] as? NSNumber).map { Self.colorFromARGB($0.intValue) }
      picker.setRoutePickerButtonColor(color, for: .active)
      picker.setRoutePickerButtonColor(color, for: .activeHighlighted)
    }
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

/// Factory for `CupertinoNativeAirPlayButton`.
class CupertinoAirPlayButtonViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
    return CupertinoAirPlayButtonNSView(viewId: viewId, args: args, messenger: messenger)
  }
}
