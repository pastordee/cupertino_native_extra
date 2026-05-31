import FlutterMacOS
import Cocoa
import ObjectiveC

// Custom NSButton with press animation effect
class AnimatedButton: NSButton {
  override func mouseDown(with event: NSEvent) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.1
      context.allowsImplicitAnimation = true
      self.alphaValue = 0.6
      self.layer?.transform = CATransform3DMakeScale(0.95, 0.95, 1.0)
    })
    super.mouseDown(with: event)
  }
  
  override func mouseUp(with event: NSEvent) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.15
      context.allowsImplicitAnimation = true
      self.alphaValue = 1.0
      self.layer?.transform = CATransform3DIdentity
    })
    super.mouseUp(with: event)
  }
}

class CupertinoNavigationBarNSView: NSView {
  private let channel: FlutterMethodChannel
  private let visualEffectView: NSVisualEffectView
  private let titleLabel: NSTextField
  private var leadingButtons: [NSButton] = []
  private var middleButtons: [NSButton] = []
  private var trailingButtons: [NSButton] = []
  private var currentTitle: String = ""
  private var currentTint: NSColor? = nil
  private var isTransparent: Bool = false
  private let registrar: FlutterPluginRegistrar

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    self.channel = FlutterMethodChannel(name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    self.visualEffectView = NSVisualEffectView(frame: .zero)
    self.titleLabel = NSTextField(labelWithString: "")

    var title: String = ""
    var leadingIcons: [String] = []
    var leadingLabels: [String] = []
    var leadingPaddings: [Double] = []
    var leadingSpacers: [String] = []
    var leadingTints: [Int] = []
    var leadingImageAssets: [String] = []
    var middleIcons: [String] = []
    var middleLabels: [String] = []
    var middlePaddings: [Double] = []
    var middleSpacers: [String] = []
    var middleTints: [Int] = []
    var trailingIcons: [String] = []
    var trailingLabels: [String] = []
    var trailingPaddings: [Double] = []
    var trailingSpacers: [String] = []
    var trailingTints: [Int] = []
    var trailingImageAssets: [String] = []
    var transparent: Bool = false
    var isDark: Bool = false
    var tint: NSColor? = nil
    var pillHeight: Double? = nil
    var middleAlignment: String = "center"

    if let dict = args as? [String: Any] {
      title = (dict["title"] as? String) ?? ""
      leadingIcons = (dict["leadingIcons"] as? [String]) ?? []
      leadingLabels = (dict["leadingLabels"] as? [String]) ?? []
      leadingPaddings = (dict["leadingPaddings"] as? [Double]) ?? []
      leadingSpacers = (dict["leadingSpacers"] as? [String]) ?? []
      leadingTints = (dict["leadingTints"] as? [Int]) ?? []
      leadingImageAssets = (dict["leadingImageAssets"] as? [String]) ?? []
      middleIcons = (dict["middleIcons"] as? [String]) ?? []
      middleLabels = (dict["middleLabels"] as? [String]) ?? []
      middlePaddings = (dict["middlePaddings"] as? [Double]) ?? []
      middleSpacers = (dict["middleSpacers"] as? [String]) ?? []
      middleTints = (dict["middleTints"] as? [Int]) ?? []
      trailingIcons = (dict["trailingIcons"] as? [String]) ?? []
      trailingLabels = (dict["trailingLabels"] as? [String]) ?? []
      trailingPaddings = (dict["trailingPaddings"] as? [Double]) ?? []
      trailingSpacers = (dict["trailingSpacers"] as? [String]) ?? []
      trailingTints = (dict["trailingTints"] as? [Int]) ?? []
      trailingImageAssets = (dict["trailingImageAssets"] as? [String]) ?? []
      pillHeight = dict["pillHeight"] as? Double
      middleAlignment = (dict["middleAlignment"] as? String) ?? "center"
      if let v = dict["transparent"] as? NSNumber { transparent = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber {
        tint = Self.colorFromARGB(n.intValue)
      }
    }

    super.init(frame: .zero)

    wantsLayer = true
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    // Configure visual effect view for translucent blur
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    if transparent {
      // Use ultra-thin material for more visible liquid glass effect
      visualEffectView.material = .underWindowBackground
      visualEffectView.blendingMode = .behindWindow
    } else {
      visualEffectView.material = .headerView
      visualEffectView.blendingMode = .withinWindow
    }
    visualEffectView.state = .active
    addSubview(visualEffectView)

    currentTitle = title
    currentTint = tint
    isTransparent = transparent

    // Create all button groups first
    var leadingButtonGroup: NSView?
    var middleButtonGroup: NSView?
    var trailingButtonGroup: NSView?
    
    // Leading buttons
    if !leadingIcons.isEmpty || !leadingLabels.isEmpty {
      leadingButtonGroup = createButtonGroup(
        icons: leadingIcons,
        labels: leadingLabels,
        paddings: leadingPaddings,
        imageAssets: leadingImageAssets,
        pillHeight: pillHeight,
        tint: tint,
        tints: leadingTints,
        target: self,
        action: #selector(leadingTapped(_:))
      )
      visualEffectView.addSubview(leadingButtonGroup!)
      
      NSLayoutConstraint.activate([
        leadingButtonGroup!.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 8),
        leadingButtonGroup!.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
      ])
      
      if let stackView = leadingButtonGroup!.subviews.first(where: { $0 is NSStackView }) as? NSStackView {
        leadingButtons = stackView.arrangedSubviews.compactMap { $0 as? NSButton }
      }
    }
    
    // Trailing buttons
    if !trailingIcons.isEmpty || !trailingLabels.isEmpty {
      trailingButtonGroup = createButtonGroup(
        icons: trailingIcons,
        labels: trailingLabels,
        paddings: trailingPaddings,
        imageAssets: trailingImageAssets,
        pillHeight: pillHeight,
        tint: tint,
        tints: trailingTints,
        target: self,
        action: #selector(trailingTapped(_:))
      )
      visualEffectView.addSubview(trailingButtonGroup!)
      
      NSLayoutConstraint.activate([
        trailingButtonGroup!.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -8),
        trailingButtonGroup!.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
      ])
      
      if let stackView = trailingButtonGroup!.subviews.first(where: { $0 is NSStackView }) as? NSStackView {
        trailingButtons = stackView.arrangedSubviews.compactMap { $0 as? NSButton }
      }
    }

    // Title label or middle button group (mutually exclusive)
    if !middleIcons.isEmpty || !middleLabels.isEmpty {
      // Middle button group with alignment control
      middleButtonGroup = createButtonGroup(
        icons: middleIcons,
        labels: middleLabels,
        paddings: middlePaddings,
        pillHeight: pillHeight,
        tint: tint,
        tints: middleTints,
        target: self,
        action: #selector(middleTapped(_:))
      )
      visualEffectView.addSubview(middleButtonGroup!)
      
      let hasLeading = leadingButtonGroup != nil
      let hasTrailing = trailingButtonGroup != nil
      
      // Apply alignment constraints based on middleAlignment parameter
      if middleAlignment == "leading" && hasLeading {
        // Position right after leading buttons (only if leading exists)
        NSLayoutConstraint.activate([
          middleButtonGroup!.leadingAnchor.constraint(equalTo: leadingButtonGroup!.trailingAnchor, constant: 8),
          middleButtonGroup!.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
        ])
      } else if middleAlignment == "trailing" && hasTrailing {
        // Position right before trailing buttons (only if trailing exists)
        NSLayoutConstraint.activate([
          middleButtonGroup!.trailingAnchor.constraint(equalTo: trailingButtonGroup!.leadingAnchor, constant: -8),
          middleButtonGroup!.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
        ])
      } else {
        // Center alignment (default)
        // Also use center if alignment is leading/trailing but no leading/trailing exists
        NSLayoutConstraint.activate([
          middleButtonGroup!.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
          middleButtonGroup!.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
        ])
      }
      
      if let stackView = middleButtonGroup!.subviews.first(where: { $0 is NSStackView }) as? NSStackView {
        middleButtons = stackView.arrangedSubviews.compactMap { $0 as? NSButton }
      }
    } else {
      // Use title label
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.stringValue = title
      titleLabel.isEditable = false
      titleLabel.isBordered = false
      titleLabel.backgroundColor = .clear
      titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
      titleLabel.alignment = .center
      if let tintColor = tint {
        titleLabel.textColor = tintColor
      }
      visualEffectView.addSubview(titleLabel)
    }

    // Layout constraints
    NSLayoutConstraint.activate([
      visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      visualEffectView.topAnchor.constraint(equalTo: topAnchor),
      visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      titleLabel.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        result(["height": 52.0]) // Standard macOS toolbar height
      case "setTitle":
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
          self.titleLabel.stringValue = title
          self.currentTitle = title
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            let tintColor = Self.colorFromARGB(n.intValue)
            self.titleLabel.textColor = tintColor
            self.leadingButtons.forEach { $0.contentTintColor = tintColor }
            self.trailingButtons.forEach { $0.contentTintColor = tintColor }
            self.currentTint = tintColor
          }
          if let t = args["transparent"] as? NSNumber {
            self.isTransparent = t.boolValue
            if self.isTransparent {
              self.visualEffectView.material = .clear
              self.visualEffectView.blendingMode = .behindWindow
            } else {
              self.visualEffectView.material = .headerView
              self.visualEffectView.blendingMode = .withinWindow
            }
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  @objc private func leadingTapped(_ sender: NSButton) {
    channel.invokeMethod("leadingTapped", arguments: ["index": sender.tag])
  }

  @objc private func middleTapped(_ sender: NSButton) {
    channel.invokeMethod("middleTapped", arguments: ["index": sender.tag])
  }

  @objc private func trailingTapped(_ sender: NSButton) {
    channel.invokeMethod("trailingTapped", arguments: ["index": sender.tag])
  }
  
  private func createButtonGroup(
    icons: [String],
    labels: [String],
    paddings: [Double],
    imageAssets: [String] = [],
    pillHeight: Double?,
    tint: NSColor?,
    tints: [Int] = [],
    target: Any?,
    action: Selector
  ) -> NSView {
    let count = max(icons.count, labels.count)
    if count == 0 { return NSView(frame: .zero) }
    
    // Use custom pill height if provided, otherwise calculate from padding
    let customHeight = pillHeight != nil ? CGFloat(pillHeight!) : nil
    
    // Calculate widths and paddings
    var buttonWidths: [CGFloat] = []
    var buttonPaddings: [NSEdgeInsets] = []
    let defaultWidth: CGFloat = 28
    let defaultHeight: CGFloat = 24
    
    for i in 0..<count {
      let padding = i < paddings.count ? CGFloat(paddings[i]) : 0
      buttonWidths.append(defaultWidth + padding * 2)
      buttonPaddings.append(NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
    
    let totalWidth = buttonWidths.reduce(0, +) + 8  // +8 for container padding
    
    // Calculate the blur view height - use custom height if provided, otherwise calculate from padding
    let blurViewHeight: CGFloat
    if let customHeight = customHeight {
      blurViewHeight = customHeight
    } else {
      let maxPadding = buttonPaddings.map { $0.top + $0.bottom }.max() ?? 0
      blurViewHeight = defaultHeight + maxPadding + 8  // +8 for container padding
    }
    
    // Create pill background view - all pills are identical and transparent
    let pillView = NSView(frame: .zero)
    pillView.wantsLayer = true
    pillView.layer?.backgroundColor = NSColor.clear.cgColor
    pillView.layer?.cornerRadius = blurViewHeight / 2
    pillView.layer?.masksToBounds = true
    
    pillView.translatesAutoresizingMaskIntoConstraints = false
    
    // Create a container view to hold both pill background and content
    let containerView = NSView()
    containerView.wantsLayer = false
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(pillView)
    
    // Selection indicator removed
    
    // Create stack view for buttons
    let stackView = NSStackView()
    stackView.orientation = .horizontal
    stackView.spacing = 0
    stackView.distribution = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Create buttons
    var buttons: [NSButton] = []
    for i in 0..<count {
      let button = NSButton(frame: .zero)
      button.tag = i
      button.target = target
      button.action = action
      button.bezelStyle = .texturedRounded
      button.isBordered = false
      
      if i < imageAssets.count, !imageAssets[i].isEmpty {
        let key = registrar.lookupKey(forAsset: imageAssets[i])
        if let url = Bundle.main.url(forResource: key, withExtension: nil),
           let image = NSImage(contentsOf: url) {
          image.size = NSSize(width: 16, height: 16)
          button.image = image
          button.imagePosition = .imageOnly
        }
      } else if #available(macOS 11.0, *), i < icons.count, !icons[i].isEmpty,
         let image = NSImage(systemSymbolName: icons[i], accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        button.image = image.withSymbolConfiguration(config)
        button.imagePosition = .imageOnly
      } else if i < labels.count, !labels[i].isEmpty {
        button.title = labels[i]
      }
      
      // Apply individual tint color if available, otherwise use global tint
      if i < tints.count && tints[i] != 0 {
        button.contentTintColor = NSColor(argb: tints[i])
      } else if let tintColor = tint {
        button.contentTintColor = tintColor
      }
      
      // Ensure button has no background - only the pill blur view should show
      button.wantsLayer = true
      button.layer?.backgroundColor = NSColor.clear.cgColor
      
      // For NSButton, padding affects the overall button size
      // NSButton doesn't have contentEdgeInsets like UIButton
      
      button.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(button)
      buttons.append(button)
      
      // Calculate button height - use custom height if provided, otherwise use default + padding
      let buttonHeight: CGFloat
      if let customHeight = customHeight {
        // Subtract container padding to fit within blur view
        buttonHeight = customHeight - 8
      } else {
        buttonHeight = defaultHeight + buttonPaddings[i].top + buttonPaddings[i].bottom
      }
      
      NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: buttonWidths[i]),
        button.heightAnchor.constraint(equalToConstant: buttonHeight),
      ])
    }
    
    containerView.addSubview(stackView)  // Add to container, not blurView
    
    // Store button references (selection view removed)
    objc_setAssociatedObject(containerView, "buttons", buttons, .OBJC_ASSOCIATION_RETAIN)
    objc_setAssociatedObject(containerView, "buttonWidths", buttonWidths, .OBJC_ASSOCIATION_RETAIN)
    
    NSLayoutConstraint.activate([
      // Pill view fills the container
      pillView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      pillView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      pillView.topAnchor.constraint(equalTo: containerView.topAnchor),
      pillView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      // Stack view positioned within container with padding
      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
      stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
      stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
      
      // Container size
      containerView.heightAnchor.constraint(equalToConstant: blurViewHeight),
      containerView.widthAnchor.constraint(equalToConstant: totalWidth),
    ])
    
    // Mouse tracking removed - no selection highlighting
    
    // Wrap in a centering container for vertical centering in toolbar
    let wrapperView = NSView()
    wrapperView.translatesAutoresizingMaskIntoConstraints = false
    wrapperView.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
      containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
      containerView.topAnchor.constraint(greaterThanOrEqualTo: wrapperView.topAnchor),
      containerView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor),
    ])
    
    return wrapperView  // Return wrapper for proper vertical centering
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}
