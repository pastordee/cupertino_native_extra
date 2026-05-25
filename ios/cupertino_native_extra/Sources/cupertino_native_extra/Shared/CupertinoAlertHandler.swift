import Foundation
import Flutter
import UIKit

/// Handler for native alert dialogs using UIAlertController.
class CupertinoAlertHandler: NSObject {
    private let channel: FlutterMethodChannel
    private weak var viewController: UIViewController?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController?) {
        self.channel = FlutterMethodChannel(
            name: "cupertino_native_alert",
            binaryMessenger: messenger
        )
        self.viewController = viewController
        super.init()
        
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showAlert":
            showAlert(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showAlert(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let actionsData = args["actions"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS",
                              message: "Invalid arguments for showAlert",
                              details: nil))
            return
        }
        
        let message = args["message"] as? String
        let preferredActionIndex = args["preferredActionIndex"] as? Int
        
        // Create the alert controller (UIAlertController.Style.alert)
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        // Add actions
        var addedActions: [UIAlertAction] = []
        for (index, actionData) in actionsData.enumerated() {
            guard let actionTitle = actionData["title"] as? String,
                  let styleIndex = actionData["style"] as? Int else {
                continue
            }
            
            let style: UIAlertAction.Style
            switch styleIndex {
            case 0: // default
                style = .default
            case 1: // cancel
                style = .cancel
            case 2: // destructive
                style = .destructive
            default:
                style = .default
            }
            
            let action = UIAlertAction(title: actionTitle, style: style) { _ in
                result(index)
            }
            
            alertController.addAction(action)
            addedActions.append(action)
        }
        
        // Set preferred action (default button)
        if let preferredIndex = preferredActionIndex,
           preferredIndex >= 0,
           preferredIndex < addedActions.count {
            alertController.preferredAction = addedActions[preferredIndex]
        }
        
        // Present the alert
        DispatchQueue.main.async { [weak self] in
            guard let viewController = self?.viewController ?? self?.topViewController() else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER",
                                  message: "Unable to find view controller",
                                  details: nil))
                return
            }
            
            viewController.present(alertController, animated: true)
        }
    }
    
    /// Gets the topmost view controller to present the alert.
    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
}
