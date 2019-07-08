import 'package:flutter/services.dart';
import 'dart:async';

import 'method_key.dart';

class RongRtcEngine {
  static const MethodChannel _channel =
      const MethodChannel('plugins.rongcloud.im/rtc_plugin');

  static Future<int> joinRTCRoom(String roomId) async {
    int code = await _channel.invokeMethod(MethodKey.JoinRTCRoom,roomId);
    return code;
  }

  static Future<int> leaveRTCRoom(String roomId) async {
    int code = await _channel.invokeMethod(MethodKey.LeaveRTCRoom,roomId);
    return code;
  }

  static void renderVideoView(String userId) {
      _channel.invokeMethod(MethodKey.RenderVideoView,userId);
  }

  static void publishAVStream() {
    _channel.invokeMethod(MethodKey.PublishAVStream);
  }

  static void unpublishAVStream() {
    _channel.invokeMethod(MethodKey.UnpublishAVStream);
  }
}