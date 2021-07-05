import 'package:flutter/services.dart';

import '../../utils/rcrtc_log.dart';

enum MediaType {
  audio,
  video,
  application,
}

/// 当前流状态
enum RCRTCResourceState {
  /// 流处于禁用状态, 不应该订阅, 即使订阅该流也不会收到音视频数据
  forbidden,

  /// 流处于正常状态, 可以正常订阅
  normal
}

class RCRTCStream {
  static const tag = "RCRTCStream";
  static const rongTag = "RongCloudRTC";
  final MethodChannel channel;
  String _streamId;
  String _streamTag;
  MediaType _type;
  bool _mute;

  RCRTCStream.fromJson(stream)
      : _streamId = stream['streamId'],
        _streamTag = stream['tag'],
        channel = MethodChannel("rong.flutter.rtclib/Stream:${stream['streamId']}_${stream['type']}_${stream['tag']}"),
        _type = MediaType.values[stream['type']],
        _mute = stream['mute'] ?? true {
    channel.setMethodCallHandler(methodHandler);
  }

  Map<String, dynamic> toJson() => {
        'streamId': _streamId,
        'tag': _streamTag,
        'type': _type.index,
      };

  Future<dynamic> methodHandler(MethodCall call) async {
    RCRTCLog.d(tag, "methodHandler ${call.method}:${call.arguments}");
  }

  String get streamId {
    return _streamId;
  }

  MediaType get type {
    return _type;
  }

  String get streamTag {
    return _streamTag;
  }

  Future<int> mute(bool value) async {
    RCRTCLog.d(tag, "set mute $value");
    int? code = await channel.invokeMethod("mute", value);
    int ret = code ?? -1;
    if (ret == 0) _mute = value;
    RCRTCLog.d(tag, "after mute success is 0 : $ret}");
    return ret;
  }

  bool isMute() {
    RCRTCLog.d(tag, "isMute $_mute");
    return _mute;
  }

  Future<RCRTCResourceState> getResourceState() async {
    int? code = await channel.invokeMethod("getResourceState");
    int ret = code ?? -1;
    if (ret == 0) {
      return RCRTCResourceState.forbidden;
    } else {
      return RCRTCResourceState.normal;
    }
  }
}
