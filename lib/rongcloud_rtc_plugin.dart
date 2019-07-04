import 'dart:async';

import 'package:flutter/services.dart';

class RongcloudRtcPlugin {
  static const MethodChannel _channel =
      const MethodChannel('rongcloud_rtc_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
