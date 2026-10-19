// Created: 2026-10-19
import AVKit
import Flutter
import UIKit

/// Factory for `CupertinoNativeAirPlayButton`.
class CupertinoAirPlayButtonViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return CupertinoAirPlayButtonPlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
  }
}

/// The system AirPlay button. Tapping it opens the system route picker; any
/// `AVPlayer` in the app follows the route chosen there, so the view needs no
/// player of its own.
class CupertinoAirPlayButtonPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let picker: AVRoutePickerView

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeAirPlayButton_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.picker = AVRoutePickerView(frame: CGRect(origin: .zero, size: frame.size))

    super.init()

    container.backgroundColor = .clear
    picker.backgroundColor = .clear
    picker.frame = container.bounds
    picker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    // Video outputs (Apple TV, AirPlay TVs) first in the picker.
    picker.prioritizesVideoDevices = true
    container.addSubview(picker)

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

  func view() -> UIView { return container }

  /// Applies whichever keys are present. A key sent as null clears that colour
  /// back to the system default.
  private func apply(_ args: [String: Any]) {
    if args.keys.contains("tint") {
      // nil restores the inherited tint.
      picker.tintColor = (args["tint"] as? NSNumber).map { Self.colorFromARGB($0.intValue) }
    }
    if args.keys.contains("activeTint") {
      // nil restores the system's active colour.
      picker.activeTintColor = (args["activeTint"] as? NSNumber).map { Self.colorFromARGB($0.intValue) }
    }
    if let v = args["prioritizesVideoDevices"] as? NSNumber {
      picker.prioritizesVideoDevices = v.boolValue
    }
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
