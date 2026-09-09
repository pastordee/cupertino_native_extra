// Created: 2026-09-09
import Flutter
import UIKit

/// Factory for `CupertinoNativeGlassSurface`.
class CupertinoGlassSurfaceFactory: NSObject, FlutterPlatformViewFactory {
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
    return CupertinoGlassSurfacePlatformView(
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

/// A backdrop of one or more Liquid Glass shapes that flow together as they
/// approach each other.
///
/// This exists because glass elements only merge when they are nested inside a
/// single `UIGlassContainerEffect`. Two separate platform views cannot do it,
/// however close they are drawn, and neither can a Flutter `BackdropFilter` —
/// merging is a property of the container, not of the material. So the shapes
/// that need to merge have to be described to one view, which is what this is.
///
/// It draws no content of its own. Flutter composites its widgets over the
/// top, so a caller renders labels, icons and controls exactly as it otherwise
/// would; only the material underneath them comes from UIKit.
///
/// Below iOS 26 there is no glass and no merging. Each element falls back to a
/// plain blur, which keeps the layout and the tinting honest even though the
/// shapes stay separate.
class CupertinoGlassSurfacePlatformView: NSObject, FlutterPlatformView {
  private let _view: UIView
  private let channel: FlutterMethodChannel

  /// The container whose effect merges the elements. Its `contentView` is the
  /// only place a nested glass element counts as part of the group.
  private var container: UIVisualEffectView?
  /// One effect view per element, in the order Dart described them.
  private var elementViews: [UIVisualEffectView] = []
  /// Reports the finger to Dart without taking it away from the glass.
  private var touchReporter: UILongPressGestureRecognizer? = nil

  /// Element geometry as last given, in logical points relative to this view.
  private var elements: [GlassElement] = []
  private var spacing: CGFloat = 0
  private var glassStyleIsClear: Bool = false
  private var tint: UIColor? = nil
  private var interactive: Bool = false

  private struct GlassElement {
    var frame: CGRect
    var cornerRadius: CGFloat
    var opacity: CGFloat
  }

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    _view = UIView(frame: frame)
    channel = FlutterMethodChannel(
      name: "cupertino_native_glass_surface_\(viewId)",
      binaryMessenger: messenger!
    )

    super.init()

    _view.backgroundColor = .clear
    // Off unless asked for. Flutter owns every control drawn over this, and a
    // platform view that swallowed touches would make them all dead. Turned on
    // only when the caller has arranged for the touches to arrive here on
    // purpose — see `interactive`.
    _view.isUserInteractionEnabled = false

    if let dict = args as? [String: Any] {
      if let s = dict["spacing"] as? NSNumber { spacing = CGFloat(truncating: s) }
      if let style = dict["style"] as? String { glassStyleIsClear = (style == "clear") }
      if let n = dict["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let i = dict["interactive"] as? NSNumber { interactive = i.boolValue }
      if #available(iOS 13.0, *), let dark = dict["isDark"] as? NSNumber {
        _view.overrideUserInterfaceStyle = dark.boolValue ? .dark : .light
      }
      elements = Self.parseElements(dict["elements"])
    }

    applyInteractive()
    buildContainer()
    syncElementViews()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "setElements":
        if let args = call.arguments as? [String: Any] {
          self.elements = Self.parseElements(args["elements"])
          if let s = args["spacing"] as? NSNumber {
            let next = CGFloat(truncating: s)
            // Rebuilding the container is the only way to change the spacing —
            // the effect is immutable once assigned — so only do it when the
            // value actually moved, not on every frame of a drag.
            if next != self.spacing {
              self.spacing = next
              self.buildContainer()
            }
          }
          self.syncElementViews()
        }
        result(nil)
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            self.tint = Self.colorFromARGB(n.intValue)
          }
          if let style = args["style"] as? String {
            self.glassStyleIsClear = (style == "clear")
          }
          if let i = args["interactive"] as? NSNumber {
            self.interactive = i.boolValue
            self.applyInteractive()
          }
          if #available(iOS 13.0, *), let dark = args["isDark"] as? NSNumber {
            self._view.overrideUserInterfaceStyle = dark.boolValue ? .dark : .light
          }
          // Both of these are baked into each element's effect object, so the
          // element views have to be made again rather than adjusted.
          self.rebuildElementViews()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { return _view }

  /// Opens or closes this view to touches, and installs the recogniser that
  /// reports them back to Dart.
  ///
  /// The recogniser observes rather than consumes: `cancelsTouchesInView` off
  /// and simultaneous recognition allowed, so UIKit still delivers the same
  /// touches to the glass and the interactive effect still runs. Taking them
  /// would report the finger accurately and leave the glass ignoring it, which
  /// is the exact thing this is here to fix.
  private func applyInteractive() {
    _view.isUserInteractionEnabled = interactive
    container?.isUserInteractionEnabled = interactive
    for v in elementViews { v.isUserInteractionEnabled = interactive }

    if interactive {
      if touchReporter == nil {
        let g = UILongPressGestureRecognizer(
          target: self,
          action: #selector(handleTouch(_:))
        )
        // Zero delay, so this is a raw touch reporter and not a long press.
        g.minimumPressDuration = 0
        g.cancelsTouchesInView = false
        g.delaysTouchesBegan = false
        g.delaysTouchesEnded = false
        g.delegate = self
        _view.addGestureRecognizer(g)
        touchReporter = g
      }
    } else if let g = touchReporter {
      _view.removeGestureRecognizer(g)
      touchReporter = nil
    }
  }

  @objc private func handleTouch(_ g: UILongPressGestureRecognizer) {
    let phase: String
    switch g.state {
    case .began: phase = "down"
    case .changed: phase = "move"
    case .ended: phase = "up"
    case .cancelled, .failed: phase = "cancel"
    default: return
    }
    let p = g.location(in: _view)
    channel.invokeMethod("onTouch", arguments: [
      "phase": phase,
      "x": Double(p.x),
      "y": Double(p.y),
    ])
  }

  // MARK: - Building

  private func buildContainer() {
    container?.removeFromSuperview()
    elementViews.removeAll()

    let effect: UIVisualEffect?
    if #available(iOS 26.0, *) {
      let group = UIGlassContainerEffect()
      group.spacing = spacing
      effect = group
    } else {
      // No container effect to have. The elements still need somewhere to
      // live, and a nil-effect visual effect view is a plain passthrough.
      effect = nil
    }

    let view = UIVisualEffectView(effect: effect)
    view.frame = _view.bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = interactive
    _view.addSubview(view)
    container = view

    rebuildElementViews()
  }

  private func rebuildElementViews() {
    guard let container = container else { return }
    for v in elementViews { v.removeFromSuperview() }
    elementViews.removeAll()

    for _ in elements {
      let effect: UIVisualEffect
      if #available(iOS 26.0, *) {
        let glass = UIGlassEffect(style: glassStyleIsClear ? .clear : .regular)
        // Left non-interactive on purpose: the interactive glass reacts to
        // touches, and every touch here belongs to a Flutter widget drawn on
        // top, so the reaction would fire in the wrong place.
        // The property that makes the glass follow a finger. It reacts to
        // touches delivered to this view, so it is worth nothing unless the
        // view is also taking them — hence the pairing with `interactive`
        // rather than a flag of its own.
        glass.isInteractive = interactive
        if let tint = tint { glass.tintColor = tint }
        effect = glass
      } else {
        effect = UIBlurEffect(style: .systemMaterial)
      }
      let v = UIVisualEffectView(effect: effect)
      v.isUserInteractionEnabled = interactive
      v.clipsToBounds = true
      container.contentView.addSubview(v)
      elementViews.append(v)
    }

    applyElementFrames()
  }

  /// Adds or removes element views only when the count changed, then moves the
  /// ones that already exist.
  ///
  /// Frames arrive on every frame of a drag. Rebuilding the effect views at
  /// that rate would restart the glass each time and cost far more than moving
  /// a layer, so the common case here has to be a move and nothing else.
  private func syncElementViews() {
    if elementViews.count != elements.count {
      rebuildElementViews()
      return
    }
    applyElementFrames()
  }

  private func applyElementFrames() {
    for (i, element) in elements.enumerated() {
      guard i < elementViews.count else { break }
      let v = elementViews[i]
      v.frame = element.frame
      // Clamped, and the curve chosen to match.
      //
      // A continuous corner cannot close on itself: asked for a radius past
      // half the shape's shorter side it stops being a corner and renders as a
      // point, so an over-rounded rectangle grows beaks on its ends instead of
      // becoming a capsule. Callers hit this without doing anything wrong —
      // one fixed radius against a shape whose height animates will cross the
      // line partway through the animation.
      //
      // At the limit the shape is a capsule, and a capsule's end is a true
      // semicircle, so the circular curve is the correct one there. Below it,
      // continuous is the iOS look.
      let limit = min(element.frame.width, element.frame.height) / 2
      let radius = max(0, min(element.cornerRadius, limit))
      v.layer.cornerRadius = radius
      if #available(iOS 13.0, *) {
        v.layer.cornerCurve = radius >= limit - 0.5 ? .circular : .continuous
      }
      // Fading the view rather than adding and removing it. A shape that
      // appears at full strength pops, and rebuilding the effect to make it
      // appear would restart the glass mid-animation.
      v.alpha = element.opacity
      v.isHidden = element.opacity <= 0.001
    }
  }

  // MARK: - Parsing

  private static func parseElements(_ raw: Any?) -> [GlassElement] {
    guard let list = raw as? [[String: Any]] else { return [] }
    return list.map { item in
      let x = (item["x"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 0
      let y = (item["y"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 0
      let w = (item["width"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 0
      let h = (item["height"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 0
      let r = (item["cornerRadius"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 0
      let o = (item["opacity"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 1
      return GlassElement(
        frame: CGRect(x: x, y: y, width: w, height: h),
        cornerRadius: r,
        opacity: max(0, min(1, o))
      )
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

extension CupertinoGlassSurfacePlatformView: UIGestureRecognizerDelegate {
  /// Never exclusive. The glass's own interactive handling is another
  /// recogniser on the same touches, and refusing to share would silently turn
  /// the effect off again.
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
  ) -> Bool {
    return true
  }
}
