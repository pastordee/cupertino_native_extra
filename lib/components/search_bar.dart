import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

/// A native iOS UISearchBar widget.
///
/// This widget displays a native iOS UISearchBar using platform channels,
/// providing authentic iOS search experience following Apple HIG guidelines.
///
/// **Features:**
/// - Native UISearchBar rendering
/// - Descriptive placeholder text support
/// - Search bar styles (default, prominent, minimal)
/// - Scope bar for filtering
/// - Show/hide cancel button
/// - Keyboard types and appearance
/// - Return key types
/// - Voice search button (iOS 14+)
///
/// **Example:**
/// ```dart
/// CNSearchBar(
///   placeholder: 'Shows, Movies, and More',
///   showsCancelButton: true,
///   showsScopeBar: true,
///   scopeButtonTitles: ['All', 'Movies', 'TV Shows'],
///   selectedScopeIndex: 0,
///   onTextChanged: (text) => performSearch(text),
///   onSearchButtonClicked: (text) => submitSearch(text),
/// )
/// ```
class CNSearchBar extends StatefulWidget {
  /// Creates a native iOS search bar.
  const CNSearchBar({
    super.key,
    this.placeholder,
    this.text,
    this.prompt,
    this.showsCancelButton = false,
    this.showsBookmarkButton = false,
    this.showsSearchResultsButton = false,
    this.searchBarStyle = CNSearchBarStyle.defaultStyle,
    this.barTintColor,
    this.tintColor,
    this.searchFieldBackgroundColor,
    this.showsScopeBar = false,
    this.scopeButtonTitles = const [],
    this.selectedScopeIndex = 0,
    this.keyboardType = CNKeyboardType.defaultType,
    this.keyboardAppearance = CNKeyboardAppearance.defaultAppearance,
    this.returnKeyType = CNReturnKeyType.search,
    this.enablesReturnKeyAutomatically = true,
    this.autocapitalizationType = CNAutocapitalizationType.none,
    this.autocorrectionType = CNAutocorrectionType.defaultType,
    this.spellCheckingType = CNSpellCheckingType.defaultType,
    this.onTextChanged,
    this.onSearchButtonClicked,
    this.onCancelButtonClicked,
    this.onScopeChanged,
    this.onBookmarkButtonClicked,
    this.height = 56.0,
  });

  /// Placeholder text (e.g., "Shows, Movies, and More")
  final String? placeholder;

  /// Initial search text
  final String? text;

  /// Prompt text displayed above the search bar
  final String? prompt;

  /// Whether to show the cancel button
  final bool showsCancelButton;

  /// Whether to show the bookmark button
  final bool showsBookmarkButton;

  /// Whether to show the search results button
  final bool showsSearchResultsButton;

  /// Visual style of the search bar
  final CNSearchBarStyle searchBarStyle;

  /// Background tint color for the search bar
  final Color? barTintColor;

  /// Tint color for search bar elements
  final Color? tintColor;

  /// Background color for the search text field
  final Color? searchFieldBackgroundColor;

  /// Whether to show the scope bar
  final bool showsScopeBar;

  /// Titles for scope bar buttons
  final List<String> scopeButtonTitles;

  /// Selected scope bar index
  final int selectedScopeIndex;

  /// Keyboard type
  final CNKeyboardType keyboardType;

  /// Keyboard appearance (light/dark)
  final CNKeyboardAppearance keyboardAppearance;

  /// Return key type
  final CNReturnKeyType returnKeyType;

  /// Whether return key is enabled only when there's text
  final bool enablesReturnKeyAutomatically;

  /// Auto-capitalization behavior
  final CNAutocapitalizationType autocapitalizationType;

  /// Auto-correction behavior
  final CNAutocorrectionType autocorrectionType;

  /// Spell checking behavior
  final CNSpellCheckingType spellCheckingType;

  /// Called when search text changes
  final ValueChanged<String>? onTextChanged;

  /// Called when search button is clicked
  final ValueChanged<String>? onSearchButtonClicked;

  /// Called when cancel button is clicked
  final VoidCallback? onCancelButtonClicked;

  /// Called when scope selection changes
  final ValueChanged<int>? onScopeChanged;

  /// Called when bookmark button is clicked
  final VoidCallback? onBookmarkButtonClicked;

  /// Height of the search bar
  final double height;

  @override
  State<CNSearchBar> createState() => _CNSearchBarState();
}

class _CNSearchBarState extends State<CNSearchBar> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = {
      'placeholder': widget.placeholder ?? 'Search',
      'text': widget.text ?? '',
      if (widget.prompt != null) 'prompt': widget.prompt,
      'showsCancelButton': widget.showsCancelButton,
      'showsBookmarkButton': widget.showsBookmarkButton,
      'showsSearchResultsButton': widget.showsSearchResultsButton,
      'searchBarStyle': widget.searchBarStyle.index,
      if (widget.barTintColor != null)
        'barTintColor': _colorToARGB(widget.barTintColor!),
      if (widget.tintColor != null)
        'tintColor': _colorToARGB(widget.tintColor!),
      if (widget.searchFieldBackgroundColor != null)
        'searchFieldBackgroundColor': _colorToARGB(
          widget.searchFieldBackgroundColor!,
        ),
      'showsScopeBar': widget.showsScopeBar,
      'scopeButtonTitles': widget.scopeButtonTitles,
      'selectedScopeIndex': widget.selectedScopeIndex,
      'keyboardType': widget.keyboardType.index,
      'keyboardAppearance': widget.keyboardAppearance.index,
      'returnKeyType': widget.returnKeyType.index,
      'enablesReturnKeyAutomatically': widget.enablesReturnKeyAutomatically,
      'autocapitalizationType': widget.autocapitalizationType.index,
      'autocorrectionType': widget.autocorrectionType.index,
      'spellCheckingType': widget.spellCheckingType.index,
    };

    return SizedBox(
      height: widget.height + (widget.showsScopeBar ? 44.0 : 0.0),
      child: UiKitView(
        viewType: 'CupertinoNativeSearchBar',
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }

  void _onPlatformViewCreated(int viewId) {
    _channel = MethodChannel('CupertinoNativeSearchBar_$viewId');
    _channel!.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments as String;
        widget.onTextChanged?.call(text);
        break;
      case 'onSearchButtonClicked':
        final text = call.arguments as String;
        widget.onSearchButtonClicked?.call(text);
        break;
      case 'onCancelButtonClicked':
        widget.onCancelButtonClicked?.call();
        break;
      case 'onScopeChanged':
        final index = call.arguments as int;
        widget.onScopeChanged?.call(index);
        break;
      case 'onBookmarkButtonClicked':
        widget.onBookmarkButtonClicked?.call();
        break;
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  /// Helper to convert Color to ARGB int
  int _colorToARGB(Color color) {
    return ((color.a * 255).round() << 24) |
        ((color.r * 255).round() << 16) |
        ((color.g * 255).round() << 8) |
        (color.b * 255).round();
  }
}

/// Search bar visual style
enum CNSearchBarStyle {
  /// Default search bar style
  defaultStyle,

  /// Prominent search bar style
  prominent,

  /// Minimal search bar style
  minimal,
}

/// Keyboard type
enum CNKeyboardType {
  /// Default keyboard
  defaultType,

  /// ASCII keyboard
  asciiCapable,

  /// Number and punctuation keyboard
  numbersAndPunctuation,

  /// URL keyboard
  url,

  /// Number pad
  numberPad,

  /// Phone pad
  phonePad,

  /// Name and phone pad
  namePhonePad,

  /// Email keyboard
  emailAddress,

  /// Decimal pad
  decimalPad,

  /// Twitter keyboard
  twitter,

  /// Web search keyboard
  webSearch,

  /// ASCII capable number pad
  asciiCapableNumberPad,
}

/// Keyboard appearance
enum CNKeyboardAppearance {
  /// Default appearance
  defaultAppearance,

  /// Light keyboard
  light,

  /// Dark keyboard
  dark,
}

/// Return key type
enum CNReturnKeyType {
  /// Default return key
  defaultType,

  /// Go
  go,

  /// Google
  google,

  /// Join
  join,

  /// Next
  next,

  /// Route
  route,

  /// Search
  search,

  /// Send
  send,

  /// Yahoo
  yahoo,

  /// Done
  done,

  /// Emergency call
  emergencyCall,

  /// Continue
  continueType,
}

/// Auto-capitalization type
enum CNAutocapitalizationType {
  /// No auto-capitalization
  none,

  /// Capitalize words
  words,

  /// Capitalize sentences
  sentences,

  /// Capitalize all characters
  allCharacters,
}

/// Auto-correction type
enum CNAutocorrectionType {
  /// Default behavior
  defaultType,

  /// Disable auto-correction
  no,

  /// Enable auto-correction
  yes,
}

/// Spell checking type
enum CNSpellCheckingType {
  /// Default behavior
  defaultType,

  /// Disable spell checking
  no,

  /// Enable spell checking
  yes,
}
