import Flutter
import UIKit

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
  private static var actionSheetHandler: CupertinoActionSheetHandler?
  private static var alertHandler: CupertinoAlertHandler?
  private static var sheetHandler: CupertinoSheetHandler?
  private static var customSheetHandler: CupertinoCustomSheetHandler?
  private static var searchControllerHandler: CupertinoSearchControllerHandler?
  @available(iOS 15.0, *)
  private static var ios26SearchTabBarHandler: IOS26SearchTabBarHandler?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cupertino_native", binaryMessenger: registrar.messenger())
    let instance = CupertinoNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Register platform view factories
    let sliderFactory = CupertinoSliderViewFactory(messenger: registrar.messenger())
    registrar.register(sliderFactory, withId: "CupertinoNativeSlider")

    let switchFactory = CupertinoSwitchViewFactory(messenger: registrar.messenger())
    registrar.register(switchFactory, withId: "CupertinoNativeSwitch")

    // Segmented control
    let segmentedFactory = CupertinoSegmentedControlViewFactory(messenger: registrar.messenger())
    registrar.register(segmentedFactory, withId: "CupertinoNativeSegmentedControl")

    let iconFactory = CupertinoIconViewFactory(messenger: registrar.messenger())
    registrar.register(iconFactory, withId: "CupertinoNativeIcon")

    let tabBarFactory = CupertinoTabBarViewFactory(messenger: registrar.messenger())
    registrar.register(tabBarFactory, withId: "CupertinoNativeTabBar")

    let popupMenuFactory = CupertinoPopupMenuButtonViewFactory(messenger: registrar.messenger())
    registrar.register(popupMenuFactory, withId: "CupertinoNativePopupMenuButton")

    let pullDownButtonFactory = CupertinoPullDownButtonViewFactory(messenger: registrar.messenger())
    registrar.register(pullDownButtonFactory, withId: "CupertinoNativePullDownButton")

    if #available(iOS 14.0, *) {
      let pullDownButtonAnchorFactory = CupertinoNativePullDownButtonAnchorFactory(messenger: registrar.messenger())
      registrar.register(pullDownButtonAnchorFactory, withId: "CupertinoNativePullDownButtonAnchor")
      
      let popupButtonFactory = CupertinoNativePopupButtonFactory(messenger: registrar.messenger())
      registrar.register(popupButtonFactory, withId: "CupertinoNativePopupButton")
    }

    let buttonFactory = CupertinoButtonViewFactory(messenger: registrar.messenger())
    registrar.register(buttonFactory, withId: "CupertinoNativeButton")

    let navigationBarFactory = CupertinoNavigationBarViewFactory(messenger: registrar.messenger())
    registrar.register(navigationBarFactory, withId: "CupertinoNativeNavigationBar")

    let navigationBarScrollableFactory = CupertinoNavigationBarScrollableViewFactory(messenger: registrar.messenger())
    registrar.register(navigationBarScrollableFactory, withId: "CupertinoNativeNavigationBarScrollable")

    let searchBarFactory = CupertinoSearchBarPlatformViewFactory(messenger: registrar.messenger())
    registrar.register(searchBarFactory, withId: "CupertinoNativeSearchBar")
    
    // Register native sheet header view for UiKitView integration
    let sheetHeaderFactory = CupertinoNativeSheetHeaderViewFactory(messenger: registrar.messenger())
    registrar.register(sheetHeaderFactory, withId: "CupertinoNativeSheetHeader")
    
    // Initialize action sheet handler
    // Get root view controller from the app delegate
    DispatchQueue.main.async {
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let window = windowScene.windows.first,
         let rootViewController = window.rootViewController {
        actionSheetHandler = CupertinoActionSheetHandler(messenger: registrar.messenger(), viewController: rootViewController)
        alertHandler = CupertinoAlertHandler(messenger: registrar.messenger(), viewController: rootViewController)
        sheetHandler = CupertinoSheetHandler(messenger: registrar.messenger(), viewController: rootViewController)
        customSheetHandler = CupertinoCustomSheetHandler(messenger: registrar.messenger(), viewController: rootViewController)
        searchControllerHandler = CupertinoSearchControllerHandler(messenger: registrar.messenger(), viewController: rootViewController)
        
        if #available(iOS 15.0, *) {
          ios26SearchTabBarHandler = IOS26SearchTabBarHandler(messenger: registrar.messenger(), viewController: rootViewController)
        }
      }
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
 
