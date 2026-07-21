import Cocoa
import FlutterMacOS

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
  private static var actionSheetHandler: CupertinoActionSheetHandler?
  private static var alertHandler: CupertinoAlertHandler?
  private static var sheetHandler: CupertinoSheetHandler?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cupertino_native", binaryMessenger: registrar.messenger)
    let instance = CupertinoNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let sliderFactory = CupertinoSliderViewFactory(messenger: registrar.messenger)
    registrar.register(sliderFactory, withId: "CupertinoNativeSlider")

    let switchFactory = CupertinoSwitchViewFactory(messenger: registrar.messenger)
    registrar.register(switchFactory, withId: "CupertinoNativeSwitch")

    let segmentedFactory = CupertinoSegmentedControlViewFactory(messenger: registrar.messenger)
    registrar.register(segmentedFactory, withId: "CupertinoNativeSegmentedControl")

    let iconFactory = CupertinoIconViewFactory(messenger: registrar.messenger)
    registrar.register(iconFactory, withId: "CupertinoNativeIcon")

    let tabBarFactory = CupertinoTabBarViewFactory(messenger: registrar.messenger)
    registrar.register(tabBarFactory, withId: "CupertinoNativeTabBar")

    let popupMenuFactory = CupertinoPopupMenuButtonViewFactory(messenger: registrar.messenger)
    registrar.register(popupMenuFactory, withId: "CupertinoNativePopupMenuButton")

    let pullDownButtonFactory = CupertinoPullDownButtonViewFactory(messenger: registrar.messenger)
    registrar.register(pullDownButtonFactory, withId: "CupertinoNativePullDownButton")

    if #available(macOS 11.0, *) {
      let popupButtonFactory = CupertinoNativePopupButtonFactory(messenger: registrar.messenger)
      registrar.register(popupButtonFactory, withId: "CupertinoNativePopupButton")
    }

    let buttonFactory = CupertinoButtonViewFactory(messenger: registrar.messenger)
    registrar.register(buttonFactory, withId: "CupertinoNativeButton")

    let navigationBarFactory = CupertinoNavigationBarViewFactory(messenger: registrar.messenger, registrar: registrar)
    registrar.register(navigationBarFactory, withId: "CupertinoNativeNavigationBar")

    let searchBarFactory = CupertinoSearchBarNSViewFactory(messenger: registrar.messenger)
    registrar.register(searchBarFactory, withId: "CupertinoNativeSearchBar")
    
    // Initialize action sheet handler
    actionSheetHandler = CupertinoActionSheetHandler(messenger: registrar.messenger)
    
    // Initialize alert handler
    alertHandler = CupertinoAlertHandler(messenger: registrar.messenger)
    
    // Initialize sheet handler
    sheetHandler = CupertinoSheetHandler(messenger: registrar.messenger)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
