[![Serverpod Liquid Glass Flutter banner](https://github.com/serverpod/cupertino_native/raw/main/misc/banner.jpg)](https://serverpod.dev)

> **Attribution**: This package is an extended fork of [`serverpod/cupertino_native`](https://github.com/serverpod/cupertino_native). All credit for the original Liquid Glass implementation, architecture, and core components goes to the Serverpod team. This fork adds experimental features and enhancements while maintaining full compatibility with the original design.

_Original package is part of Serverpod's open-source initiative. [Serverpod](https://serverpod.dev) is the ultimate backend for Flutter - all written in Dart, free, and open-source. 👉 [Check it out](https://serverpod.dev)_

# Liquid Glass for Flutter (Extended)

Native Liquid Glass widgets for iOS and macOS in Flutter with pixel‑perfect fidelity.

This plugin hosts real UIKit/AppKit controls inside Flutter using Platform Views and method channels. It matches native look/feel perfectly while still fitting naturally into Flutter code.

Does it work and is it fast? Yes. Is it a vibe-coded Frankenstein's monster patched together with duct tape? Also yes.

This package is a proof of concept for bringing Liquid Glass to Flutter. Contributions are most welcome. What we have here can serve as a great starting point for building a complete, polished library. The vision for this package is to bridge the gap until we have a good, new Cupertino library written entirely in Flutter. To move toward completeness, we can also improve parts that are easy to write in Flutter to match the new Liquid Glass style (e.g., improved `CupertinoScaffold`, theme, etc.).

Read the release blogpost: 👉 [Is it time for Flutter to leave the uncanny valley?](https://medium.com/serverpod/is-it-time-for-flutter-to-leave-the-uncanny-valley-b7f2cdb834ae)

## Installation

### From Git

Add the dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  cupertino_native:
    git:
      url: https://github.com/pastordee/cupertino_native_extra.git
      ref: main
```

Then run `flutter pub get`.

### From Original Source

To use the original Serverpod package:

```bash
flutter pub add cupertino_native
```

### Platform Requirements

Ensure your platform minimums are compatible:

- iOS `platform :ios, '14.0'` (iOS 13.0+ for native components)
- macOS 11.0+

You will also need to install the Xcode 26 beta and use `xcode-select` to set it as your default.

```bash
sudo xcode-select -s /Applications/Xcode-beta.app
```

## What's in the package

This package ships a handful of native Liquid Glass widgets. Each widget exposes a simple, Flutter‑friendly API and falls back to a reasonable Flutter implementation on non‑Apple platforms.

### Slider

![Liquid Glass Slider](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/slider.png)

```dart
double _value = 50;

CNSlider(
  value: _value,
  min: 0,
  max: 100,
  onChanged: (v) => setState(() => _value = v),
)
```

### Switch

![Liquid Glass Switch](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/switch.png)

```dart
bool _on = true;

CNSwitch(
  value: _on,
  onChanged: (v) => setState(() => _on = v),
)
```

### Segmented Control

![Liquid Glass Segmented Control](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/segmented-control.png)

```dart
int _index = 0;

CNSegmentedControl(
  labels: const ['One', 'Two', 'Three'],
  selectedIndex: _index,
  onValueChanged: (i) => setState(() => _index = i),
)
```

### Button

![Liquid Glass Button](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/button.png)

```dart
CNButton(
  label: 'Press me',
  onPressed: () {},
)

// Icon button variant
CNButton.icon(
  icon: const CNSymbol('heart.fill'),
  onPressed: () {},
)
```

### Icon (SF Symbols)

![Liquid Glass Icon](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/icon.png)

```dart
// Monochrome symbol
const CNIcon(symbol: CNSymbol('star'));

// Multicolor / hierarchical options are also supported
const CNIcon(
  symbol: CNSymbol('paintpalette.fill'),
  mode: CNSymbolRenderingMode.multicolor,
)
```

### Popup Menu Button

![Liquid Glass Popup Menu Button](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/popup-menu-button.png)

```dart
final items = [
  const CNPopupMenuItem(label: 'New File', icon: CNSymbol('doc', size: 18)),
  const CNPopupMenuItem(label: 'New Folder', icon: CNSymbol('folder', size: 18)),
  const CNPopupMenuDivider(),
  const CNPopupMenuItem(label: 'Rename', icon: CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18)),
];

CNPopupMenuButton(
  buttonLabel: 'Actions',
  items: items,
  onSelected: (index) {
    // Handle selection
  },
)
```

### Tab Bar

![Liquid Glass Tab Bar](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/tab-bar.png)

```dart
int _tabIndex = 0;

// Overlay this at the bottom of your page
CNTabBar(
  items: const [
    CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
    CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle')),
    CNTabBarItem(label: 'Settings', icon: CNSymbol('gearshape.fill')),
  ],
  currentIndex: _tabIndex,
  onTap: (i) => setState(() => _tabIndex = i),
)
```

## What's New in This Fork

This extended version includes experimental features and enhancements:

### iOS 26+ Native Tab Bar (Experimental - Option B)

A native UITabBarController implementation for iOS 13+/macOS 10.15+, providing true native tab bar experiences with search functionality.

```dart
// Enable native tab bar
CNNativeTabBar.enable(
  tabs: [
    CNNativeTab(
      label: 'Home',
      icon: CNSymbol('house.fill'),
      page: HomeScreen(),
    ),
    CNNativeTab(
      label: 'Search',
      icon: CNSymbol('magnifyingglass'),
      isSearchTab: true,
    ),
    CNNativeTab(
      label: 'Profile',
      icon: CNSymbol('person.crop.circle'),
      page: ProfileScreen(),
    ),
  ],
  onTabSelected: (index) {
    print('Tab $index selected');
  },
);
```

**Features:**
- Native UITabBarController for authentic iOS feel
- Built-in search tab with UISearchController
- Seamless Flutter view embedding within native tabs
- Proper lifecycle management and state handling

**Known Limitations:**
- iOS 13.0+ only (iOS 26 UI appearance on iOS 14+)
- macOS support available but styling optimizations pending
- FlutterViewController has strict UIKit hierarchy requirements

### Enhanced Native Sheets

Improved `CNCustomSheet` and `CNNativeSheet` components with:
- Dismissable inline actions via `dismissOnTap` property
- Better handling of custom content layouts
- Improved animation and transition support

```dart
CNCustomSheet(
  items: [
    CNSheetItem(title: 'Edit', icon: CNSymbol('pencil')),
    CNSheetItem(title: 'Delete', icon: CNSymbol('trash'), isDestructive: true),
  ],
  inlineActions: [
    CNSheetInlineAction(
      label: 'Done',
      dismissOnTap: true,  // NEW: Auto-dismiss on tap
    ),
  ],
)
```

## What's left to do?

Original package TODOs still apply:

- Cleaning up the code. Probably by someone who knows a bit about Swift.
- Adding more native components.
- Reviewing the Flutter APIs to ensure consistency and eliminate redundancies.
- Extending the flexibility and styling options of the widgets.
- Investigate how to best combine scroll views with the native components.
- macOS compiles and runs, but it's untested with Liquid Glass and generally doesn't look great.

**For this fork:**
- Stabilize Option B (iOS 26+ native tab bar) API
- Add comprehensive test coverage
- Expand search tab customization options
- Improve macOS support and styling

## Original Concept

How was this done? Pretty much vibe-coded with Codex and GPT-5. 😅

Read the original release blogpost: 👉 [Is it time for Flutter to leave the uncanny valley?](https://medium.com/serverpod/is-it-time-for-flutter-to-leave-the-uncanny-valley-b7f2cdb834ae)

## Resources & Attribution

- **Original Package**: [serverpod/cupertino_native](https://github.com/serverpod/cupertino_native)
- **Serverpod**: [serverpod.dev](https://serverpod.dev)
- **Flutter**: [flutter.dev](https://flutter.dev)
- **UIKit Documentation**: [Apple Developer](https://developer.apple.com/documentation/uikit)

## License

This extended fork maintains the same license as the original Serverpod package. See LICENSE file for details.

**Original Source Attribution**:
All core architecture, native UIKit integration patterns, and Liquid Glass components are derived from or inspired by [serverpod/cupertino_native](https://github.com/serverpod/cupertino_native) by the Serverpod team.
