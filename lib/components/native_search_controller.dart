import 'dart:async';

import 'package:flutter/services.dart';

import 'search_bar.dart';

/// Native iOS search controller that displays a fullscreen search interface.
///
/// This widget provides a native UISearchController experience, showing a
/// modal search interface with keyboard focus and native animations.
///
/// **Example:**
/// ```dart
/// final controller = CNNativeSearchController();
///
/// // Show the search controller
/// await controller.show(
///   placeholder: 'Search items',
///   onTextChanged: (query) {
///     print('Search text: $query');
///   },
///   onSubmitted: (query) {
///     print('Search submitted: $query');
///   },
///   onCancelled: () {
///     print('Search cancelled');
///   },
/// );
/// ```
class CNNativeSearchController {
  static const platform =
      MethodChannel('cupertino_native_search_controller');

  final Map<String, dynamic> _callbacks = {};
  bool _handlerSetup = false;

  /// Shows the native search controller as a modal.
  ///
  /// Parameters:
  /// - [placeholder]: Placeholder text for the search bar
  /// - [keyboardType]: Type of keyboard to display
  /// - [keyboardAppearance]: Appearance of the keyboard
  /// - [returnKeyType]: Type of return key to display
  /// - [enablesReturnKeyAutomatically]: Whether to enable return key automatically
  /// - [autocapitalizationType]: Text autocapitalization behavior
  /// - [autocorrectionType]: Text autocorrection behavior
  /// - [spellCheckingType]: Spell checking behavior
  /// - [barTintColor]: Background color of the search bar
  /// - [tintColor]: Tint color for search bar elements
  /// - [searchFieldBackgroundColor]: Background color of the search text field
  /// - [onTextChanged]: Called when search text changes
  /// - [onSubmitted]: Called when search is submitted (return key pressed)
  /// - [onCancelled]: Called when search is cancelled
  Future<void> show({
    String placeholder = 'Search',
    CNKeyboardType keyboardType = CNKeyboardType.defaultType,
    CNKeyboardAppearance keyboardAppearance =
        CNKeyboardAppearance.defaultAppearance,
    CNReturnKeyType returnKeyType = CNReturnKeyType.search,
    bool enablesReturnKeyAutomatically = true,
    CNAutocapitalizationType autocapitalizationType =
        CNAutocapitalizationType.none,
    CNAutocorrectionType autocorrectionType = CNAutocorrectionType.defaultType,
    CNSpellCheckingType spellCheckingType = CNSpellCheckingType.defaultType,
    int? barTintColor,
    int? tintColor,
    int? searchFieldBackgroundColor,
    ValueChanged<String>? onTextChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onCancelled,
  }) async {
    // Setup method call listener for callbacks (only once)
    if (!_handlerSetup) {
      _setupMethodCallHandler();
      _handlerSetup = true;
    }

    // Store callbacks
    _callbacks['onTextChanged'] = onTextChanged;
    _callbacks['onSubmitted'] = onSubmitted;
    _callbacks['onCancelled'] = onCancelled;

    try {
      print('[CNNativeSearchController] Calling show() with placeholder: $placeholder');
      await platform.invokeMethod('show', {
        'placeholder': placeholder,
        'keyboardType': keyboardType.index,
        'keyboardAppearance': keyboardAppearance.index,
        'returnKeyType': returnKeyType.index,
        'enablesReturnKeyAutomatically': enablesReturnKeyAutomatically,
        'autocapitalizationType': autocapitalizationType.index,
        'autocorrectionType': autocorrectionType.index,
        'spellCheckingType': spellCheckingType.index,
        if (barTintColor != null) 'barTintColor': barTintColor,
        if (tintColor != null) 'tintColor': tintColor,
        if (searchFieldBackgroundColor != null)
          'searchFieldBackgroundColor': searchFieldBackgroundColor,
      });
      print('[CNNativeSearchController] show() completed successfully');
    } catch (e) {
      print('[CNNativeSearchController] Error showing search controller: $e');
    }
  }

  /// Hides the search controller.
  Future<void> hide() async {
    try {
      await platform.invokeMethod('hide');
      _cleanup();
    } catch (e) {
      print('Error hiding search controller: $e');
    }
  }

  /// Updates the search text programmatically.
  Future<void> updateSearchText(String text) async {
    try {
      await platform.invokeMethod('updateSearchText', {
        'text': text,
      });
    } catch (e) {
      print('Error updating search text: $e');
    }
  }

  /// Sets up the method call handler for receiving callbacks from native code.
  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSearchTextChanged':
          final query = call.arguments?['query'] as String?;
          if (query != null) {
            (_callbacks['onTextChanged'] as ValueChanged<String>?)
                ?.call(query);
          }
          break;
        case 'onSearchSubmitted':
          final query = call.arguments?['query'] as String?;
          if (query != null) {
            (_callbacks['onSubmitted'] as ValueChanged<String>?)
                ?.call(query);
          }
          break;
        case 'onSearchCancelled':
          (_callbacks['onCancelled'] as VoidCallback?)?.call();
          _cleanup();
          break;
      }
    });
  }

  /// Cleans up resources.
  void _cleanup() {
    _callbacks.clear();
  }

  /// Disposes the controller.
  void dispose() {
    _cleanup();
  }
}
