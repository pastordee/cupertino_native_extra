import Cocoa
import FlutterMacOS

class CupertinoSearchBarNSView: NSView, NSSearchFieldDelegate {
    private let channel: FlutterMethodChannel
    private let searchField: NSSearchField
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(name: "CupertinoNativeSearchBar_\(viewId)", binaryMessenger: messenger)
        self.searchField = NSSearchField()
        
        super.init(frame: frame)
        
        // Parse arguments
        if let dict = args as? [String: Any] {
            // Placeholder
            if let placeholder = dict["placeholder"] as? String {
                searchField.placeholderString = placeholder
            }
            
            // Initial text
            if let text = dict["text"] as? String {
                searchField.stringValue = text
            }
            
            // Colors (macOS specific)
            if let tintValue = dict["tintColor"] as? NSNumber {
                if #available(macOS 10.14, *) {
                    searchField.appearance = NSAppearance(named: .aqua)
                }
            }
        }
        
        // Setup search field
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.sendsWholeSearchString = false
        searchField.sendsSearchStringImmediately = true
        
        // Add to view
        self.addSubview(searchField)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            searchField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            searchField.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func view() -> NSView {
        return self
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSSearchField {
            channel.invokeMethod("onTextChanged", arguments: textField.stringValue)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSSearchField {
            channel.invokeMethod("onSearchButtonClicked", arguments: textField.stringValue)
        }
    }
}

class CupertinoSearchBarNSViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        return CupertinoSearchBarNSView(frame: .zero, viewId: viewId, args: args, messenger: messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
