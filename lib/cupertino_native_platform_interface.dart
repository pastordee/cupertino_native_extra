import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cupertino_native_method_channel.dart';

/// Platform interface for Cupertino Native Extra plugin.
///
/// This abstract class defines the interface that platform-specific implementations
/// (iOS, macOS) must extend to provide native widget functionality.
///
/// ## Implementation Details
///
/// Platform implementations should:
/// 1. Extend this class
/// 2. Register themselves during plugin initialization
/// 3. Override all abstract methods
/// 4. Handle platform-specific native code integration
///
/// The default implementation uses method channels to communicate with
/// native code through [MethodChannelCupertinoNative].
abstract class CupertinoNativePlatform extends PlatformInterface {
  /// Constructs a CupertinoNativePlatform.
  CupertinoNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static CupertinoNativePlatform _instance = MethodChannelCupertinoNative();

  /// The default instance of [CupertinoNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelCupertinoNative].
  static CupertinoNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CupertinoNativePlatform] when
  /// they register themselves.
  static set instance(CupertinoNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Retrieves a user-visible platform version string from the host platform.
  ///
  /// Returns a string like "iOS 14.5" or "macOS 11.3" depending on the
  /// underlying native platform and its version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
