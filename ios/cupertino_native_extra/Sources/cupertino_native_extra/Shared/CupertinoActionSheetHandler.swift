import Flutter
import UIKit

/// Handles native iOS action sheet (UIAlertController) via method channel
class CupertinoActionSheetHandler: NSObject {
    private let channel: FlutterMethodChannel
    private weak var viewController: UIViewController?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController) {
        self.channel = FlutterMethodChannel(name: "cupertino_native_action_sheet", binaryMessenger: messenger)
        self.viewController = viewController
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showActionSheet":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Arguments must be a map", details: nil))
                return
            }
            showActionSheet(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showActionSheet(args: [String: Any], result: @escaping FlutterResult) {
        guard let viewController = viewController else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "View controller not available", details: nil))
            return
        }
        
        // Create alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Set title
        if let title = args["title"] as? String {
            alertController.title = title
        }
        
        // Set message
        if let message = args["message"] as? String {
            alertController.message = message
        }
        
        // Add actions
        if let actions = args["actions"] as? [[String: Any]] {
            for (index, actionData) in actions.enumerated() {
                if let title = actionData["title"] as? String {
                    let styleIndex = actionData["style"] as? Int ?? 0
                    let style: UIAlertAction.Style
                    
                    switch styleIndex {
                    case 1:
                        style = .cancel
                    case 2:
                        style = .destructive
                    default:
                        style = .default
                    }
                    
                    let action = UIAlertAction(title: title, style: style) { _ in
                        result(index)
                    }
                    
                    alertController.addAction(action)
                }
            }
        }
        
        // Handle iPad popover presentation
        if let popoverController = alertController.popoverPresentationController {
            if let sourceView = viewController.view {
                popoverController.sourceView = sourceView
                popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        // Present
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
