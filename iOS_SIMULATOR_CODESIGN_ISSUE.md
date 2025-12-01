# iOS Simulator Code Signing Issue - Xcode 26 Workaround

## Problem
When building for iOS simulator on macOS 14.8+ with Xcode 26.1+, you may encounter the following error:

```
Failed to build iOS app
Uncategorized (Xcode): Command CodeSign failed with a nonzero exit code
resource fork, Finder information, or similar detritus not allowed
Target debug_unpack_ios failed
```

This is a known issue where the Flutter framework extracted for the simulator build contains extended attributes that Xcode's code signing cannot handle.

## Why It Happens
- Xcode 26.1+ has stricter code signing validation
- The Flutter framework in the cache may have extended attributes (xattr) from downloads
- These attributes cause the codesign tool to fail with "detritus not allowed" error
- This **only affects simulator builds** - physical device builds work fine

## Solutions

### Solution 1: Build on a Real Device (Recommended)
Since the issue only affects simulator builds and you've confirmed it works on real devices, the simplest solution is to test on an actual device:

```bash
flutter run
# Select your real device instead of the simulator
```

### Solution 2: Clean Extended Attributes (Temporary Fix)
You can temporarily remove extended attributes, but they may reappear after Flutter rebuilds artifacts:

```bash
find ~/Development/flutter/bin/cache/artifacts/engine/ios -name "*.framework" -type d -exec xattr -c {} \;
find ~/Library/Developer/Xcode/DerivedData -name "*.framework" -type d -exec xattr -c {} \;
```

Then try rebuilding:
```bash
flutter clean
flutter pub get
flutter run
```

### Solution 3: Downgrade Xcode (If Necessary)
If you must use the simulator and the above solutions don't work, consider using an earlier version of Xcode (< 26.0) or wait for Flutter to release a fix.

## Workaround Configuration
A Podfile post_install hook has been added to attempt to configure code signing more leniently for simulator builds, but due to Flutter's internal build process, this may not fully resolve the issue.

See `ios/Podfile` for details.
