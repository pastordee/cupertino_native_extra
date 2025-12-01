import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCupertinoNativePlatform
    with MockPlatformInterfaceMixin
    implements CupertinoNativePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CupertinoNativePlatform initialPlatform =
      CupertinoNativePlatform.instance;

  test('$MethodChannelCupertinoNative is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCupertinoNative>());
  });

  test('getPlatformVersion', () async {
    CupertinoNative cupertinoNativePlugin = CupertinoNative();
    MockCupertinoNativePlatform fakePlatform = MockCupertinoNativePlatform();
    CupertinoNativePlatform.instance = fakePlatform;

    expect(await cupertinoNativePlugin.getPlatformVersion(), '42');
  });
}
