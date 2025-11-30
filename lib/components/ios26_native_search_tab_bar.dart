import 'package:flutter/services.dart';

/// iOS 26+ Native Tab Bar with Search Support
///
/// This widget enables the native iOS 26 tab bar with search functionality.
/// When enabled, it replaces the Flutter app's root with a native UITabBarController.
///
/// This is an alternative to the standard Flutter tab bar that provides true native
/// iOS behavior with the ability to transform the tab bar into a search interface.
///
/// **Important**: This is an experimental API and may significantly impact your app's
/// navigation structure. Use with caution.
///
/// **Example:**
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   IOS26NativeSearchTabBar.enable(
///     tabs: [
///       const NativeTabConfig(title: 'Home', sfSymbol: 'house.fill'),
///       const NativeTabConfig(
///         title: 'Search',
///         sfSymbol: 'magnifyingglass',
///         isSearchTab: true,
///       ),
///       const NativeTabConfig(title: 'Profile', sfSymbol: 'person.fill'),
///     ],
///     onTabSelected: (index) {
///       print('Tab selected: $index');
///     },
///     onSearchQueryChanged: (query) {
///       print('Search query: $query');
///     },
///   );
/// }
/// ```
class IOS26NativeSearchTabBar {
  static const MethodChannel _channel = MethodChannel(
    'cupertino_native/ios26_search_tab_bar',
  );

  static bool _isEnabled = false;

  /// Enable native tab bar mode
  ///
  /// This will replace your app's root view controller with a native
  /// UITabBarController. Your Flutter content will be displayed within
  /// the selected tab.
  ///
  /// Parameters:
  /// - [tabs]: List of tab configurations defining each tab's appearance and behavior
  /// - [selectedIndex]: The initially selected tab index (default: 0)
  /// - [onTabSelected]: Called when user taps a non-search tab
  /// - [onSearchQueryChanged]: Called when user types in the search bar
  /// - [onSearchSubmitted]: Called when user presses search/return key
  /// - [onSearchCancelled]: Called when user dismisses the search interface
  static Future<void> enable({
    required List<NativeTabConfig> tabs,
    int selectedIndex = 0,
    void Function(int index)? onTabSelected,
    void Function(String query)? onSearchQueryChanged,
    void Function(String query)? onSearchSubmitted,
    VoidCallback? onSearchCancelled,
  }) async {
    if (_isEnabled) {
      print('[IOS26NativeSearchTabBar] Already enabled, skipping');
      return;
    }

    // Setup method call handler for callbacks
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTabSelected':
          final index = call.arguments['index'] as int;
          onTabSelected?.call(index);
          break;
        case 'onSearchQueryChanged':
          final query = call.arguments['query'] as String;
          onSearchQueryChanged?.call(query);
          break;
        case 'onSearchSubmitted':
          final query = call.arguments['query'] as String;
          onSearchSubmitted?.call(query);
          break;
        case 'onSearchCancelled':
          onSearchCancelled?.call();
          break;
      }
    });

    try {
      print('[IOS26NativeSearchTabBar] Enabling native tab bar...');
      // Enable native tab bar
      await _channel.invokeMethod('enableNativeTabBar', {
        'tabs': tabs
            .map(
              (tab) => {
                'title': tab.title,
                'sfSymbol': tab.sfSymbol,
                'isSearch': tab.isSearchTab,
              },
            )
            .toList(),
        'selectedIndex': selectedIndex,
      });
      _isEnabled = true;
      print('[IOS26NativeSearchTabBar] Native tab bar enabled successfully');
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error enabling native tab bar: $e');
      rethrow;
    }
  }

  /// Disable native tab bar and return to Flutter-only mode
  static Future<void> disable() async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _channel.invokeMethod('disableNativeTabBar');
      _isEnabled = false;
      print('[IOS26NativeSearchTabBar] Native tab bar disabled');
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error disabling native tab bar: $e');
      rethrow;
    }
  }

  /// Set the selected tab index
  static Future<void> setSelectedIndex(int index) async {
    try {
      await _channel.invokeMethod('setSelectedIndex', {'index': index});
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error setting selected index: $e');
      rethrow;
    }
  }

  /// Show the search bar (activates the search controller)
  static Future<void> showSearch() async {
    try {
      await _channel.invokeMethod('showSearch');
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error showing search: $e');
      rethrow;
    }
  }

  /// Hide the search bar
  static Future<void> hideSearch() async {
    try {
      await _channel.invokeMethod('hideSearch');
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error hiding search: $e');
      rethrow;
    }
  }

  /// Check if native tab bar is currently enabled
  static Future<bool> isEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isEnabled');
      return result ?? false;
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error checking if enabled: $e');
      return false;
    }
  }

  /// Get current tab index
  static Future<int> getCurrentTabIndex() async {
    try {
      final result = await _channel.invokeMethod<int>('getCurrentTabIndex');
      return result ?? 0;
    } catch (e) {
      print('[IOS26NativeSearchTabBar] Error getting current tab index: $e');
      return 0;
    }
  }
}

/// Configuration for a native tab
class NativeTabConfig {
  /// The title of the tab
  final String title;

  /// SF Symbol name for the tab icon (iOS only)
  ///
  /// Example: 'house.fill', 'magnifyingglass', 'person.fill'
  final String? sfSymbol;

  /// Whether this tab is a search tab
  ///
  /// Only one tab should be marked as a search tab.
  /// When selected, the tab bar will transform into a search bar on iOS 26+.
  final bool isSearchTab;

  const NativeTabConfig({
    required this.title,
    this.sfSymbol,
    this.isSearchTab = false,
  });
}
