import 'dart:convert';

import 'package:flutter/services.dart';

import 'rcrtc_error_code.dart';
import 'rcrtc_mix_config.dart';

class RCRTCLiveInfo {
  final String roomId;
  final String liveUrl;
  final String userId;
  late MethodChannel _channel;

  RCRTCLiveInfo.fromJSON(info)
      : roomId = info['roomId'],
        liveUrl = info['liveUrl'],
        userId = info['userId'] {
    _channel = MethodChannel("rong.flutter.rtclib/LiveInfo:$roomId");
  }

  Future<RCRTCCodeResult<List<String>>> addPublishStreamUrl(String url) async {
    Map<dynamic, dynamic> map = await _channel.invokeMethod("addPublishStreamUrl", url);
    int code = map["code"];
    RCRTCCodeResult<List<String>> result = RCRTCCodeResult(code);
    if (code == 0) {
      List<dynamic> temp = map["data"];
      List<String> list = [];
      temp.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      result.object = list;
    } else {
      result.reason = map["data"];
    }
    return result;
  }

  Future<RCRTCCodeResult<List<String>>> removePublishStreamUrl(String url) async {
    Map<dynamic, dynamic> map = await _channel.invokeMethod("removePublishStreamUrl", url);
    int code = map["code"];
    RCRTCCodeResult<List<String>> result = RCRTCCodeResult(code);
    if (code == 0) {
      List<dynamic> temp = map["data"];
      List<String> list = [];
      temp.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
    } else {
      result.reason = map["data"];
    }
    return result;
  }

  Future<int> setMixConfig(RCRTCMixConfig config) async {
    int? ret = await _channel.invokeMethod("setMixConfig", jsonEncode(config));
    return ret ?? -1;
  }
}
