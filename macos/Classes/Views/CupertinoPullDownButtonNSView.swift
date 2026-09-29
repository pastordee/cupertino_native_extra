import FlutterMacOS
import Cocoa

class CupertinoPullDownButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private let button: NSButton
  private var pullDownMenu: NSMenu = NSMenu()
  private var labels: [String] = []
  private var symbols: [String] = []
  private var dividers: [Bool] = []
  private var enabled: [Bool] = []
  private var defaultSizes: [NSNumber] = []
  private var defaultColors: [NSNumber] = []
  private var defaultModes: [String?] = []
  private var defaultPalettes: [[NSNumber]] = []
  private var defaultGradients: [NSNumber?] = []

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePullDownButton_\(viewId)", binaryMessenger: messenger)
    self.button = NSButton(title: "", target: nil, action: nil)
    super.init(frame: .zero)

    var title: String? = nil
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: NSColor? = nil
    var makeRound: Bool = false
    var buttonStyle: String = "automatic"
    var isDark: Bool = false
    var tint: NSColor? = nil
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
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      dividers = (dict["isDivider"] as? [NSNumber]) ?? []
      enabled = (dict["enabled"] as? [NSNumber]) ?? []
      if let modes = dict["sfSymbolRenderingModes"] as? [String?] { self.defaultModes = modes }
      if let palettes = dict["sfSymbolPaletteColors"] as? [[NSNumber]] { self.defaultPalettes = palettes }
      if let gradients = dict["sfSymbolGradientEnabled"] as? [NSNumber?] { self.defaultGradients = gradients }
      if let m = dict["buttonIconRenderingMode"] as? String { buttonIconMode = m }
      if let pal = dict["buttonIconPaletteColors"] as? [NSNumber] { buttonIconPalette = pal }
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      colors = (dict["sfSymbolColors"] as? [NSNumber]) ?? []
    }

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    if let t = title { button.title = t }
    if let name = iconName, var image = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
      if #available(macOS 12.0, *), let sz = iconSize {
        let cfg = NSImage.SymbolConfiguration(pointSize: sz, weight: .regular)
        image = image.withSymbolConfiguration(cfg) ?? image
      }
      if let mode = buttonIconMode {
        switch mode {
        case "hierarchical":
          if #available(macOS 12.0, *), let c = iconColor {
            let cfg = NSImage.SymbolConfiguration(hierarchicalColor: c)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "palette":
          if #available(macOS 12.0, *), !buttonIconPalette.isEmpty {
            let cols = buttonIconPalette.map { Self.colorFromARGB($0.intValue) }
            let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "multicolor":
          if #available(macOS 12.0, *) {
            let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        default:
          break
        }
      } else if let c = iconColor {
        image = image.tinted(with: c)
      }
      button.image = image
      button.imagePosition = .imageOnly
    }

    // Map CNButtonStyle to AppKit bezel styles
    switch buttonStyle {
    case "filled", "borderedProminent":
      button.bezelStyle = .rounded
      button.isBordered = true
    case "gray", "tinted", "borderedTinted":
      button.bezelStyle = .rounded
      button.isBordered = true
    case "bordered":
      button.bezelStyle = .rounded
      button.isBordered = true
    case "borderless", "plain":
      button.bezelStyle = .roundRect
      button.isBordered = false
    default:
      button.bezelStyle = .rounded
      button.isBordered = true
    }

    if let c = tint { button.contentTintColor = c }

    self.labels = labels
    self.symbols = symbols
    self.dividers = dividers.map { $0.boolValue }
    self.enabled = enabled.map { $0.boolValue }
    self.defaultSizes = sizes
    self.defaultColors = colors
    rebuildMenu()

    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

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
          self.defaultSizes = (args["sfSymbolSizes"] as? [NSNumber]) ?? []
          self.defaultColors = (args["sfSymbolColors"] as? [NSNumber]) ?? []
          self.defaultModes = (args["sfSymbolRenderingModes"] as? [String?]) ?? []
          self.defaultPalettes = (args["sfSymbolPaletteColors"] as? [[NSNumber]]) ?? []
          self.defaultGradients = (args["sfSymbolGradientEnabled"] as? [NSNumber?]) ?? []
          self.rebuildMenu()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing items", details: nil))
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            self.button.contentTintColor = Self.colorFromARGB(n.intValue)
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

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func rebuildMenu() {
    pullDownMenu = NSMenu()
    pullDownMenu.autoenablesItems = false
    
    let count = max(labels.count, max(symbols.count, dividers.count))
    for i in 0..<count {
      let isDiv = i < dividers.count ? dividers[i] : false
      if isDiv {
        pullDownMenu.addItem(NSMenuItem.separator())
        continue
      }
      
      let title = i < labels.count ? labels[i] : ""
      let item = NSMenuItem(title: title, action: #selector(menuItemSelected(_:)), keyEquivalent: "")
      item.target = self
      item.tag = i
      item.isEnabled = i < enabled.count ? enabled[i] : true
      
      // Add SF Symbol icon if available
      if i < symbols.count, !symbols[i].isEmpty {
        if var image = NSImage(systemSymbolName: symbols[i], accessibilityDescription: nil) {
          // Apply size if specified
          if i < defaultSizes.count, let sz = defaultSizes[i] as? CGFloat, sz > 0 {
            if #available(macOS 12.0, *) {
              let cfg = NSImage.SymbolConfiguration(pointSize: sz, weight: .regular)
              image = image.withSymbolConfiguration(cfg) ?? image
            }
          }
          
          // Apply rendering mode
          if i < defaultModes.count, let mode = defaultModes[i] {
            switch mode {
            case "hierarchical":
              if #available(macOS 12.0, *), i < defaultColors.count {
                let c = Self.colorFromARGB(defaultColors[i].intValue)
                let cfg = NSImage.SymbolConfiguration(hierarchicalColor: c)
                image = image.withSymbolConfiguration(cfg) ?? image
              }
            case "palette":
              if #available(macOS 12.0, *), i < defaultPalettes.count, !defaultPalettes[i].isEmpty {
                let cols = defaultPalettes[i].map { Self.colorFromARGB($0.intValue) }
                let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
                image = image.withSymbolConfiguration(cfg) ?? image
              }
            case "multicolor":
              if #available(macOS 12.0, *) {
                let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
                image = image.withSymbolConfiguration(cfg) ?? image
              }
            default: break
            }
          } else if i < defaultColors.count {
            let c = Self.colorFromARGB(defaultColors[i].intValue)
            image = image.tinted(with: c)
          }
          
          item.image = image
        }
      }
      
      pullDownMenu.addItem(item)
    }
    
    button.menu = pullDownMenu
    if #available(macOS 10.14, *) {
      button.contentTintColor = button.contentTintColor
    }
  }

  @objc private func menuItemSelected(_ sender: NSMenuItem) {
    channel.invokeMethod("onItemSelected", arguments: sender.tag)
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(red: r, green: g, blue: b, alpha: a)
  }
}

private extension NSImage {
  func tinted(with color: NSColor) -> NSImage {
    let image = self.copy() as! NSImage
    image.lockFocus()
    color.set()
    let imageRect = NSRect(origin: .zero, size: image.size)
    imageRect.fill(using: .sourceAtop)
    image.unlockFocus()
    return image
  }
}
