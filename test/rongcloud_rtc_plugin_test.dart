import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('rongcloud_rtc_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await RongcloudRtcPlugin.platformVersion, '42');
  });
}
