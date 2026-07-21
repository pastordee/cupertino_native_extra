import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cupertino_native_platform_interface.dart';

/// Method channel implementation of [CupertinoNativePlatform].
///
/// This class communicates with native iOS/macOS code through Flutter's
/// method channel system. It serves as the bridge between Dart and native
/// code for widget configuration and platform queries.
///
/// ## Method Channel Details
///
/// Channel name: `cupertino_native`
///
/// Available methods:
/// - `getPlatformVersion`: Returns the native platform version string
/// - Other methods for widget-specific configuration (handled per-widget)
///
/// ## Communication Pattern
///
/// 1. Dart calls async method on channel
/// 2. Native handler receives and processes
/// 3. Result is returned back to Dart
/// 4. Exceptions propagate through PlatformException
class MethodChannelCupertinoNative extends CupertinoNativePlatform {
  /// The method channel used to interact with the native platform.
  ///
  /// This channel name "cupertino_native" must match the channel name
  /// defined in the native iOS/macOS implementation.
  @visibleForTesting
  final methodChannel = const MethodChannel('cupertino_native');

  @override
  /// See [CupertinoNativePlatform.getPlatformVersion].
  ///
  /// Invokes the native `getPlatformVersion` method and returns the result.
  /// Returns null if the method is not implemented on the native side.
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
