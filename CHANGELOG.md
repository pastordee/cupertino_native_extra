## 0.2.0 - Extended Fork Release

### Added
- **iOS 26+ Native Tab Bar (Experimental)**: New `CNNativeTabBar` implementation providing true native UITabBarController experience
  - Native tab bar with search support via `isSearchTab` property
  - Proper Flutter view embedding using wrapper view controller pattern
  - Search tab with UISearchController and expand/collapse functionality
  - Complete demo page with navigation and search functionality

- **Enhanced Sheet Components**:
  - `dismissOnTap` property for `CNSheetInlineAction` to automatically dismiss sheets
  - Improved inline action handling

- **Comprehensive Documentation**:
  - Attribution to original `serverpod/cupertino_native`
  - Installation via Git instead of pub.dev
  - Updated examples for new native components

### Changed
- Repository migrated to GitHub: `pastordee/cupertino_native_extra`
- Tab bar architecture to support native UITabBarController
- Updated demo pages for native tab bar showcase
- Improved error handling in Swift method channels

### Fixed
- Syntax error in demo (stray character removed)
- Sheet inline action dismissal behavior
- Search tab interaction handling

### Known Limitations
- iOS 13.0+ only (iOS 26 UI appearance on iOS 14+)
- macOS support available but styling pending
- FlutterViewController has strict UIKit hierarchy requirements

### Attribution
This extended fork extends and maintains compatibility with the original `serverpod/cupertino_native` package.
Original source: https://github.com/serverpod/cupertino_native

## 0.1.1

* Adds link to blog post in readme.

## 0.1.0

* Cleaned up API.
* Added polished (somewhat) examples.
* Compiles and runs on MacOS.
* Much improved readme file.
* Dart doc and analyzer requirement.

## 0.0.1

* Initial release (to reserve pub name).
