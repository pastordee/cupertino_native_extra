import Flutter
import UIKit

/// Platform view that creates a UINavigationController with navigation bar and scrollable content.
/// This enables proper iOS large title behavior where the title collapses on scroll.
class CupertinoNavigationBarScrollablePlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let navigationController: UINavigationController
  private let contentViewController: UIViewController
  private let scrollView: UIScrollView
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeNavigationBarScrollable_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    
    // Create a view controller to hold the navigation controller
    self.contentViewController = UIViewController()
    
    // Create navigation controller
    self.navigationController = UINavigationController(rootViewController: contentViewController)
    
    // Create scroll view for content
    self.scrollView = UIScrollView()
    
    var title: String = ""
    var leadingIcons: [String] = []
    var leadingLabels: [String] = []
    var leadingPaddings: [Double] = []
    var leadingSpacers: [String] = []
    var trailingIcons: [String] = []
    var trailingLabels: [String] = []
    var trailingPaddings: [Double] = []
    var trailingSpacers: [String] = []
    var largeTitle: Bool = true  // Default to true for scrollable mode
    var transparent: Bool = false
    var isDark: Bool = false
    var tint: UIColor? = nil
    
    if let dict = args as? [String: Any] {
      title = (dict["title"] as? String) ?? ""
      leadingIcons = (dict["leadingIcons"] as? [String]) ?? []
      leadingLabels = (dict["leadingLabels"] as? [String]) ?? []
      leadingPaddings = (dict["leadingPaddings"] as? [Double]) ?? []
      leadingSpacers = (dict["leadingSpacers"] as? [String]) ?? []
      trailingIcons = (dict["trailingIcons"] as? [String]) ?? []
      trailingLabels = (dict["trailingLabels"] as? [String]) ?? []
      trailingPaddings = (dict["trailingPaddings"] as? [Double]) ?? []
      trailingSpacers = (dict["trailingSpacers"] as? [String]) ?? []
      if let v = dict["largeTitle"] as? NSNumber { largeTitle = v.boolValue }
      if let v = dict["transparent"] as? NSNumber { transparent = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
    }
    
    super.init()
    
    // Parse tint color after super.init()
    if let dict = args as? [String: Any],
       let style = dict["style"] as? [String: Any],
       let n = style["tint"] as? NSNumber {
      tint = colorFromARGB(n.intValue)
    }
    
    // Setup container
    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    
    // Configure navigation bar appearance
    let navigationBar = navigationController.navigationBar
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      if transparent {
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
      } else {
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
      }
      
      if let tintColor = tint {
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
        navigationBar.tintColor = tintColor
      }
      
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.compactAppearance = appearance
      if #available(iOS 15.0, *) {
        navigationBar.compactScrollEdgeAppearance = appearance
      }
    } else {
      if transparent {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
      } else {
        navigationBar.isTranslucent = true
      }
      if let tintColor = tint {
        navigationBar.tintColor = tintColor
      }
    }
    
    // Enable large titles
    if #available(iOS 11.0, *) {
      navigationBar.prefersLargeTitles = largeTitle
      contentViewController.navigationItem.largeTitleDisplayMode = largeTitle ? .always : .never
    }
    
    // Set title
    contentViewController.title = title
    
    // Setup scroll view
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .clear
    contentViewController.view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: contentViewController.view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: contentViewController.view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: contentViewController.view.bottomAnchor)
    ])
    
    // Create leading buttons
    if !leadingIcons.isEmpty || !leadingLabels.isEmpty {
      var barItems: [UIBarButtonItem] = []
      let count = max(leadingIcons.count, leadingLabels.count)
      
      for i in 0..<count {
        let icon = i < leadingIcons.count ? leadingIcons[i] : ""
        let label = i < leadingLabels.count ? leadingLabels[i] : ""
        let spacer = i < leadingSpacers.count ? leadingSpacers[i] : ""
        
        if spacer == "flexible" {
          barItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
          continue
        } else if spacer == "fixed" {
          let padding = i < leadingPaddings.count ? CGFloat(leadingPaddings[i]) : 8.0
          let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
          fixedSpace.width = padding
          barItems.append(fixedSpace)
          continue
        }
        
        let button = UIButton(type: .system)
        button.tag = i
        
        if !icon.isEmpty, let image = createSFSymbol(icon, withTint: tint) {
          button.setImage(image, for: .normal)
        }
        if !label.isEmpty {
          button.setTitle(label, for: .normal)
        }
        
        button.addTarget(self, action: #selector(leadingTapped(_:)), for: .touchUpInside)
        
        let barItem = UIBarButtonItem(customView: button)
        barItems.append(barItem)
      }
      
      contentViewController.navigationItem.leftBarButtonItems = barItems
    }
    
    // Create trailing buttons
    if !trailingIcons.isEmpty || !trailingLabels.isEmpty {
      var barItems: [UIBarButtonItem] = []
      let count = max(trailingIcons.count, trailingLabels.count)
      
      for i in 0..<count {
        let icon = i < trailingIcons.count ? trailingIcons[i] : ""
        let label = i < trailingLabels.count ? trailingLabels[i] : ""
        let spacer = i < trailingSpacers.count ? trailingSpacers[i] : ""
        
        if spacer == "flexible" {
          barItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
          continue
        } else if spacer == "fixed" {
          let padding = i < trailingPaddings.count ? CGFloat(trailingPaddings[i]) : 8.0
          let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
          fixedSpace.width = padding
          barItems.append(fixedSpace)
          continue
        }
        
        let button = UIButton(type: .system)
        button.tag = i
        
        if !icon.isEmpty, let image = createSFSymbol(icon, withTint: tint) {
          button.setImage(image, for: .normal)
        }
        if !label.isEmpty {
          button.setTitle(label, for: .normal)
        }
        
        button.addTarget(self, action: #selector(trailingTapped(_:)), for: .touchUpInside)
        
        let barItem = UIBarButtonItem(customView: button)
        barItems.append(barItem)
      }
      
      contentViewController.navigationItem.rightBarButtonItems = barItems
    }
    
    // Add navigation controller's view to container
    navigationController.view.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(navigationController.view)
    
    NSLayoutConstraint.activate([
      navigationController.view.topAnchor.constraint(equalTo: container.topAnchor),
      navigationController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      navigationController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      navigationController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])
    
    // Set up method channel
    channel.setMethodCallHandler { [weak self] (call, result) in
      self?.handle(call, result: result)
    }
  }
  
  func view() -> UIView {
    return container
  }
  
  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
  
  @objc private func leadingTapped(_ sender: UIButton) {
    channel.invokeMethod("leadingTapped", arguments: ["index": sender.tag])
  }
  
  @objc private func trailingTapped(_ sender: UIButton) {
    channel.invokeMethod("trailingTapped", arguments: ["index": sender.tag])
  }
  
  private func createSFSymbol(_ name: String, withTint tint: UIColor?) -> UIImage? {
    if #available(iOS 13.0, *) {
      let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
      if let image = UIImage(systemName: name, withConfiguration: config) {
        if let tintColor = tint {
          return image.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }
        return image
      }
    }
    return nil
  }
  
  private func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
