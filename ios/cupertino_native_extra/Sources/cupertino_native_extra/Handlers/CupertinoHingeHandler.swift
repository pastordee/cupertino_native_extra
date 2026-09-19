// Created: 2026-09-19
import Flutter
import UIKit

/// The fold, for Flutter: iOS 27.1's `UIHinge` (status and angle, live through
/// `UIHingeInteraction`) and the reserved regions a folding display has — the
/// fold itself ("division") and the camera ("occlusion").
///
/// Reached by name at runtime rather than compiled against. Xcode 27.0 and
/// 27.1 ship the same Swift, so there is no compile-time way to tell the SDKs
/// apart, and an app built with 27.0 — every App Store build at the time of
/// writing — must still compile this. On a system without the APIs it reports
/// no hinge and no regions.
///
/// Sends a map on `cupertino_native/hinge` whenever the hinge moves or the
/// window changes size:
///   status: "unknown" | "closed" | "partiallyOpen" | "fullyOpen" | "none"
///   angle:  radians (π is flat), or null
///   folds / occlusions: [{x, y, width, height}] in window points
class CupertinoHingeHandler: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var interaction: AnyObject?
  private weak var hostView: UIView?
  private var boundsObservation: NSKeyValueObservation?
  private var lastHinge: NSObject?

  init(messenger: FlutterBinaryMessenger) {
    super.init()
    FlutterEventChannel(name: "cupertino_native/hinge", binaryMessenger: messenger)
      .setStreamHandler(self)
    FlutterMethodChannel(name: "cupertino_native/hinge_query", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard let self = self else { result(nil); return }
        if call.method == "get" { result(self.snapshot()) } else {
          result(FlutterMethodNotImplemented)
        }
      }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    attach()
    events(snapshot())
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    detach()
    return nil
  }

  // MARK: - Attaching

  private func rootView() -> UIView? {
    let scene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
      ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
    return scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController?.view
      ?? scene?.windows.first?.rootViewController?.view
  }

  private func attach() {
    guard let view = rootView() else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        if self?.sink != nil { self?.attach() }
      }
      return
    }
    hostView = view

    // UIHingeInteraction(updateHandler:), by name.
    if let cls = NSClassFromString("UIHingeInteraction") as? NSObject.Type {
      let handler: @convention(block) (AnyObject, AnyObject) -> Void = {
        [weak self] _, update in
        self?.lastHinge = (update as? NSObject)?.value(forKey: "hinge") as? NSObject
        self?.emit()
      }
      let sel = NSSelectorFromString("initWithUpdateHandler:")
      if let allocated = cls.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue()
        as? NSObject,
        allocated.responds(to: sel),
        let made = allocated.perform(sel, with: handler)?.takeUnretainedValue()
          as? UIInteraction
      {
        view.addInteraction(made)
        interaction = made
      }
    }

    // The fold's position changes with the window (rotation, split view).
    boundsObservation = view.observe(\.bounds, options: [.new]) { [weak self] _, _ in
      DispatchQueue.main.async { self?.emit() }
    }
  }

  private func detach() {
    if let view = hostView, let i = interaction as? UIInteraction {
      view.removeInteraction(i)
    }
    interaction = nil
    boundsObservation = nil
  }

  private func emit() {
    sink?(snapshot())
  }

  // MARK: - Reading

  private func snapshot() -> [String: Any] {
    var out: [String: Any] = [
      "status": "none", "angle": NSNull(), "folds": [], "occlusions": [],
    ]
    if let hinge = lastHinge {
      let raw = (hinge.value(forKey: "status") as? Int) ?? 0
      out["status"] = ["unknown", "closed", "partiallyOpen", "fullyOpen"][
        min(max(raw, 0), 3)]
      if let a = hinge.value(forKey: "angle") as? Double { out["angle"] = a }
    }
    guard let view = hostView ?? rootView() else { return out }
    out["folds"] = regions(of: "divisionRegionKind", in: view)
    out["occlusions"] = regions(of: "occlusionRegionKind", in: view)
    return out
  }

  private func regions(of kindName: String, in view: UIView) -> [[String: Double]] {
    guard let kindCls = NSClassFromString("UIViewReservedRegionKind") as? NSObject.Type else {
      return []
    }
    let kindSel = NSSelectorFromString(kindName)
    guard kindCls.responds(to: kindSel),
      let kind = kindCls.perform(kindSel)?.takeUnretainedValue()
    else { return [] }
    let querySel = NSSelectorFromString("reservedRegionsOfKind:")
    guard view.responds(to: querySel),
      let list = view.perform(querySel, with: kind)?.takeUnretainedValue() as? [NSObject]
    else { return [] }
    return list.compactMap { region in
      if let active = region.value(forKey: "active") as? Bool, !active { return nil }
      guard let value = region.value(forKey: "frame") as? NSValue else { return nil }
      let r = view.convert(value.cgRectValue, to: nil)
      return [
        "x": Double(r.origin.x), "y": Double(r.origin.y),
        "width": Double(r.size.width), "height": Double(r.size.height),
      ]
    }
  }
}
