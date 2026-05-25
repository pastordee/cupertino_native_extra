import Flutter
import UIKit

class CupertinoSearchControllerHandler: NSObject {
    private let channel: FlutterMethodChannel
    private weak var viewController: UIViewController?
    private var searchController: UISearchController?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController) {
        self.channel = FlutterMethodChannel(name: "cupertino_native_search_controller", binaryMessenger: messenger)
        self.viewController = viewController
        
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            show(call: call, result: result)
        case "hide":
            hide(result: result)
        case "updateSearchText":
            updateSearchText(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func show(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "SELF_RELEASED", message: "Handler was released", details: nil))
                return
            }
            
            // Try to get the best available view controller
            var presentingViewController: UIViewController?
            
            // First try the stored view controller
            if let vc = self.viewController, vc.view.window != nil {
                presentingViewController = vc
                print("[CNNativeSearchController] Using stored view controller")
            }
            
            // If that fails, try to find the key window's root view controller
            if presentingViewController == nil {
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow }),
                   let rootViewController = window.rootViewController {
                    presentingViewController = rootViewController
                    print("[CNNativeSearchController] Using key window root view controller")
                }
            }
            
            // If still nil, try to find any window
            if presentingViewController == nil {
                if let window = UIApplication.shared.windows.first,
                   let rootViewController = window.rootViewController {
                    presentingViewController = rootViewController
                    print("[CNNativeSearchController] Using first window root view controller")
                }
            }
            
            guard let viewController = presentingViewController else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller available", details: nil))
                return
            }
            
            print("[CNNativeSearchController] Presenting search controller from: \(viewController)")
            
            // Create search results controller (empty for now - will be populated by Flutter)
            let searchResultsController = UIViewController()
            searchResultsController.view.backgroundColor = .systemBackground
            
            // Create search controller
            let searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self
            searchController.obscuresBackgroundDuringPresentation = true
            searchController.hidesNavigationBarDuringPresentation = false
            
            // Prevent dismiss by tapping outside
            searchController.modalPresentationStyle = .fullScreen
            
            // Configure search bar
            if let placeholder = args["placeholder"] as? String {
                searchController.searchBar.placeholder = placeholder
            } else {
                searchController.searchBar.placeholder = "Search"
            }
            
            // Set keyboard properties
            if let keyboardTypeIndex = args["keyboardType"] as? Int,
               keyboardTypeIndex >= 0,
               keyboardTypeIndex < 11 {
                let keyboardTypes: [UIKeyboardType] = [
                    .default, .asciiCapable, .numbersAndPunctuation, .URL,
                    .numberPad, .phonePad, .namePhonePad, .emailAddress,
                    .decimalPad, .twitter, .webSearch
                ]
                searchController.searchBar.keyboardType = keyboardTypes[keyboardTypeIndex]
            }
            
            if let keyboardAppearanceIndex = args["keyboardAppearance"] as? Int,
               keyboardAppearanceIndex >= 0,
               keyboardAppearanceIndex < 3 {
                let appearances: [UIKeyboardAppearance] = [.default, .light, .dark]
                searchController.searchBar.keyboardAppearance = appearances[keyboardAppearanceIndex]
            }
            
            if let returnKeyTypeIndex = args["returnKeyType"] as? Int,
               returnKeyTypeIndex >= 0,
               returnKeyTypeIndex < 11 {
                let returnKeyTypes: [UIReturnKeyType] = [
                    .default, .go, .google, .join, .next, .route,
                    .search, .send, .yahoo, .done, .emergencyCall
                ]
                searchController.searchBar.returnKeyType = returnKeyTypes[returnKeyTypeIndex]
            }
            
            if let autocapitalizationTypeIndex = args["autocapitalizationType"] as? Int,
               autocapitalizationTypeIndex >= 0,
               autocapitalizationTypeIndex < 4 {
                let types: [UITextAutocapitalizationType] = [.none, .words, .sentences, .allCharacters]
                searchController.searchBar.autocapitalizationType = types[autocapitalizationTypeIndex]
            }
            
            if let autocorrectionTypeIndex = args["autocorrectionType"] as? Int,
               autocorrectionTypeIndex >= 0,
               autocorrectionTypeIndex < 3 {
                let types: [UITextAutocorrectionType] = [.default, .no, .yes]
                searchController.searchBar.autocorrectionType = types[autocorrectionTypeIndex]
            }
            
            if let spellCheckingTypeIndex = args["spellCheckingType"] as? Int,
               spellCheckingTypeIndex >= 0,
               spellCheckingTypeIndex < 3 {
                let types: [UITextSpellCheckingType] = [.default, .no, .yes]
                searchController.searchBar.spellCheckingType = types[spellCheckingTypeIndex]
            }
            
            // Configure appearance
            if let barTintColorValue = args["barTintColor"] as? Int {
                searchController.searchBar.barTintColor = Self.colorFromARGB(barTintColorValue)
            }
            
            if let tintColorValue = args["tintColor"] as? Int {
                searchController.searchBar.tintColor = Self.colorFromARGB(tintColorValue)
            }
            
            if let searchFieldBackgroundColorValue = args["searchFieldBackgroundColor"] as? Int {
                searchController.searchBar.searchTextField.backgroundColor = Self.colorFromARGB(searchFieldBackgroundColorValue)
            }
            
            self.searchController = searchController
            
            print("[CNNativeSearchController] Search controller created, presenting now...")
            
            // Present the search controller
            viewController.present(searchController, animated: true) {
                print("[CNNativeSearchController] Search controller presented successfully")
                // Focus search bar
                searchController.searchBar.becomeFirstResponder()
                result(nil)
            }
        }
    }
    
    private func hide(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.searchController?.dismiss(animated: true) {
                result(nil)
            }
        }
    }
    
    private func updateSearchText(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let text = args["text"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.searchController?.searchBar.text = text
            result(nil)
        }
    }
    
    // MARK: - Helper Methods
    
    static func colorFromARGB(_ argb: Int) -> UIColor {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - UISearchResultsUpdating

extension CupertinoSearchControllerHandler: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        channel.invokeMethod("onSearchTextChanged", arguments: ["query": query])
    }
}

// MARK: - UISearchBarDelegate

extension CupertinoSearchControllerHandler: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        channel.invokeMethod("onSearchSubmitted", arguments: ["query": query])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController?.dismiss(animated: true) {
            self.channel.invokeMethod("onSearchCancelled", arguments: nil)
        }
    }
}
