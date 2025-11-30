# Native Search Controller Implementation

## Overview
Implemented a native iOS fullscreen search controller that appears modally when triggered from any location in the app. This provides a native `UISearchController` experience with automatic keyboard focus and native animations.

## Features
- **Modal Fullscreen Search**: Takes over the entire screen with native iOS animations
- **Keyboard Integration**: Automatic keyboard focus with configurable keyboard type
- **Callbacks**: Real-time search text changes, submission, and cancellation callbacks
- **Keyboard Customization**: Support for keyboard type, appearance, return key type, autocapitalization, autocorrection, and spell checking
- **Color Customization**: Configurable search bar background, text field background, and tint colors
- **Easy Integration**: Simple `show()` and `hide()` methods

## Implementation

### Dart Side (`lib/components/native_search_controller.dart`)
```dart
final controller = CNNativeSearchController();

await controller.show(
  placeholder: 'Search items',
  keyboardType: CNKeyboardType.defaultType,
  onTextChanged: (query) {
    print('Search text: $query');
  },
  onSubmitted: (query) {
    print('Search submitted: $query');
  },
  onCancelled: () {
    print('Search cancelled');
  },
);
```

### Swift Side (`ios/Classes/Handlers/CupertinoSearchControllerHandler.swift`)
- Uses native `UISearchController` for authentic iOS appearance
- Implements `UISearchResultsUpdating` for real-time text changes
- Implements `UISearchBarDelegate` for search submission and cancellation
- Properly handles keyboard configuration via index-based enum mapping
- Supports all keyboard types, appearances, and text settings

### Plugin Registration
- Added to `CupertinoNativePlugin.swift` initialization
- Method channel: `"cupertino_native_search_controller"`
- Exported in `lib/cupertino_native.dart`

## API Reference

### `CNNativeSearchController`

#### Methods

##### `show()`
Shows the native search controller modally.

**Parameters:**
- `placeholder` (String): Placeholder text for the search bar (default: 'Search')
- `keyboardType` (CNKeyboardType): Type of keyboard to display
- `keyboardAppearance` (CNKeyboardAppearance): Keyboard appearance (light/dark)
- `returnKeyType` (CNReturnKeyType): Return key type (e.g., search, done, go)
- `enablesReturnKeyAutomatically` (bool): Whether to enable return key when text exists
- `autocapitalizationType` (CNAutocapitalizationType): Auto-capitalization behavior
- `autocorrectionType` (CNAutocorrectionType): Auto-correction behavior
- `spellCheckingType` (CNSpellCheckingType): Spell checking behavior
- `barTintColor` (int?): ARGB color for search bar background
- `tintColor` (int?): ARGB color for search bar elements
- `searchFieldBackgroundColor` (int?): ARGB color for text field background
- `onTextChanged` (ValueChanged<String>?): Called when search text changes
- `onSubmitted` (ValueChanged<String>?): Called when search is submitted
- `onCancelled` (VoidCallback?): Called when search is cancelled

##### `hide()`
Hides/dismisses the search controller.

##### `updateSearchText(String text)`
Updates the search text programmatically.

##### `dispose()`
Cleans up resources and listeners.

## Supported Keyboard Types
- `defaultType` - Default keyboard
- `asciiCapable` - ASCII keyboard
- `numbersAndPunctuation` - Number and punctuation
- `url` - URL keyboard
- `numberPad` - Number pad
- `phonePad` - Phone pad
- `namePhonePad` - Name and phone pad
- `emailAddress` - Email keyboard
- `decimalPad` - Decimal pad
- `twitter` - Twitter keyboard
- `webSearch` - Web search keyboard

## Files Modified/Created

### New Files
- `ios/Classes/Handlers/CupertinoSearchControllerHandler.swift` - Native handler
- `lib/components/native_search_controller.dart` - Dart wrapper
- `example/lib/demos/native_search_controller_demo.dart` - Demo page

### Modified Files
- `ios/Classes/CupertinoNativePlugin.swift` - Added handler initialization
- `lib/cupertino_native.dart` - Exported new controller
- `example/lib/main.dart` - Added demo to main menu

## Demo Usage
The demo page (`native_search_controller_demo.dart`) shows:
- How to instantiate the controller
- Opening the fullscreen search interface
- Handling search text changes via callback
- Displaying current search status
- Proper disposal of controller resources

## Integration Pattern
The search controller can be called from anywhere in your app:
```dart
// From a button tap
onPressed: () async {
  await searchController.show(...);
}

// From a navigation bar
// From a bottom sheet
// From any callback handler
```

## Notes
- The search controller appears modally, taking over the entire screen
- Automatic keyboard focus for immediate typing experience
- Proper memory management via `dispose()` method
- Supports all existing keyboard and text configuration enums from `CNSearchBar`
- Thread-safe implementation with main thread dispatch
