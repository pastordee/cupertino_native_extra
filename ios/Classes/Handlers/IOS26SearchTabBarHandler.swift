import Flutter
import UIKit

/// Handler for iOS 26+ native tab bar controller with search support
@available(iOS 15.0, *)
class IOS26SearchTabBarHandler: NSObject {
    private let channel: FlutterMethodChannel
    private let messenger: FlutterBinaryMessenger
    private weak var rootViewController: UIViewController?
    private var tabBarController: IOS26SearchTabBarController?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController) {
        self.messenger = messenger
        self.rootViewController = viewController
        self.channel = FlutterMethodChannel(
            name: "cupertino_native/ios26_search_tab_bar",
            binaryMessenger: messenger
        )
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableNativeTabBar":
            enableNativeTabBar(call: call, result: result)
        case "disableNativeTabBar":
            disableNativeTabBar(result: result)
        case "setSelectedIndex":
            setSelectedIndex(call: call, result: result)
        case "showSearch":
            showSearch(result: result)
        case "hideSearch":
            hideSearch(result: result)
        case "isEnabled":
            isEnabled(result: result)
        case "getCurrentTabIndex":
            getCurrentTabIndex(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Tab Bar Management
    
    private func enableNativeTabBar(call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "SELF_RELEASED", message: "Handler was released", details: nil))
                return
            }
            
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            
            // Get the root view controller
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
                result(FlutterError(code: "NO_WINDOW", message: "No key window found", details: nil))
                return
            }
            
            guard let flutterVC = window.rootViewController else {
                result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller", details: nil))
                return
            }
            
            // Store reference to original Flutter view controller
            self.rootViewController = flutterVC
            
            // Parse tab configurations
            guard let tabsData = args["tabs"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_TABS", message: "Invalid tabs configuration", details: nil))
                return
            }
            
            let selectedIndex = (args["selectedIndex"] as? Int) ?? 0
            
            // Create tab bar controller
            let tabBarController = IOS26SearchTabBarController(
                tabs: tabsData,
                selectedIndex: selectedIndex,
                messenger: self.messenger,
                wrappedViewController: flutterVC
            )
            
            // Set this handler as the delegate for callbacks
            tabBarController.onTabSelected = { [weak self] index in
                self?.channel.invokeMethod("onTabSelected", arguments: ["index": index])
            }
            tabBarController.onSearchQueryChanged = { [weak self] query in
                self?.channel.invokeMethod("onSearchQueryChanged", arguments: ["query": query])
            }
            tabBarController.onSearchSubmitted = { [weak self] query in
                self?.channel.invokeMethod("onSearchSubmitted", arguments: ["query": query])
            }
            tabBarController.onSearchCancelled = { [weak self] in
                self?.channel.invokeMethod("onSearchCancelled", arguments: nil)
            }
            
            self.tabBarController = tabBarController
            
            // Replace root view controller
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            
            print("[IOS26SearchTabBar] Native tab bar controller installed with wrapped Flutter VC")
            result(nil)
        }
    }
    
    private func disableNativeTabBar(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let originalVC = self.rootViewController else {
                result(FlutterError(code: "NOT_ENABLED", message: "Tab bar not enabled", details: nil))
                return
            }
            
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
                result(FlutterError(code: "NO_WINDOW", message: "No key window found", details: nil))
                return
            }
            
            // Restore original Flutter view controller
            window.rootViewController = originalVC
            window.makeKeyAndVisible()
            
            self.tabBarController = nil
            self.rootViewController = nil
            
            print("[IOS26SearchTabBar] Native tab bar controller removed")
            result(nil)
        }
    }
    
    private func setSelectedIndex(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let index = args["index"] as? Int else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController?.selectedIndex = index
            result(nil)
        }
    }
    
    private func showSearch(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController?.activateSearch()
            result(nil)
        }
    }
    
    private func hideSearch(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController?.deactivateSearch()
            result(nil)
        }
    }
    
    private func isEnabled(result: @escaping FlutterResult) {
        result(tabBarController != nil)
    }
    
    private func getCurrentTabIndex(result: @escaping FlutterResult) {
        result(tabBarController?.selectedIndex ?? 0)
    }
}

// MARK: - iOS 26 Search Tab Bar Controller

@available(iOS 15.0, *)
private class IOS26SearchTabBarController: UITabBarController {
    private let tabConfigs: [[String: Any]]
    private let wrappedViewController: UIViewController?
    var onTabSelected: ((Int) -> Void)?
    var onSearchQueryChanged: ((String) -> Void)?
    var onSearchSubmitted: ((String) -> Void)?
    var onSearchCancelled: (() -> Void)?
    
    private var searchTabIndex: Int = -1
    private var searchController: UISearchController?
    private let messenger: FlutterBinaryMessenger
    
    init(tabs: [[String: Any]], selectedIndex: Int, messenger: FlutterBinaryMessenger, wrappedViewController: UIViewController? = nil) {
        self.tabConfigs = tabs
        self.messenger = messenger
        self.wrappedViewController = wrappedViewController
        
        super.init(nibName: nil, bundle: nil)
        
        // Find search tab index
        for (index, tab) in tabs.enumerated() {
            if tab["isSearch"] as? Bool == true {
                searchTabIndex = index
                break
            }
        }
        
        self.selectedIndex = selectedIndex
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("[IOS26SearchTabBar] Setting up tab bar controller")
        
        setupTabBarAppearance()
        setupViewControllers()
        self.delegate = self
        
        print("[IOS26SearchTabBar] Tab bar controller setup complete")
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        appearance.shadowColor = UIColor.separator
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        var controllers: [UIViewController] = []
        
        for (index, config) in tabConfigs.enumerated() {
            let title = config["title"] as? String ?? "Tab \(index + 1)"
            let isSearch = config["isSearch"] as? Bool ?? false
            let sfSymbol = config["sfSymbol"] as? String
            
            // Create appropriate view controller for this tab
            let vc: UIViewController
            if isSearch {
                // Search tab: wrap in navigation controller with search controller
                let searchPlaceholder = UIViewController()
                searchPlaceholder.view.backgroundColor = .systemBackground
                let navController = UINavigationController(rootViewController: searchPlaceholder)
                
                // Create and configure search controller
                let searchController = UISearchController(searchResultsController: nil)
                searchController.searchResultsUpdater = self
                searchController.searchBar.delegate = self
                searchController.obscuresBackgroundDuringPresentation = false
                searchController.searchBar.placeholder = "Search"
                
                searchPlaceholder.navigationItem.searchController = searchController
                searchPlaceholder.navigationItem.hidesSearchBarWhenScrolling = false
                searchPlaceholder.definesPresentationContext = true
                
                vc = navController
                print("[IOS26SearchTabBar] Created search tab with nav controller and search controller at index \(index)")
            } else if index == 0, let flutterVC = wrappedViewController {
                // First tab: wrap Flutter view in a custom container VC
                let tabVC = FlutterTabViewController()
                tabVC.tabIndex = index
                tabVC.embedFlutterView(flutterVC.view)
                vc = tabVC
                print("[IOS26SearchTabBar] Wrapped Flutter view in custom tab VC for tab 0")
            } else {
                // Other tabs: placeholder view controller
                let tabVC = TabPlaceholderViewController()
                tabVC.title = title
                vc = tabVC
            }
            
            // Setup tab bar item
            if isSearch {
                vc.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: index)
            } else if let symbol = sfSymbol {
                let image = UIImage(systemName: symbol)
                vc.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image)
            } else {
                vc.tabBarItem = UITabBarItem(title: title, image: nil, tag: index)
            }
            vc.tabBarItem.tag = index
            
            controllers.append(vc)
        }
        
        viewControllers = controllers
    }
    
    func activateSearch() {
        if searchTabIndex >= 0 {
            selectedIndex = searchTabIndex
            print("[IOS26SearchTabBar] Search tab activated")
            
            // Activate the search controller to show the search interface
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let searchVC = self.viewControllers?[self.searchTabIndex] as? FlutterTabViewController {
                    // Try to activate any search controller if present
                    if let navController = searchVC.navigationController {
                        navController.navigationBar.prefersLargeTitles = false
                    }
                }
            }
        }
    }
    
    func deactivateSearch() {
        if searchTabIndex >= 0 {
            selectedIndex = 0
            print("[IOS26SearchTabBar] Search tab deactivated")
        }
    }
}

// MARK: - Custom Tab View Controllers

/// Wrapper view controller for Flutter tab content
private class FlutterTabViewController: UIViewController {
    var tabIndex: Int = 0
    private var embeddedFlutterView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    func embedFlutterView(_ flutterView: UIView) {
        // Remove from previous parent if needed
        flutterView.removeFromSuperview()
        
        // Add to this view controller
        flutterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flutterView)
        NSLayoutConstraint.activate([
            flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flutterView.topAnchor.constraint(equalTo: view.topAnchor),
            flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        embeddedFlutterView = flutterView
    }
}

/// Placeholder view controller for non-Flutter tabs
private class TabPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Tab Content\n\n(Controlled by Flutter)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - UITabBarControllerDelegate

@available(iOS 15.0, *)
extension IOS26SearchTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController) ?? 0
        print("[IOS26SearchTabBar] Tab selected: \(index)")
        onTabSelected?(index)
    }
}

// MARK: - UISearchResultsUpdating

@available(iOS 15.0, *)
extension IOS26SearchTabBarController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        onSearchQueryChanged?(query)
    }
}

// MARK: - UISearchBarDelegate

@available(iOS 15.0, *)
extension IOS26SearchTabBarController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        onSearchSubmitted?(query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        onSearchCancelled?()
    }
}
