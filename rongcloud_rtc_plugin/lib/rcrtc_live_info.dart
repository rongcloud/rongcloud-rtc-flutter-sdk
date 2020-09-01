import 'dart:convert';

import 'package:flutter/services.dart';

import 'rcrtc_mix_config.dart';

class RCRTCLiveInfo {
  static final _channelTag = "rong.flutter.rtclib/LiveInfo:";
  static final _methodAddStreamUrl = "addPublishStreamUrl";
  static final _methodremoveStreamUrl = "removePublishStreamUrl";
  static final _methodSetMixConfig = "setMixConfig";

  final String roomId;
  final String liveUrl;
  final String userId;
  MethodChannel _channel;

  RCRTCLiveInfo.fromJSON(info)
      : roomId = info['roomId'],
        liveUrl = info['liveUrl'],
        userId = info['userId'] {
    _channel = MethodChannel("$_channelTag$liveUrl");
  }

  Future<dynamic> addPublishStreamUrl(String url) async {
    await _channel.invokeMethod(_methodAddStreamUrl);
  }

  Future<dynamic> removePublishStreamUrl(String url) async {
    await _channel.invokeMethod(_methodremoveStreamUrl);
  }

  Future<dynamic> setMixConfig(RCRTCMixConfig config) async {
    await _channel.invokeMethod(_methodSetMixConfig, jsonEncode(config));
  }
}
