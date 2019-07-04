import 'dart:async';

import 'package:flutter/services.dart';

import 'rc_method_key.dart';

class RongcloudRtcPlugin {
  static const MethodChannel _channel =
      const MethodChannel('rongcloud_rtc_plugin');

  static void init(String appKey) {
    _channel.invokeMethod(MethodKey.Init,appKey);
  }
  
  static Future<int> connect(String imToken) async {
    int code = await _channel.invokeMethod(MethodKey.Connect,imToken);
    return code;
  }

  static void joinRTCRoom(String roomId) {
    _channel.invokeMethod(MethodKey.JoinRTCRoom,roomId);
  }

  static void leaveRTCRoom(String roomId) {
    _channel.invokeMethod(MethodKey.LeaveRTCRoom,roomId);
  }
}
