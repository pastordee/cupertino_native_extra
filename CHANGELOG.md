# Changelog

All notable changes to the cupertino_native_extra plugin are documented in this file.

## [0.2.0+1] - 2025-12-03

### Added
- Comprehensive library documentation for all core modules
- Detailed class-level documentation for all public APIs
- Apple HIG (Human Interface Guidelines) alignment documentation
- SF Symbols rendering modes guide (monochrome, hierarchical, palette, multicolor)
- Button style usage guide with best practices
- Platform interface implementation guidance
- Method channel communication pattern documentation
- Color system documentation (ARGB conversion, dynamic color resolution)
- Enhanced demo application with 19 well-commented screen examples
- Best practices guides throughout codebase
- Usage examples for all major components
- Architecture overview documentation

### Changed
- Enhanced documentation in `cupertino_native.dart` with quick start guide
- Improved platform interface documentation
- Extended button style enum documentation with Apple HIG alignment
- Expanded SF Symbol class documentation with rendering mode details
- Enhanced channel parameter documentation with color conversion details
- Reorganized example demos with comprehensive comments

### Fixed
- Removed unnecessary internal documentation files
- Improved documentation clarity and consistency

### Repository
- Cleaned root directory (removed 32 unnecessary markdown files)
- Renamed `docs/` directory to `doc/` per Pub conventions
- Organized example application structure
- Improved project layout for pub.dev publication

## [0.2.0] - Earlier Release

Previous version with stable native iOS widget implementations including:
- Native Navigation Bars with liquid glass effects
- Native Toolbars with blur effects
- Native Buttons with 8 styles
- Native Sliders and Switches
- Native Segmented Controls
- Native Popup Menus and Pull-Down Buttons
- Native Tab Bars with badges
- Native Search Bars with native controller integration
- Native Action Sheets and Alerts
- Native Bottom Sheets with detents
- SF Symbols integration
- Full dark mode support
- iOS 14.0+ and macOS 11.0+ platform support

---

## Plugin Features Overview

### Navigation Components
- **CNNavigationBar** - Native iOS navigation bar with blur effect
- **CNNavigationBar.scrollable** - Large title with smooth collapse animation
- **CNToolbar** - Native iOS toolbar for top/bottom placement

### Control Components
- **CNButton** - 8 native iOS button styles
- **CNSlider** - Native iOS slider with step support
- **CNSwitch** - Native toggle switch
- **CNSegmentedControl** - Native segmented control
- **CNIcon** - SF Symbols with rendering modes

### Menu & Popup Components
- **CNPopupMenuButton** - Context menu from button
- **CNPopupButton** - Dropdown selection menu
- **CNPullDownButton** - Pull-down menu (iOS 13+)
- **CNPullDownButtonAnchor** - Anchored popup menu (iOS 14+)

### Search & Picker Components
- **CNTabBar** - Native tab bar with badges
- **CNSearchBar** - Native search bar with scope
- **CNNativeSearchController** - Fullscreen search controller

### Sheet & Dialog Components
- **CNActionSheet** - Native action sheet/menu
- **CNAlert** - Native alert dialog
- **CNSheet** - Native bottom sheet with detents

### Styling Components
- **CNSymbol** - SF Symbol description (4 rendering modes)
- **CNButtonStyle** - 8 button style options

## Platform Support

- **iOS**: 14.0 and later
- **macOS**: 11.0 and later
- **Flutter**: 3.3.0 and later
- **Dart**: 3.9.0 and later

## Breaking Changes

None in this version.

## Migration Guide

For upgrading from previous versions:
1. Update your pubspec.yaml to `cupertino_native_extra: ^0.2.0`
2. Run `flutter pub get`
3. No API changes required - fully backward compatible
4. Refer to README.md and example app for best practices

## Known Issues

None currently known.

## Contributing

See GitHub repository for contribution guidelines.

## License

Licensed under the License file included in the repository.
