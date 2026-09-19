// Created: 2026-09-19
import Flutter
import UIKit

/// Factory for `CupertinoNativeVerticalBar`.
class CupertinoVerticalBarFactory: NSObject, FlutterPlatformViewFactory {
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
    return CupertinoVerticalBarPlatformView(
      frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

/// A bar laid out down the side of the screen, the way iOS 27.1 places tab
/// bars and toolbars on iPhone Duo ("Designing for iPhone Duo" → Vertical
/// controls).
///
/// UIKit only turns the bars it manages itself — a tab bar controller's, a
/// navigation controller's toolbar — vertical. A bar drawn inside a Flutter
/// view is not one of those, so this builds the same thing from the same
/// parts: each group of items is a capsule of Liquid Glass, all of them inside
/// one glass container so neighbouring capsules merge, and every item is a real
/// UIButton, so presses, menus and the glass's response to a finger are the
/// system's own.
///
/// Two modes. In tab mode one item is selected and sits on a lozenge with its
/// symbol in the tint colour, as the system tab bar draws it. In toolbar mode
/// items are plain; a group may be marked prominent, which fills it with the
/// tint (the Compose / Done position).
class CupertinoVerticalBarPlatformView: NSObject, FlutterPlatformView {
  private let root: UIView
  private let channel: FlutterMethodChannel

  private var groups: [[Item]] = []
  private var prominent: [Bool] = []
  private var selected: Int = -1
  private var itemSize: CGFloat = 46
  private var gap: CGFloat = 10
  private var inset: CGFloat = 4
  private var tint: UIColor = .systemBlue
  private var tabMode: Bool = false

  /// Views rebuilt whenever the description changes.
  private var container: UIVisualEffectView?
  private var buttons: [UIButton] = []

  /// Tab mode: the selection lozenge and the capsule it moves in, for the
  /// drag across tabs the system tab bar has.
  private var pill: UIView?
  private weak var tabCapsule: UIView?
  private var tabRange: Range<Int> = 0..<0

  private struct Item {
    var symbol: String?
    var image: UIImage?
    var label: String
    var badge: String?
    var menu: [[String: Any]]?
  }

  init(
    frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    root = UIView(frame: frame)
    channel = FlutterMethodChannel(
      name: "CupertinoNativeVerticalBar_\(viewId)", binaryMessenger: messenger)
    super.init()
    root.backgroundColor = .clear
    apply(args)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      if call.method == "update" {
        self.apply(call.arguments)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { root }

  // MARK: - Description

  private func apply(_ args: Any?) {
    guard let dict = args as? [String: Any] else { return }
    if let n = dict["itemSize"] as? NSNumber { itemSize = CGFloat(truncating: n) }
    if let n = dict["gap"] as? NSNumber { gap = CGFloat(truncating: n) }
    if let n = dict["inset"] as? NSNumber { inset = CGFloat(truncating: n) }
    if let n = dict["tint"] as? NSNumber { tint = Self.color(n.intValue) }
    if let n = dict["selected"] as? NSNumber { selected = n.intValue }
    if let b = dict["tabMode"] as? NSNumber { tabMode = b.boolValue }
    if #available(iOS 13.0, *), let dark = dict["isDark"] as? NSNumber {
      root.overrideUserInterfaceStyle = dark.boolValue ? .dark : .light
    }
    if let raw = dict["groups"] as? [[String: Any]] {
      groups = raw.map { g in
        ((g["items"] as? [[String: Any]]) ?? []).map { i in
          var image: UIImage? = nil
          if let data = i["imageData"] as? FlutterStandardTypedData,
            let src = UIImage(data: data.data)
          {
            let side = CGFloat(truncating: (i["imageSize"] as? NSNumber) ?? 22)
            image = Self.draw(src, side: side).withRenderingMode(.alwaysTemplate)
          }
          return Item(
            symbol: i["symbol"] as? String, image: image,
            label: (i["label"] as? String) ?? "",
            badge: i["badge"] as? String,
            menu: i["menu"] as? [[String: Any]])
        }
      }
      prominent = raw.map { ($0["prominent"] as? NSNumber)?.boolValue ?? false }
    }
    rebuild()
  }

  // MARK: - Views

  private func rebuild() {
    container?.removeFromSuperview()
    buttons.removeAll()

    let host: UIVisualEffectView
    if #available(iOS 26.0, *) {
      // Groups stay separate capsules, as Mail's do; the container is still
      // what lets glass flow as capsules appear and change.
      let effect = UIGlassContainerEffect()
      effect.spacing = 0
      host = UIVisualEffectView(effect: effect)
    } else {
      host = UIVisualEffectView(effect: nil)
    }
    host.frame = root.bounds
    host.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    root.addSubview(host)
    container = host

    let width = itemSize + inset * 2
    var y: CGFloat = 0
    var flat = 0
    for (g, items) in groups.enumerated() {
      let isProminent = g < prominent.count && prominent[g]
      let height = itemSize * CGFloat(items.count) + inset * 2
      let frame = CGRect(x: 0, y: y, width: width, height: height)

      let capsule: UIVisualEffectView
      if #available(iOS 26.0, *) {
        let glass = UIGlassEffect()
        glass.isInteractive = true
        if isProminent { glass.tintColor = tint }
        capsule = UIVisualEffectView(effect: glass)
        capsule.cornerConfiguration = .capsule()
      } else {
        capsule = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        capsule.layer.cornerRadius = width / 2
        capsule.clipsToBounds = true
        if isProminent { capsule.backgroundColor = tint }
      }
      capsule.frame = frame
      host.contentView.addSubview(capsule)

      for (k, item) in items.enumerated() {
        let index = flat
        let isSelected = tabMode && index == selected
        let cell = CGRect(
          x: inset, y: inset + CGFloat(k) * itemSize, width: itemSize, height: itemSize)

        if isSelected {
          // The selected tab's lozenge: a neutral fill on the glass, the colour
          // carried by the symbol — the system tab bar's look.
          let pill = UIView(frame: cell)
          pill.backgroundColor = UIColor.label.withAlphaComponent(0.1)
          pill.layer.cornerRadius = itemSize / 2
          pill.isUserInteractionEnabled = false
          capsule.contentView.addSubview(pill)
          self.pill = pill
          self.tabCapsule = capsule
          self.tabRange = (flat - k)..<(flat - k + items.count)
          // Sliding a finger along the bar moves the selection with it, and
          // lifting selects where it ended — the native tab bar's drag.
          let pan = UIPanGestureRecognizer(target: self, action: #selector(dragged(_:)))
          capsule.contentView.addGestureRecognizer(pan)
        }

        let button = UIButton(type: .system)
        button.frame = cell
        var config = UIButton.Configuration.plain()
        let base = item.image ?? item.symbol.flatMap {
          UIImage(systemName: $0)?.applyingSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        }
        config.image = base
        let fg: UIColor =
          isProminent ? .white : (tabMode ? (isSelected ? tint : .label) : tint)
        config.baseForegroundColor = fg
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in fg }
        config.contentInsets = .zero
        button.configuration = config
        button.accessibilityLabel = item.label
        button.tag = index
        if let menu = item.menu, !menu.isEmpty {
          button.menu = buildMenu(menu, index: index)
          button.showsMenuAsPrimaryAction = true
        } else {
          button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        }
        capsule.contentView.addSubview(button)
        buttons.append(button)

        if let badge = item.badge {
          capsule.contentView.addSubview(makeBadge(badge, in: cell))
        }
        flat += 1
      }
      y += height + gap
    }
  }

  private func makeBadge(_ text: String, in cell: CGRect) -> UIView {
    let trimmed = text.trimmingCharacters(in: .whitespaces)
    let label = UILabel()
    label.text = trimmed
    label.font = .systemFont(ofSize: 10, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    label.backgroundColor = .systemRed
    label.clipsToBounds = true
    label.isUserInteractionEnabled = false
    if trimmed.isEmpty {
      label.frame = CGRect(x: cell.maxX - 13, y: cell.minY + 6, width: 9, height: 9)
      label.layer.cornerRadius = 4.5
    } else {
      let w = max(16, label.intrinsicContentSize.width + 8)
      label.frame = CGRect(x: cell.maxX - w + 2, y: cell.minY + 2, width: w, height: 16)
      label.layer.cornerRadius = 8
    }
    return label
  }

  private func buildMenu(_ items: [[String: Any]], index: Int) -> UIMenu {
    var children: [UIMenuElement] = []
    for (i, m) in items.enumerated() {
      if (m["divider"] as? NSNumber)?.boolValue == true { continue }
      let title = (m["title"] as? String) ?? ""
      let image = (m["symbol"] as? String).flatMap { UIImage(systemName: $0) }
      let action = UIAction(title: title, image: image) { [weak self] _ in
        self?.channel.invokeMethod("menuSelected", arguments: ["index": index, "item": i])
      }
      if (m["destructive"] as? NSNumber)?.boolValue == true {
        action.attributes = .destructive
      }
      children.append(action)
    }
    return UIMenu(children: children)
  }

  @objc private func dragged(_ g: UIPanGestureRecognizer) {
    guard let pill = pill, let capsule = tabCapsule, !tabRange.isEmpty else { return }
    let count = tabRange.count
    let y = g.location(in: capsule).y - inset
    let slot = min(max(Int(floor(y / itemSize)), 0), count - 1)
    switch g.state {
    case .began, .changed:
      let centre = min(max(y, itemSize / 2), itemSize * CGFloat(count) - itemSize / 2)
      UIView.animate(withDuration: 0.12) {
        pill.center = CGPoint(x: self.inset + self.itemSize / 2, y: self.inset + centre)
        pill.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
      }
    case .ended:
      let index = tabRange.lowerBound + slot
      UIView.animate(
        withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0
      ) {
        pill.transform = .identity
        pill.frame = CGRect(
          x: self.inset, y: self.inset + CGFloat(slot) * self.itemSize,
          width: self.itemSize, height: self.itemSize)
      }
      UISelectionFeedbackGenerator().selectionChanged()
      channel.invokeMethod("pressed", arguments: ["index": index])
    default:
      UIView.animate(withDuration: 0.2) { pill.transform = .identity }
    }
  }

  @objc private func tapped(_ sender: UIButton) {
    channel.invokeMethod("pressed", arguments: ["index": sender.tag])
  }

  // MARK: - Helpers

  private static func draw(_ source: UIImage, side: CGFloat) -> UIImage {
    let aspect = source.size.height > 0 ? source.size.width / source.size.height : 1
    let size =
      aspect >= 1
      ? CGSize(width: side, height: side / aspect)
      : CGSize(width: side * aspect, height: side)
    return UIGraphicsImageRenderer(size: size).image { _ in
      source.draw(in: CGRect(origin: .zero, size: size))
    }
  }

  private static func color(_ argb: Int) -> UIColor {
    UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255, green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255, alpha: CGFloat((argb >> 24) & 0xFF) / 255)
  }
}
