import Flutter
import UIKit

class CupertinoPullDownButtonPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let button: UIButton
  private var currentButtonStyle: String = "automatic"
  private var isRoundButton: Bool = false
  private var labels: [String] = []
  private var symbols: [String] = []
  private var dividers: [Bool] = []
  private var enabled: [Bool] = []
  private var itemSizes: [NSNumber] = []
  private var itemColors: [NSNumber] = []
  private var itemModes: [String?] = []
  private var itemPalettes: [[NSNumber]] = []
  private var itemGradients: [NSNumber?] = []
  private var subtitles: [String?] = []
  private var hasNavigation: [Bool] = []
  private var submenuItemCounts: [Int] = []
  // Track current button icon configuration
  private var btnIconName: String? = nil
  private var btnIconSize: CGFloat? = nil
  private var btnIconColor: UIColor? = nil
  private var btnIconMode: String? = nil
  private var btnIconPalette: [UIColor] = []
  // Inline actions
  private var inlineActionLabels: [String] = []
  private var inlineActionSymbols: [String] = []
  private var inlineActionEnabled: [Bool] = []
  private var inlineActionSizes: [NSNumber] = []
  private var inlineActionColors: [NSNumber] = []
  private var inlineActionModes: [String?] = []
  private var inlineActionPalettes: [[NSNumber]] = []
  private var inlineActionGradients: [NSNumber?] = []

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePullDownButton_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.button = UIButton(type: .system)

    var title: String? = nil
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: UIColor? = nil
    var makeRound: Bool = false
    var isDark: Bool = false
    var tint: UIColor? = nil
    var buttonStyle: String = "automatic"
    var labels: [String] = []
    var symbols: [String] = []
    var dividers: [NSNumber] = []
    var enabled: [NSNumber] = []
    var sizes: [NSNumber] = []
    var colors: [NSNumber] = []
    var buttonIconMode: String? = nil
    var buttonIconPalette: [NSNumber] = []

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber { makeRound = r.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      dividers = (dict["isDivider"] as? [NSNumber]) ?? []
      enabled = (dict["enabled"] as? [NSNumber]) ?? []
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      colors = (dict["sfSymbolColors"] as? [NSNumber]) ?? []
      if let modes = dict["sfSymbolRenderingModes"] as? [String?] { self.itemModes = modes }
      if let palettes = dict["sfSymbolPaletteColors"] as? [[NSNumber]] { self.itemPalettes = palettes }
      if let gradients = dict["sfSymbolGradientEnabled"] as? [NSNumber?] { self.itemGradients = gradients }
      if let subs = dict["subtitles"] as? [String?] { self.subtitles = subs }
      if let navs = dict["hasNavigation"] as? [NSNumber] { self.hasNavigation = navs.map { $0.boolValue } }
      if let counts = dict["submenuItemCounts"] as? [NSNumber] { self.submenuItemCounts = counts.map { $0.intValue } }
      if let m = dict["buttonIconRenderingMode"] as? String { buttonIconMode = m }
      if let pal = dict["buttonIconPaletteColors"] as? [NSNumber] { buttonIconPalette = pal }
      // Inline actions
      if let inlineLabels = dict["inlineActionLabels"] as? [String] { self.inlineActionLabels = inlineLabels }
      if let inlineSymbols = dict["inlineActionSymbols"] as? [String] { self.inlineActionSymbols = inlineSymbols }
      if let inlineEnabled = dict["inlineActionEnabled"] as? [NSNumber] { self.inlineActionEnabled = inlineEnabled.map { $0.boolValue } }
      if let inlineSizes = dict["inlineActionSizes"] as? [NSNumber] { self.inlineActionSizes = inlineSizes }
      if let inlineColors = dict["inlineActionColors"] as? [NSNumber] { self.inlineActionColors = inlineColors }
      if let inlineModes = dict["inlineActionModes"] as? [String?] { self.inlineActionModes = inlineModes }
      if let inlinePalettes = dict["inlineActionPaletteColors"] as? [[NSNumber]] { self.inlineActionPalettes = inlinePalettes }
      if let inlineGradients = dict["inlineActionGradientEnabled"] as? [NSNumber?] { self.inlineActionGradients = inlineGradients }
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) { container.overrideUserInterfaceStyle = isDark ? .dark : .light }

    button.translatesAutoresizingMaskIntoConstraints = false
    // Choose a visible default tint if none provided
    if let t = tint { button.tintColor = t }
    else if #available(iOS 13.0, *) { button.tintColor = .label }

    // Add button and pin to container
    container.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      button.topAnchor.constraint(equalTo: container.topAnchor),
      button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    // Store
    self.labels = labels
    self.symbols = symbols
    self.dividers = dividers.map { $0.boolValue }
    self.enabled = enabled.map { $0.boolValue }

    self.isRoundButton = makeRound
    applyButtonStyle(buttonStyle: buttonStyle, round: makeRound)
    currentButtonStyle = buttonStyle
    
    // Cache current icon props
    self.btnIconName = iconName
    self.btnIconSize = iconSize
    self.btnIconColor = iconColor
    self.btnIconMode = buttonIconMode
    if !buttonIconPalette.isEmpty { self.btnIconPalette = buttonIconPalette.map { Self.colorFromARGB($0.intValue) } }
    
    // Apply content initially
    setButtonContent(title: title, image: makeButtonIconImage(), iconOnly: (title == nil))
    if #available(iOS 15.0, *), var cfg = button.configuration {
      if let symCfg = makeButtonSymbolConfiguration() {
        cfg.preferredSymbolConfigurationForImage = symCfg
      } else if let t = tint, btnIconColor == nil, btnIconMode == nil {
        cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(hierarchicalColor: t)
      }
      button.configuration = cfg
    }

    // Ensure the image persists across configuration state changes
    if #available(iOS 15.0, *) {
      button.configurationUpdateHandler = { [weak self] btn in
        guard let self = self else { return }
        var cfg = btn.configuration ?? .plain()
        cfg.image = self.makeButtonIconImage()
        cfg.preferredSymbolConfigurationForImage = self.makeButtonSymbolConfiguration()
        btn.configuration = cfg
      }
    }

    self.itemSizes = sizes
    self.itemColors = colors
    rebuildMenu(defaultSizes: sizes, defaultColors: colors)
    
    // IMPORTANT: For pull-down buttons, we use showsMenuAsPrimaryAction = true
    // This makes the menu appear on touch down (pull-down behavior) instead of long press
    if #available(iOS 14.0, *) {
      button.showsMenuAsPrimaryAction = true
    } else {
      button.addTarget(self, action: #selector(onButtonPressedLegacy(_:)), for: .touchUpInside)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.button.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setItems":
        if let args = call.arguments as? [String: Any] {
          self.labels = (args["labels"] as? [String]) ?? []
          self.symbols = (args["sfSymbols"] as? [String]) ?? []
          self.dividers = ((args["isDivider"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.enabled = ((args["enabled"] as? [NSNumber]) ?? []).map { $0.boolValue }
          let sizes = (args["sfSymbolSizes"] as? [NSNumber]) ?? []
          let colors = (args["sfSymbolColors"] as? [NSNumber]) ?? []
          self.itemSizes = sizes
          self.itemColors = colors
          self.itemModes = (args["sfSymbolRenderingModes"] as? [String?]) ?? []
          self.itemPalettes = (args["sfSymbolPaletteColors"] as? [[NSNumber]]) ?? []
          self.itemGradients = (args["sfSymbolGradientEnabled"] as? [NSNumber?]) ?? []
          self.subtitles = (args["subtitles"] as? [String?]) ?? []
          self.hasNavigation = ((args["hasNavigation"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.submenuItemCounts = ((args["submenuItemCounts"] as? [NSNumber]) ?? []).map { $0.intValue }
          self.rebuildMenu(defaultSizes: sizes, defaultColors: colors)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing items", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            self.button.tintColor = Self.colorFromARGB(n.intValue)
            self.applyButtonStyle(buttonStyle: self.currentButtonStyle, round: self.isRoundButton)
            if #available(iOS 15.0, *), self.btnIconColor == nil, self.btnIconMode == nil, let tint = self.button.tintColor, var cfg = self.button.configuration {
              cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(hierarchicalColor: tint)
              self.button.configuration = cfg
            }
          }
          if let bs = args["buttonStyle"] as? String {
            self.currentButtonStyle = bs
            self.applyButtonStyle(buttonStyle: bs, round: self.isRoundButton)
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          if let name = args["buttonIconName"] as? String { self.btnIconName = name }
          if let s = args["buttonIconSize"] as? NSNumber { self.btnIconSize = CGFloat(truncating: s) }
          if let c = args["buttonIconColor"] as? NSNumber { self.btnIconColor = Self.colorFromARGB(c.intValue) }
          if let m = args["buttonIconRenderingMode"] as? String { self.btnIconMode = m }
          if let pal = args["buttonIconPaletteColors"] as? [NSNumber] { self.btnIconPalette = pal.map { Self.colorFromARGB($0.intValue) } }
          self.setButtonContent(title: nil, image: self.makeButtonIconImage(), iconOnly: true)
          if #available(iOS 15.0, *), var cfg = self.button.configuration {
            if let symCfg = self.makeButtonSymbolConfiguration() {
              cfg.preferredSymbolConfigurationForImage = symCfg
            } else if self.btnIconColor == nil, self.btnIconMode == nil, let tint = self.button.tintColor {
              cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(hierarchicalColor: tint)
            }
            self.button.configuration = cfg
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) { self.container.overrideUserInterfaceStyle = isDark ? .dark : .light }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.button.setTitle(t, for: .normal)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setPressed":
        if let args = call.arguments as? [String: Any], let p = args["pressed"] as? NSNumber {
          self.button.isHighlighted = p.boolValue
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing pressed", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  private func rebuildMenu(defaultSizes: [NSNumber]? = nil, defaultColors: [NSNumber]? = nil) {
    // iOS 14+ native menu with pull-down behavior
    if #available(iOS 14.0, *) {
      var groups: [[UIMenuElement]] = []
      var current: [UIMenuElement] = []
      let count = max(labels.count, max(symbols.count, dividers.count))
      let flushGroup: () -> Void = {
        if !current.isEmpty { groups.append(current); current = [] }
      }
      
      // Build inline actions section first (appears at top as horizontal buttons)
      // iOS 16+ supports horizontal layout with preferredElementSize
      // iOS 15 will show them vertically but still inline
      if #available(iOS 16.0, *), !inlineActionLabels.isEmpty {
        var inlineActions: [UIMenuElement] = []
        for i in 0..<inlineActionLabels.count {
          // Use subtitle for the label text - iOS displays these horizontally
          let subtitle = i < inlineActionLabels.count ? inlineActionLabels[i] : ""
          var image: UIImage? = nil
          if i < inlineActionSymbols.count, !inlineActionSymbols[i].isEmpty {
            image = UIImage(systemName: inlineActionSymbols[i])
          }
          
          // Apply size - use larger size for inline actions
          let symbolSize: CGFloat
          if i < inlineActionSizes.count {
            symbolSize = CGFloat(truncating: inlineActionSizes[i])
          } else {
            symbolSize = 28.0  // Default larger size for inline actions
          }
          if symbolSize > 0, let img = image {
            image = img.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: symbolSize))
          }
          
          // Apply rendering mode
          if i < inlineActionModes.count, let mode = inlineActionModes[i] {
            switch mode {
            case "hierarchical":
              if i < inlineActionColors.count {
                let c = Self.colorFromARGB(inlineActionColors[i].intValue)
                if let img = image {
                  let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
                  image = img.applyingSymbolConfiguration(cfg)
                }
              }
            case "palette":
              if i < inlineActionPalettes.count {
                let palColors = inlineActionPalettes[i].map { Self.colorFromARGB($0.intValue) }
                if !palColors.isEmpty, let img = image {
                  let cfg = UIImage.SymbolConfiguration(paletteColors: palColors)
                  image = img.applyingSymbolConfiguration(cfg)
                }
              }
            case "multicolor":
              if let img = image {
                let cfg = UIImage.SymbolConfiguration.preferringMulticolor()
                image = img.applyingSymbolConfiguration(cfg)
              }
            case "monochrome":
              if i < inlineActionColors.count {
                let c = Self.colorFromARGB(inlineActionColors[i].intValue)
                if let img = image {
                  let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
                  image = img.applyingSymbolConfiguration(cfg)
                }
              }
            default: break
            }
          } else if i < inlineActionColors.count {
            let c = Self.colorFromARGB(inlineActionColors[i].intValue)
            if let img = image {
              let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
              image = img.applyingSymbolConfiguration(cfg)
            }
          }
          
          let isEnabled = i < inlineActionEnabled.count ? inlineActionEnabled[i] : true
          
          // Create action with title (shows below icon in horizontal layout)
          // The .medium preferredElementSize displays title below the icon
          let currentIndex = i
          let action = UIAction(title: subtitle, image: image) { [weak self] _ in
            self?.channel.invokeMethod("onInlineActionSelected", arguments: currentIndex)
          }
          action.attributes = isEnabled ? [] : [UIAction.Attributes.disabled]
          inlineActions.append(action)
        }
        
        // Add inline actions directly to groups - iOS 15+ renders these horizontally
        // when they have subtitle + image with empty title
        if !inlineActions.isEmpty {
          groups.append(inlineActions)
        }
      }
      
      // Build regular menu items
      var i = 0
      while i < count {
        let isDiv = i < dividers.count ? dividers[i] : false
        if isDiv { flushGroup(); i += 1; continue }
        let title = i < labels.count ? labels[i] : ""
        var image: UIImage? = nil
        if i < symbols.count, !symbols[i].isEmpty { image = UIImage(systemName: symbols[i]) }
        if let sizes = defaultSizes, i < sizes.count {
          let s = CGFloat(truncating: sizes[i])
          if s > 0, let img = image { image = img.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: s)) }
        }
        
        // Rendering mode
        if i < self.itemModes.count, let mode = self.itemModes[i] {
          switch mode {
          case "hierarchical":
            if #available(iOS 15.0, *), let colors = defaultColors, i < colors.count {
              let c = Self.colorFromARGB(colors[i].intValue)
              if let img = image {
                let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
                image = img.applyingSymbolConfiguration(cfg)
              }
            }
          case "palette":
            if #available(iOS 15.0, *), i < self.itemPalettes.count {
              let palColors = self.itemPalettes[i].map { Self.colorFromARGB($0.intValue) }
              if !palColors.isEmpty, let img = image {
                let cfg = UIImage.SymbolConfiguration(paletteColors: palColors)
                image = img.applyingSymbolConfiguration(cfg)
              }
            }
          case "multicolor":
            if #available(iOS 15.0, *), let img = image {
              let cfg = UIImage.SymbolConfiguration.preferringMulticolor()
              image = img.applyingSymbolConfiguration(cfg)
            }
          case "monochrome":
            if #available(iOS 15.0, *), let colors = defaultColors, i < colors.count {
              let c = Self.colorFromARGB(colors[i].intValue)
              if let img = image {
                let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
                image = img.applyingSymbolConfiguration(cfg)
              }
            }
          default: break
          }
        } else if let colors = defaultColors, i < colors.count {
          let c = Self.colorFromARGB(colors[i].intValue)
          if #available(iOS 15.0, *), let img = image {
            let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
            image = img.applyingSymbolConfiguration(cfg)
          }
        }
        
        let isEnabled = i < self.enabled.count ? self.enabled[i] : true
        
        // Get subtitle and submenu info
        let subtitle = i < self.subtitles.count ? self.subtitles[i] : nil
        let submenuCount = i < self.submenuItemCounts.count ? self.submenuItemCounts[i] : 0
        
        // Check if this is a submenu (has child items)
        if submenuCount > 0, #available(iOS 14.0, *) {
          // Build submenu children
          var submenuChildren: [UIMenuElement] = []
          for childIdx in (i + 1)...(i + submenuCount) {
            guard childIdx < self.labels.count else { break }
            
            let childTitle = self.labels[childIdx]
            let childIsDivider = childIdx < self.dividers.count ? self.dividers[childIdx] : false
            
            if childIsDivider {
              // Dividers within submenus are handled by sections
              continue
            }
            
            var childImage: UIImage? = nil
            if childIdx < self.symbols.count, !self.symbols[childIdx].isEmpty {
              let childSymbolName = self.symbols[childIdx]
              if #available(iOS 13.0, *) {
                childImage = UIImage(systemName: childSymbolName)
              }
              // Apply sizing and coloring for child
              if let childImg = childImage {
                if childIdx < self.itemSizes.count {
                  let size = CGFloat(truncating: self.itemSizes[childIdx])
                  let cfg = UIImage.SymbolConfiguration(pointSize: size)
                  childImage = childImg.applyingSymbolConfiguration(cfg)
                }
              }
              // Apply rendering modes for child (simplified, can be expanded)
              if childIdx < self.itemModes.count, let childMode = self.itemModes[childIdx] {
                // ... (color/mode logic can be added similar to parent)
              } else if let childImg = childImage, let defaultColors = defaultColors, childIdx < defaultColors.count {
                let c = Self.colorFromARGB(defaultColors[childIdx].intValue)
                if #available(iOS 15.0, *) {
                  let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
                  childImage = childImg.applyingSymbolConfiguration(cfg)
                }
              }
            }
            
            let childIsEnabled = childIdx < self.enabled.count ? self.enabled[childIdx] : true
            let currentIndex = childIdx
            let childAction = UIAction(title: childTitle, image: childImage) { [weak self] _ in
              self?.channel.invokeMethod("onItemSelected", arguments: ["index": currentIndex])
            }
            childAction.attributes = childIsEnabled ? [] : [.disabled]
            submenuChildren.append(childAction)
          }
          
          // Create submenu with subtitle
          let submenu: UIMenu
          if #available(iOS 15.0, *), let subtitle = subtitle, !subtitle.isEmpty {
            submenu = UIMenu(title: title, subtitle: subtitle, image: image, children: submenuChildren)
          } else {
            submenu = UIMenu(title: title, image: image, children: submenuChildren)
          }
          current.append(submenu)
          
          // Skip the child items we just processed
          i += submenuCount + 1
        } else {
          // Regular action (no submenu)
          let action: UIAction
          let currentIndex = i
          if #available(iOS 15.0, *), let subtitle = subtitle, !subtitle.isEmpty {
            action = UIAction(title: title, subtitle: subtitle, image: image) { [weak self] _ in
              self?.channel.invokeMethod("onItemSelected", arguments: ["index": currentIndex])
            }
          } else {
            action = UIAction(title: title, image: image) { [weak self] _ in
              self?.channel.invokeMethod("onItemSelected", arguments: ["index": currentIndex])
            }
          }
          action.attributes = isEnabled ? [] : [.disabled]
          current.append(action)
          i += 1
        }
      }
      flushGroup()
      
      // Create menu sections - first section (inline actions) gets special treatment on iOS 16+
      var children: [UIMenu] = []
      for (index, group) in groups.enumerated() {
        if #available(iOS 16.0, *), index == 0, !inlineActionLabels.isEmpty {
          // First section with inline actions - use medium size for horizontal layout
          let menu = UIMenu(options: .displayInline, preferredElementSize: .medium, children: group)
          children.append(menu)
        } else {
          // Regular sections
          let menu = UIMenu(options: .displayInline, children: group)
          children.append(menu)
        }
      }
      
      button.menu = UIMenu(children: children)
    }
  }

  @objc private func onButtonPressedLegacy(_ sender: UIButton) {
    // iOS 13 fallback - show action sheet
    guard let vc = container.window?.rootViewController else { return }
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    for i in 0..<labels.count {
      let isDiv = i < dividers.count ? dividers[i] : false
      if isDiv { continue }
      let title = labels[i]
      let isEnabled = i < enabled.count ? enabled[i] : true
      let currentIndex = i
      let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
        self?.channel.invokeMethod("onItemSelected", arguments: ["index": currentIndex])
      }
      action.isEnabled = isEnabled
      alert.addAction(action)
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    if let popover = alert.popoverPresentationController {
      popover.sourceView = sender
      popover.sourceRect = sender.bounds
    }
    vc.present(alert, animated: true)
  }

  private func applyButtonStyle(buttonStyle: String, round: Bool) {
    if #available(iOS 15.0, *) {
      var config: UIButton.Configuration
      switch buttonStyle {
      case "filled": config = .filled()
      case "gray": config = .gray()
      case "tinted": config = .tinted()
      case "plain": config = .plain()
      case "bordered": config = .bordered()
      case "borderless": config = .borderless()
      case "borderedProminent": config = .borderedProminent()
      case "borderedTinted": config = .borderedTinted()
      case "glass":
        if #available(iOS 26.0, *) { config = .glass() } else { config = .tinted() }
      case "prominentGlass":
        if #available(iOS 26.0, *) { config = .prominentGlass() } else { config = .tinted() }
      default: config = .plain()
      }
      if round {
        config.cornerStyle = .capsule
      } else {
        config.cornerStyle = .medium
      }
      if let tint = button.tintColor {
        switch buttonStyle {
        case "filled", "borderedProminent", "prominentGlass":
          config.baseBackgroundColor = tint
        case "tinted", "bordered", "gray", "plain", "glass":
          config.baseForegroundColor = tint
        default:
          break
        }
      }
      button.configuration = config
    } else {
      // iOS 13-14: basic styling
      if round {
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
      }
    }
  }

  private func setButtonContent(title: String?, image: UIImage?, iconOnly: Bool) {
    if #available(iOS 15.0, *) {
      var cfg = button.configuration ?? .plain()
      if iconOnly {
        cfg.title = nil
        cfg.image = image
        cfg.imagePlacement = .all
      } else {
        cfg.title = title
        cfg.image = image
        cfg.imagePlacement = .leading
        cfg.imagePadding = 4
      }
      button.configuration = cfg
    } else {
      button.setTitle(title, for: .normal)
      button.setImage(image, for: .normal)
    }
  }

  private func makeButtonIconImage() -> UIImage? {
    guard let name = btnIconName else { return nil }
    var img = UIImage(systemName: name)
    if let size = btnIconSize, size > 0, let i = img {
      let cfg = UIImage.SymbolConfiguration(pointSize: size)
      img = i.applyingSymbolConfiguration(cfg)
    }
    return img
  }

  private func makeButtonSymbolConfiguration() -> UIImage.SymbolConfiguration? {
    guard #available(iOS 15.0, *) else { return nil }
    guard btnIconName != nil else { return nil }
    
    if let mode = btnIconMode {
      switch mode {
      case "hierarchical":
        if let c = btnIconColor {
          return UIImage.SymbolConfiguration(hierarchicalColor: c)
        }
      case "palette":
        if !btnIconPalette.isEmpty {
          return UIImage.SymbolConfiguration(paletteColors: btnIconPalette)
        }
      case "multicolor":
        return UIImage.SymbolConfiguration.preferringMulticolor()
      case "monochrome":
        if let c = btnIconColor {
          return UIImage.SymbolConfiguration(hierarchicalColor: c)
        }
      default: break
      }
    }
    
    if let c = btnIconColor {
      return UIImage.SymbolConfiguration(hierarchicalColor: c)
    }
    return nil
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
