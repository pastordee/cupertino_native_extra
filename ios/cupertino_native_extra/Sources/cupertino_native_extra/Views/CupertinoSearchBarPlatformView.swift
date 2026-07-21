import Flutter
import UIKit

class CupertinoSearchBarPlatformView: NSObject, FlutterPlatformView, UISearchBarDelegate {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let searchBar: UISearchBar
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(name: "CupertinoNativeSearchBar_\(viewId)", binaryMessenger: messenger)
        self.container = UIView(frame: frame)
        self.searchBar = UISearchBar()
        
        super.init()
        
        // Parse arguments
        if let dict = args as? [String: Any] {
            // Text and placeholders
            if let placeholder = dict["placeholder"] as? String {
                searchBar.placeholder = placeholder
            }
            if let text = dict["text"] as? String {
                searchBar.text = text
            }
            if let prompt = dict["prompt"] as? String {
                searchBar.prompt = prompt
            }
            
            // Button visibility
            if let showsCancel = dict["showsCancelButton"] as? Bool {
                searchBar.showsCancelButton = showsCancel
            }
            if let showsBookmark = dict["showsBookmarkButton"] as? Bool {
                searchBar.showsBookmarkButton = showsBookmark
            }
            if let showsSearchResults = dict["showsSearchResultsButton"] as? Bool {
                searchBar.showsSearchResultsButton = showsSearchResults
            }
            
            // Style
            if let styleIndex = dict["searchBarStyle"] as? Int {
                switch styleIndex {
                case 0:
                    searchBar.searchBarStyle = .default
                case 1:
                    searchBar.searchBarStyle = .prominent
                case 2:
                    searchBar.searchBarStyle = .minimal
                default:
                    searchBar.searchBarStyle = .default
                }
            }
            
            // Colors
            if let barTintValue = dict["barTintColor"] as? NSNumber {
                searchBar.barTintColor = Self.colorFromARGB(barTintValue.intValue)
            }
            if let tintValue = dict["tintColor"] as? NSNumber {
                searchBar.tintColor = Self.colorFromARGB(tintValue.intValue)
            }
            if #available(iOS 13.0, *) {
                if let fieldBgValue = dict["searchFieldBackgroundColor"] as? NSNumber {
                    searchBar.searchTextField.backgroundColor = Self.colorFromARGB(fieldBgValue.intValue)
                }
            }
            
            // Scope bar
            if let showsScopeBar = dict["showsScopeBar"] as? Bool {
                searchBar.showsScopeBar = showsScopeBar
            }
            if let scopeTitles = dict["scopeButtonTitles"] as? [String] {
                searchBar.scopeButtonTitles = scopeTitles
            }
            if let selectedScope = dict["selectedScopeIndex"] as? Int {
                searchBar.selectedScopeButtonIndex = selectedScope
            }
            
            // Keyboard configuration
            if let keyboardTypeIndex = dict["keyboardType"] as? Int {
                searchBar.keyboardType = Self.keyboardType(from: keyboardTypeIndex)
            }
            if let keyboardAppearanceIndex = dict["keyboardAppearance"] as? Int {
                searchBar.keyboardAppearance = Self.keyboardAppearance(from: keyboardAppearanceIndex)
            }
            if let returnKeyTypeIndex = dict["returnKeyType"] as? Int {
                searchBar.returnKeyType = Self.returnKeyType(from: returnKeyTypeIndex)
            }
            if let enablesReturnKeyAuto = dict["enablesReturnKeyAutomatically"] as? Bool {
                searchBar.enablesReturnKeyAutomatically = enablesReturnKeyAuto
            }
            if let autocapTypeIndex = dict["autocapitalizationType"] as? Int {
                searchBar.autocapitalizationType = Self.autocapitalizationType(from: autocapTypeIndex)
            }
            if let autocorrectionTypeIndex = dict["autocorrectionType"] as? Int {
                searchBar.autocorrectionType = Self.autocorrectionType(from: autocorrectionTypeIndex)
            }
            if let spellCheckingTypeIndex = dict["spellCheckingType"] as? Int {
                searchBar.spellCheckingType = Self.spellCheckingType(from: spellCheckingTypeIndex)
            }
        }
        
        // Setup search bar
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove background to make it transparent
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        
        // Add to container
        container.backgroundColor = .clear
        container.addSubview(searchBar)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: container.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    func view() -> UIView {
        return container
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        channel.invokeMethod("onTextChanged", arguments: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        channel.invokeMethod("onSearchButtonClicked", arguments: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        channel.invokeMethod("onCancelButtonClicked", arguments: nil)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        channel.invokeMethod("onScopeChanged", arguments: selectedScope)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        channel.invokeMethod("onBookmarkButtonClicked", arguments: nil)
    }
    
    // MARK: - Helper Methods
    
    static func colorFromARGB(_ argb: Int) -> UIColor {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    static func keyboardType(from index: Int) -> UIKeyboardType {
        switch index {
        case 0: return .default
        case 1: return .asciiCapable
        case 2: return .numbersAndPunctuation
        case 3: return .URL
        case 4: return .numberPad
        case 5: return .phonePad
        case 6: return .namePhonePad
        case 7: return .emailAddress
        case 8: return .decimalPad
        case 9: return .twitter
        case 10: return .webSearch
        case 11: return .asciiCapableNumberPad
        default: return .default
        }
    }
    
    static func keyboardAppearance(from index: Int) -> UIKeyboardAppearance {
        switch index {
        case 0: return .default
        case 1: return .light
        case 2: return .dark
        default: return .default
        }
    }
    
    static func returnKeyType(from index: Int) -> UIReturnKeyType {
        switch index {
        case 0: return .default
        case 1: return .go
        case 2: return .google
        case 3: return .join
        case 4: return .next
        case 5: return .route
        case 6: return .search
        case 7: return .send
        case 8: return .yahoo
        case 9: return .done
        case 10: return .emergencyCall
        case 11: return .continue
        default: return .default
        }
    }
    
    static func autocapitalizationType(from index: Int) -> UITextAutocapitalizationType {
        switch index {
        case 0: return .none
        case 1: return .words
        case 2: return .sentences
        case 3: return .allCharacters
        default: return .none
        }
    }
    
    static func autocorrectionType(from index: Int) -> UITextAutocorrectionType {
        switch index {
        case 0: return .default
        case 1: return .no
        case 2: return .yes
        default: return .default
        }
    }
    
    static func spellCheckingType(from index: Int) -> UITextSpellCheckingType {
        switch index {
        case 0: return .default
        case 1: return .no
        case 2: return .yes
        default: return .default
        }
    }
}

class CupertinoSearchBarPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return CupertinoSearchBarPlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
