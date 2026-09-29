import FlutterMacOS
import Cocoa

// The macOS counterpart of the iOS CNNavigationBar platform view.
//
// It reads the same creation params and answers the same channel methods as
// the iOS bar (setActions, setSegments, setBadges, setTitle, setStyle,
// setBrightness), and reports taps with the same indices, so the Dart widget
// needs no macOS branch. The look is a Mac toolbar rather than an iOS bar:
// icon buttons grouped in capsules, a hover highlight, menus as NSMenus, and
// the segmented control centred.

// MARK: - Params

/// One side's actions, read from the parallel `<side>Icons`, `<side>Labels`…
/// lists the Dart side sends. Index i here is index i of the Dart action
/// list, spacers included, which is what taps report back.
private struct BarActions {
  var icons: [String] = []
  var labels: [String] = []
  var paddings: [Double] = []
  var labelSizes: [Double] = []
  var iconSizes: [Double] = []
  var spacers: [String] = []
  var tints: [Int] = []
  var badgeValues: [String] = []
  var badgeColors: [Int] = []
  var imageAssets: [String] = []
  var popupMenus: [[[String: Any]]?] = []

  init(from d: [String: Any], prefix p: String) {
    icons = (d["\(p)Icons"] as? [String]) ?? []
    labels = (d["\(p)Labels"] as? [String]) ?? []
    paddings = Self.doubles(d["\(p)Paddings"])
    labelSizes = Self.doubles(d["\(p)LabelSizes"])
    iconSizes = Self.doubles(d["\(p)IconSizes"])
    spacers = (d["\(p)Spacers"] as? [String]) ?? []
    tints = ((d["\(p)Tints"] as? [NSNumber]) ?? []).map { $0.intValue }
    badgeValues = (d["\(p)BadgeValues"] as? [String]) ?? []
    badgeColors = ((d["\(p)BadgeColors"] as? [NSNumber]) ?? []).map { $0.intValue }
    imageAssets = (d["\(p)ImageAssets"] as? [String]) ?? []
    popupMenus = ((d["\(p)PopupMenus"] as? [Any]) ?? []).map { $0 as? [[String: Any]] }
  }

  var count: Int { max(icons.count, labels.count, spacers.count) }

  func spacer(_ i: Int) -> String { i < spacers.count ? spacers[i] : "" }
  func icon(_ i: Int) -> String { i < icons.count ? icons[i] : "" }
  func label(_ i: Int) -> String { i < labels.count ? labels[i] : "" }
  func asset(_ i: Int) -> String { i < imageAssets.count ? imageAssets[i] : "" }
  func padding(_ i: Int) -> CGFloat { i < paddings.count ? CGFloat(paddings[i]) : 0 }
  func labelSize(_ i: Int) -> CGFloat { i < labelSizes.count ? CGFloat(labelSizes[i]) : 0 }
  func iconSize(_ i: Int) -> CGFloat { i < iconSizes.count ? CGFloat(iconSizes[i]) : 0 }
  func tint(_ i: Int) -> Int { i < tints.count ? tints[i] : 0 }
  func menu(_ i: Int) -> [[String: Any]]? { i < popupMenus.count ? popupMenus[i] : nil }
  func badge(_ i: Int) -> String { i < badgeValues.count ? badgeValues[i] : "" }
  func badgeColor(_ i: Int) -> Int { i < badgeColors.count ? badgeColors[i] : 0 }

  private static func doubles(_ v: Any?) -> [Double] {
    ((v as? [NSNumber]) ?? []).map { $0.doubleValue }
  }
}

private func colorFromARGB(_ argb: Int) -> NSColor {
  let a = CGFloat((argb >> 24) & 0xFF) / 255.0
  let r = CGFloat((argb >> 16) & 0xFF) / 255.0
  let g = CGFloat((argb >> 8) & 0xFF) / 255.0
  let b = CGFloat(argb & 0xFF) / 255.0
  return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
}

private func optionalColor(_ v: Any?) -> NSColor? {
  guard let n = v as? NSNumber, n.intValue != 0 else { return nil }
  return colorFromARGB(n.intValue)
}

// MARK: - Pieces

/// A capsule behind a run of buttons, like a Mac toolbar item group. Its fill
/// follows the view's appearance, so it is resolved in updateLayer.
private final class NavPillView: NSView {
  override init(frame: NSRect) {
    super.init(frame: frame)
    wantsLayer = true
  }
  required init?(coder: NSCoder) { return nil }
  override var wantsUpdateLayer: Bool { true }
  override func updateLayer() {
    effectiveAppearance.performAsCurrentDrawingAppearance {
      layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.08).cgColor
      layer?.borderColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
    }
    layer?.borderWidth = 0.5
    layer?.cornerRadius = bounds.height / 2
  }
  override func layout() {
    super.layout()
    layer?.cornerRadius = bounds.height / 2
  }
}

/// A borderless bar button with a hover highlight and a press dip. Takes the
/// first click even when the window isn't key, as toolbar buttons do.
private final class NavBarButton: NSButton {
  var menuItems: [[String: Any]]?
  private var tracking: NSTrackingArea?
  private var hovering = false { didSet { updateHover() } }
  private var badgeView: NSTextField?

  override init(frame: NSRect) {
    super.init(frame: frame)
    isBordered = false
    bezelStyle = .regularSquare
    setButtonType(.momentaryChange)
    wantsLayer = true
    layer?.cornerRadius = 14
    focusRingType = .none
  }
  required init?(coder: NSCoder) { return nil }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let t = tracking { removeTrackingArea(t) }
    let t = NSTrackingArea(
      rect: bounds,
      options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
      owner: self, userInfo: nil)
    addTrackingArea(t)
    tracking = t
  }

  override func mouseEntered(with event: NSEvent) { hovering = true }
  override func mouseExited(with event: NSEvent) { hovering = false }

  override func mouseDown(with event: NSEvent) {
    alphaValue = 0.55
    super.mouseDown(with: event)  // returns once the mouse is released
    alphaValue = 1.0
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateHover()
  }

  private func updateHover() {
    effectiveAppearance.performAsCurrentDrawingAppearance {
      layer?.backgroundColor = hovering
        ? NSColor.labelColor.withAlphaComponent(0.10).cgColor
        : NSColor.clear.cgColor
    }
  }

  override func layout() {
    super.layout()
    layer?.cornerRadius = min(bounds.height, bounds.width) / 2
    layoutBadge()
  }

  /// A small count capsule on the top-right corner; empty removes it.
  func setBadge(_ value: String, color: NSColor?) {
    guard !value.isEmpty else {
      badgeView?.removeFromSuperview()
      badgeView = nil
      return
    }
    let badge = badgeView ?? {
      let b = NSTextField(labelWithString: "")
      b.font = NSFont.systemFont(ofSize: 9, weight: .bold)
      b.alignment = .center
      b.textColor = .white
      b.wantsLayer = true
      b.layer?.masksToBounds = true
      addSubview(b)
      badgeView = b
      return b
    }()
    badge.stringValue = value
    badge.layer?.backgroundColor = (color ?? .systemRed).cgColor
    layoutBadge()
  }

  private func layoutBadge() {
    guard let b = badgeView else { return }
    let h: CGFloat = 14
    let w = max(h, b.intrinsicContentSize.width + 6)
    // NSButton is flipped: y = 0 is the top edge.
    b.frame = NSRect(x: bounds.width - w + 3, y: -2, width: w, height: h)
    b.layer?.cornerRadius = h / 2
  }
}

/// A capsule segmented control in the app's own colours. NSSegmentedControl
/// can't take a track colour or per-state label colours, which the apps set
/// on every bar, so this draws its own: a track, a thumb behind the selected
/// segment, and a borderless button per label.
private final class NavSegmentedControl: NSView {
  var onChanged: ((Int) -> Void)?
  private var buttons: [NSButton] = []
  private let thumb = NSView()
  private var labels: [String] = []
  private(set) var selectedIndex = 0
  private var widths: [CGFloat] = []

  var height: CGFloat = 28
  var labelSize: CGFloat = 13
  var trackColor: NSColor?
  var thumbColor: NSColor?
  var labelColor: NSColor?
  var selectedLabelColor: NSColor?

  override var isFlipped: Bool { true }

  override init(frame: NSRect) {
    super.init(frame: frame)
    wantsLayer = true
    thumb.wantsLayer = true
    addSubview(thumb)
  }
  required init?(coder: NSCoder) { return nil }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

  func configure(labels: [String], selected: Int) {
    self.labels = labels
    selectedIndex = max(0, min(selected, labels.count - 1))
    buttons.forEach { $0.removeFromSuperview() }
    buttons = []
    let font = NSFont.systemFont(ofSize: labelSize, weight: .medium)
    widths = labels.map { ($0 as NSString).size(withAttributes: [.font: font]).width + 26 }
    for (i, label) in labels.enumerated() {
      let b = SegmentButton(frame: .zero)
      b.title = label
      b.tag = i
      b.target = self
      b.action = #selector(segmentTapped(_:))
      addSubview(b)
      buttons.append(b)
    }
    invalidateIntrinsicContentSize()
    refreshColors()
    needsLayout = true
  }

  func select(_ index: Int, animated: Bool) {
    guard index >= 0, index < labels.count, index != selectedIndex else { return }
    selectedIndex = index
    refreshColors()
    if animated {
      NSAnimationContext.runAnimationGroup { ctx in
        ctx.duration = 0.18
        ctx.allowsImplicitAnimation = true
        layoutThumb()
      }
    } else {
      layoutThumb()
    }
  }

  override var intrinsicContentSize: NSSize {
    NSSize(width: widths.reduce(0, +) + 4, height: height)
  }

  override func layout() {
    super.layout()
    layer?.cornerRadius = bounds.height / 2
    var x: CGFloat = 2
    for (i, b) in buttons.enumerated() {
      b.frame = NSRect(x: x, y: 2, width: widths[i], height: bounds.height - 4)
      x += widths[i]
    }
    layoutThumb()
  }

  private func layoutThumb() {
    guard selectedIndex < buttons.count else { thumb.isHidden = true; return }
    thumb.isHidden = false
    thumb.frame = buttons[selectedIndex].frame
    thumb.layer?.cornerRadius = thumb.frame.height / 2
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    refreshColors()
  }

  func refreshColors() {
    effectiveAppearance.performAsCurrentDrawingAppearance {
      layer?.backgroundColor =
        (trackColor ?? NSColor.labelColor.withAlphaComponent(0.08)).cgColor
      thumb.layer?.backgroundColor = (thumbColor ?? NSColor.controlAccentColor).cgColor
      let font = NSFont.systemFont(ofSize: labelSize, weight: .medium)
      let para = NSMutableParagraphStyle()
      para.alignment = .center
      for (i, b) in buttons.enumerated() {
        let color = i == selectedIndex
          ? (selectedLabelColor ?? .white)
          : (labelColor ?? .labelColor)
        b.attributedTitle = NSAttributedString(
          string: labels[i],
          attributes: [.font: font, .foregroundColor: color, .paragraphStyle: para])
      }
    }
  }

  @objc private func segmentTapped(_ sender: NSButton) {
    guard sender.tag != selectedIndex else { return }
    select(sender.tag, animated: true)
    onChanged?(sender.tag)
  }

  private final class SegmentButton: NSButton {
    override init(frame: NSRect) {
      super.init(frame: frame)
      isBordered = false
      bezelStyle = .regularSquare
      setButtonType(.momentaryChange)
      focusRingType = .none
    }
    required init?(coder: NSCoder) { return nil }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
  }
}

// MARK: - The bar

class CupertinoNavigationBarNSView: NSView {
  private let channel: FlutterMethodChannel
  private let registrar: FlutterPluginRegistrar
  private let background = NSVisualEffectView(frame: .zero)
  private let leadingStack = NSStackView()
  private let trailingStack = NSStackView()
  private let titleLabel = NSTextField(labelWithString: "")
  private var segmented: NavSegmentedControl?

  private var leadingButtons: [Int: NavBarButton] = [:]
  private var trailingButtons: [Int: NavBarButton] = [:]
  private var leadingMenus: [Int: [[String: Any]]] = [:]
  private var trailingMenus: [Int: [[String: Any]]] = [:]
  private var lastActionArgs: [String: Any] = [:]

  private var tint: NSColor?

  override var isFlipped: Bool { true }

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    super.init(frame: .zero)

    let d = (args as? [String: Any]) ?? [:]
    let isDark = (d["isDark"] as? NSNumber)?.boolValue ?? false
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    if let style = d["style"] as? [String: Any] { tint = optionalColor(style["tint"]) }

    wantsLayer = true
    background.translatesAutoresizingMaskIntoConstraints = false
    background.material = .headerView
    background.blendingMode = .withinWindow
    background.state = .followsWindowActiveState
    // Transparent bars let the Flutter content behind show through; the
    // button capsules carry their own fill so they stay readable.
    background.isHidden = (d["transparent"] as? NSNumber)?.boolValue ?? false
    addSubview(background)

    for s in [leadingStack, trailingStack] {
      s.orientation = .horizontal
      s.spacing = 8
      s.alignment = .centerY
      s.translatesAutoresizingMaskIntoConstraints = false
      s.setHuggingPriority(.required, for: .horizontal)
      s.setContentCompressionResistancePriority(.required, for: .horizontal)
      addSubview(s)
    }

    NSLayoutConstraint.activate([
      background.leadingAnchor.constraint(equalTo: leadingAnchor),
      background.trailingAnchor.constraint(equalTo: trailingAnchor),
      background.topAnchor.constraint(equalTo: topAnchor),
      background.bottomAnchor.constraint(equalTo: bottomAnchor),
      leadingStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      leadingStack.centerYAnchor.constraint(equalTo: centerYAnchor),
      trailingStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      trailingStack.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])

    let middle = BarActions(from: d, prefix: "middle")
    let segLabels = (d["segmentedControlLabels"] as? [String]) ?? []
    let hasSegments =
      ((d["hasSegmentedControl"] as? NSNumber)?.boolValue ?? false) && !segLabels.isEmpty

    if middle.count > 0 {
      let group = buildSide(middle, action: #selector(middleTapped(_:))).0
      placeCentered(group)
    } else if hasSegments {
      let seg = NavSegmentedControl(frame: .zero)
      seg.height = CGFloat((d["segmentedControlHeight"] as? NSNumber)?.doubleValue ?? 28)
      let ls = (d["segmentedControlLabelSize"] as? NSNumber)?.doubleValue ?? 0
      if ls > 0 { seg.labelSize = CGFloat(ls) }
      seg.trackColor = optionalColor(d["segmentedControlTint"])
      seg.thumbColor = optionalColor(d["segmentedControlSelectedColor"])
      seg.labelColor = optionalColor(d["segmentedControlLabelColor"])
      seg.selectedLabelColor = optionalColor(d["segmentedControlSelectedLabelColor"])
      seg.configure(
        labels: segLabels,
        selected: (d["segmentedControlSelectedIndex"] as? NSNumber)?.intValue ?? 0)
      seg.onChanged = { [weak self] i in
        self?.channel.invokeMethod("segmentedControlChanged", arguments: ["selectedIndex": i])
      }
      segmented = seg
      placeCentered(seg)
    } else {
      titleLabel.stringValue = (d["title"] as? String) ?? ""
      let size = (d["titleSize"] as? NSNumber)?.doubleValue ?? 0
      titleLabel.font = NSFont.systemFont(ofSize: size > 0 ? CGFloat(size) : 15, weight: .semibold)
      titleLabel.textColor = .labelColor
      titleLabel.lineBreakMode = .byTruncatingTail
      titleLabel.alignment = .center
      if (d["titleClickable"] as? NSNumber)?.boolValue ?? false {
        titleLabel.addGestureRecognizer(
          NSClickGestureRecognizer(target: self, action: #selector(titleTapped)))
      }
      placeCentered(titleLabel)
    }

    applyActions(d)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      let args = call.arguments as? [String: Any]
      switch call.method {
      case "getIntrinsicSize":
        result(["height": 52.0])
      case "setTitle":
        self.titleLabel.stringValue = (args?["title"] as? String) ?? ""
        result(nil)
      case "setStyle":
        if let args = args {
          if let t = optionalColor(args["tint"]) {
            self.tint = t
            self.applyActions(self.lastActionArgs)
          }
          if let t = args["transparent"] as? NSNumber {
            self.background.isHidden = t.boolValue
          }
        }
        result(nil)
      case "setSegments":
        if let labels = args?["labels"] as? [String] {
          self.segmented?.configure(
            labels: labels,
            selected: (args?["selectedIndex"] as? NSNumber)?.intValue ?? 0)
        }
        result(nil)
      case "setActions":
        if let args = args { self.applyActions(args) }
        result(nil)
      case "setBadges":
        if let args = args { self.applyBadges(args) }
        result(nil)
      case "setLargeTitleOffset":
        // No large titles on the Mac: the title stays in the bar.
        result(nil)
      case "setBrightness":
        if let dark = (args?["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
          self.segmented?.refreshColors()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  /// Centres [view] in the bar but never lets it run under either side.
  private func placeCentered(_ view: NSView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(view)
    let centre = view.centerXAnchor.constraint(equalTo: centerXAnchor)
    centre.priority = .defaultHigh
    NSLayoutConstraint.activate([
      centre,
      view.centerYAnchor.constraint(equalTo: centerYAnchor),
      view.leadingAnchor.constraint(
        greaterThanOrEqualTo: leadingStack.trailingAnchor, constant: 12),
      view.trailingAnchor.constraint(
        lessThanOrEqualTo: trailingStack.leadingAnchor, constant: -12),
    ])
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
  }

  // MARK: Actions

  /// (Re)builds both sides from the `<side>…` params — at creation and on
  /// every setActions, so actions that change after the first frame show up.
  private func applyActions(_ args: [String: Any]) {
    lastActionArgs = args
    let leading = BarActions(from: args, prefix: "leading")
    let trailing = BarActions(from: args, prefix: "trailing")

    leadingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    trailingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let l = buildSide(leading, action: #selector(leadingTapped(_:)))
    leadingButtons = l.1
    leadingMenus = menus(of: leading)
    leadingStack.addArrangedSubview(l.0)

    let t = buildSide(trailing, action: #selector(trailingTapped(_:)))
    trailingButtons = t.1
    trailingMenus = menus(of: trailing)
    trailingStack.addArrangedSubview(t.0)
  }

  private func menus(of actions: BarActions) -> [Int: [[String: Any]]] {
    var out: [Int: [[String: Any]]] = [:]
    for i in 0..<actions.count {
      if let m = actions.menu(i), !m.isEmpty { out[i] = m }
    }
    return out
  }

  /// One side: runs of buttons in capsules, split by spacers. Button tags are
  /// the Dart action indices.
  private func buildSide(_ actions: BarActions, action: Selector) -> (NSView, [Int: NavBarButton]) {
    let row = NSStackView()
    row.orientation = .horizontal
    row.spacing = 8
    row.alignment = .centerY
    var buttons: [Int: NavBarButton] = [:]
    var run: [NavBarButton] = []

    func closeRun() {
      guard !run.isEmpty else { return }
      let pill = NavPillView(frame: .zero)
      let inner = NSStackView(views: run)
      inner.orientation = .horizontal
      inner.spacing = 0
      inner.translatesAutoresizingMaskIntoConstraints = false
      pill.addSubview(inner)
      NSLayoutConstraint.activate([
        inner.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 3),
        inner.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -3),
        inner.topAnchor.constraint(equalTo: pill.topAnchor, constant: 3),
        inner.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -3),
      ])
      row.addArrangedSubview(pill)
      run = []
    }

    for i in 0..<actions.count {
      if !actions.spacer(i).isEmpty {
        closeRun()
        continue
      }
      let b = makeButton(actions, i)
      b.tag = i
      b.target = self
      b.action = action
      b.menuItems = actions.menu(i)
      b.setBadge(actions.badge(i), color: optionalColor(actions.badgeColor(i)))
      buttons[i] = b
      run.append(b)
    }
    closeRun()
    return (row, buttons)
  }

  private func makeButton(_ a: BarActions, _ i: Int) -> NavBarButton {
    let b = NavBarButton(frame: .zero)
    b.translatesAutoresizingMaskIntoConstraints = false
    let color = optionalColor(a.tint(i)) ?? tint ?? NSColor.labelColor
    b.contentTintColor = color

    var hasImage = false
    if !a.asset(i).isEmpty, let image = assetImage(a.asset(i)) {
      image.size = NSSize(width: 18, height: 18)
      b.image = image
      hasImage = true
    } else if !a.icon(i).isEmpty,
      let image = NSImage(systemSymbolName: a.icon(i), accessibilityDescription: a.label(i))
    {
      let size = a.iconSize(i) > 0 ? min(a.iconSize(i), 20) : 15
      b.image = image.withSymbolConfiguration(.init(pointSize: size, weight: .medium))
      hasImage = true
    }

    if hasImage {
      b.imagePosition = .imageOnly
      b.toolTip = a.label(i).isEmpty ? nil : a.label(i)
      NSLayoutConstraint.activate([
        b.widthAnchor.constraint(equalToConstant: 28 + a.padding(i) * 2),
        b.heightAnchor.constraint(equalToConstant: 28),
      ])
    } else {
      let font = NSFont.systemFont(ofSize: a.labelSize(i) > 0 ? a.labelSize(i) : 13, weight: .medium)
      b.attributedTitle = NSAttributedString(
        string: a.label(i), attributes: [.font: font, .foregroundColor: color])
      let w = (a.label(i) as NSString).size(withAttributes: [.font: font]).width
      NSLayoutConstraint.activate([
        b.widthAnchor.constraint(equalToConstant: w + 20 + a.padding(i) * 2),
        b.heightAnchor.constraint(equalToConstant: 28),
      ])
    }
    return b
  }

  private func assetImage(_ asset: String) -> NSImage? {
    let key = registrar.lookupKey(forAsset: asset)
    for bundle in [Bundle.main] + Bundle.allFrameworks {
      if let url = bundle.url(forResource: key, withExtension: nil),
        let image = NSImage(contentsOf: url)
      {
        return image
      }
    }
    return nil
  }

  private func applyBadges(_ args: [String: Any]) {
    func apply(_ buttons: [Int: NavBarButton], _ values: [String], _ colors: [NSNumber]) {
      for (i, b) in buttons where i < values.count {
        b.setBadge(values[i], color: i < colors.count ? optionalColor(colors[i]) : nil)
      }
    }
    apply(leadingButtons,
          (args["leadingBadgeValues"] as? [String]) ?? [],
          (args["leadingBadgeColors"] as? [NSNumber]) ?? [])
    apply(trailingButtons,
          (args["trailingBadgeValues"] as? [String]) ?? [],
          (args["trailingBadgeColors"] as? [NSNumber]) ?? [])
  }

  // MARK: Taps

  @objc private func leadingTapped(_ sender: NavBarButton) {
    if let items = leadingMenus[sender.tag] {
      showMenu(items, from: sender, location: "leading")
    } else {
      channel.invokeMethod("leadingTapped", arguments: ["index": sender.tag])
    }
  }

  @objc private func middleTapped(_ sender: NavBarButton) {
    channel.invokeMethod("middleTapped", arguments: ["index": sender.tag])
  }

  @objc private func trailingTapped(_ sender: NavBarButton) {
    if let items = trailingMenus[sender.tag] {
      showMenu(items, from: sender, location: "trailing")
    } else {
      channel.invokeMethod("trailingTapped", arguments: ["index": sender.tag])
    }
  }

  @objc private func titleTapped() {
    channel.invokeMethod("titleTapped", arguments: nil)
  }

  // MARK: Menus

  /// Builds an NSMenu from the serialized popup entries. Every entry —
  /// dividers and submenu parents included — takes one flat depth-first
  /// index, parent before children, matching the iOS bar and the Dart side.
  private func showMenu(_ items: [[String: Any]], from button: NSButton, location: String) {
    var flat = 0
    func build(_ entries: [[String: Any]]) -> NSMenu {
      let menu = NSMenu()
      menu.autoenablesItems = false
      for e in entries {
        let type = e["type"] as? String ?? "item"
        let label = e["label"] as? String ?? ""
        var image: NSImage? = nil
        if let name = e["icon"] as? String, !name.isEmpty {
          image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
        }
        switch type {
        case "divider":
          flat += 1
          menu.addItem(.separator())
        case "submenu":
          flat += 1
          let parent = NSMenuItem(title: label, action: nil, keyEquivalent: "")
          parent.image = image
          parent.submenu = build(e["children"] as? [[String: Any]] ?? [])
          menu.addItem(parent)
        default:
          let item = NSMenuItem(title: label, action: #selector(menuChosen(_:)), keyEquivalent: "")
          item.target = self
          item.image = image
          item.isEnabled = e["enabled"] as? Bool ?? true
          item.state = (e["selected"] as? Bool ?? false) ? .on : .off
          if #available(macOS 14.4, *), let sub = e["subtitle"] as? String, !sub.isEmpty {
            item.subtitle = sub
          }
          item.representedObject = [
            "location": location, "actionIndex": button.tag, "menuIndex": flat,
          ] as [String: Any]
          flat += 1
          menu.addItem(item)
        }
      }
      return menu
    }
    build(items).popUp(
      positioning: nil,
      at: NSPoint(x: 0, y: button.isFlipped ? button.bounds.height + 4 : -4),
      in: button)
  }

  @objc private func menuChosen(_ sender: NSMenuItem) {
    guard let info = sender.representedObject as? [String: Any] else { return }
    channel.invokeMethod("popupMenuSelected", arguments: info)
  }
}
