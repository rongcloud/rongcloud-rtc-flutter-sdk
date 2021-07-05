import 'dart:convert';

import '../stream/rcrtc_audio_input_stream.dart';
import '../stream/rcrtc_input_stream.dart';
import '../stream/rcrtc_video_input_stream.dart';
import 'rcrtc_user.dart';

class RCRTCRemoteUser extends RCRTCUser {
  /// remote user 对应发布的资源
  final List<RCRTCInputStream> streamList = [];

  RCRTCRemoteUser.fromJson(Map<String, dynamic> jsonObj) : super.fromJson(jsonObj) {
    List<dynamic> jsonStreamList = jsonObj['streamList'];
    for (var stream in jsonStreamList) {
      if (stream['type'] == 0) {
        streamList.add(RCRTCAudioInputStream.fromJson(stream));
      } else {
        streamList.add(RCRTCVideoInputStream.fromJson(stream));
      }
    }
  }

  /// 切换至大流
  void switchToNormalStream() async {
    String json = jsonEncode(streamList);
    await methodChannel.invokeMethod("switchToNormalStream", json);
  }

  /// 切换至小流
  void switchToTinyStream() async {
    String json = jsonEncode(streamList);
    await methodChannel.invokeMethod("switchToTinyStream", json);
  }
}
