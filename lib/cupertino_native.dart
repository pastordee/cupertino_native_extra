// Public exports and convenience API for the plugin.

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
