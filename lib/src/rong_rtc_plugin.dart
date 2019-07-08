import 'dart:async';

import 'package:flutter/services.dart';

import 'method_key.dart';

class RongRtcPlugin {
  static const MethodChannel _channel =
      const MethodChannel('plugins.rongcloud.im/rtc_plugin');

  static void init(String appKey) {
    _channel.invokeMethod(MethodKey.Init,appKey);
  }
  
  static Future<int> connect(String imToken) async {
    int code = await _channel.invokeMethod(MethodKey.Connect,imToken);
    return code;
  }

}