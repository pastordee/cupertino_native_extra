/// Cupertino Native Extra - Native iOS widgets for Flutter
///
/// This plugin provides pixel-perfect native iOS widgets with liquid glass
/// effects, using native UIKit rendering for authentic Apple design language
/// implementation. All widgets support dark mode and iOS 14+ features.
///
/// ## Quick Start
///
/// Import the package:
/// ```dart
/// import 'package:cupertino_native_extra/cupertino_native.dart';
/// ```
///
/// ## Core Components
///
/// ### Navigation
/// - [CNNavigationBar] - Native iOS navigation bar with blur effect
/// - [CNNavigationBar.scrollable] - Large title with smooth collapse animation
/// - [CNToolbar] - Native iOS toolbar for top/bottom placement
///
/// ### Controls
/// - [CNButton] - 8 native iOS button styles
/// - [CNSlider] - Native iOS slider with step support
/// - [CNSwitch] - Native toggle switch
/// - [CNSegmentedControl] - Native segmented control
///
/// ### Menus & Popups
/// - [CNPopupMenuButton] - Context menu from button
/// - [CNPopupButton] - Dropdown selection menu
/// - [CNPullDownButton] - Pull-down menu (iOS 13+)
/// - [CNPullDownButtonAnchor] - Anchored popup menu (iOS 14+)
///
/// ### Pickers & Search
/// - [CNTabBar] - Native tab bar with badges
/// - [CNSearchBar] - Native search bar with scope
/// - [CNNativeSearchController] - Fullscreen search (iOS 16+)
///
/// ### Sheets & Dialogs
/// - [CNActionSheet] - Native action sheet/menu
/// - [CNAlert] - Native alert dialog
/// - [CNSheet] - Native bottom sheet with detents
///
/// ### Styling
/// - [CNIcon] - SF Symbols with rendering modes
/// - [CNSymbol] - SF Symbol description
/// - [CNButtonStyle] - 8 button style options
///
/// ## Key Features
///
/// - **Pixel-Perfect**: True native UIKit rendering
/// - **Liquid Glass**: Frosted glass blur effects
/// - **Dark Mode**: Full light/dark mode support
/// - **Accessibility**: Native accessibility integration
/// - **Performance**: Hardware-accelerated animations
/// - **Type-Safe**: Full Dart type safety
///
/// ## Platform Support
///
/// - iOS 14.0+
/// - macOS 11.0+
///
/// ## Architecture
///
/// The plugin uses:
/// - Platform channels for Swift/Objective-C communication
/// - UIKit/AppKit for native rendering
/// - Method channels for configuration
/// - PlatformView for widget embedding
///
/// ## Example
///
/// ```dart
/// CNButton(
///   label: 'Save',
///   style: CNButtonStyle.filled,
///   onPressed: () => print('Tapped'),
/// )
/// ```
library;

export 'cupertino_native_platform_interface.dart';
export 'cupertino_native_method_channel.dart';
export 'components/slider.dart';
export 'components/switch.dart';
export 'components/segmented_control.dart';
export 'components/icon.dart';
export 'components/tab_bar.dart';
export 'components/popup_menu_button.dart';
export 'components/pull_down_button.dart';
export 'components/pull_down_button_anchor.dart';
export 'components/popup_button.dart';
export 'components/navigation_bar.dart';
export 'components/toolbar.dart';
export 'components/bottom_toolbar.dart';
export 'components/transforming_toolbar.dart';
export 'components/search_field.dart';
export 'components/search_bar.dart';
export 'components/search_config.dart'; // Search configuration
export 'components/native_search_controller.dart'; // Native fullscreen search
export 'components/ios26_native_search_tab_bar.dart'; // iOS 26+ native tab bar (Option B)
export 'components/action_sheet.dart';
export 'components/alert.dart';
export 'components/sheet.dart'; // Exports both native_sheet and custom_sheet
export 'style/sf_symbol.dart';
export 'style/button_style.dart';
export 'components/button.dart';

import 'cupertino_native_platform_interface.dart';

/// Top-level facade for simple plugin interactions.
class CupertinoNative {
  /// Returns a user-friendly platform version string supplied by the
  /// platform implementation.
  Future<String?> getPlatformVersion() {
    return CupertinoNativePlatform.instance.getPlatformVersion();
  }
}
