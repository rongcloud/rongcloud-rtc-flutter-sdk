import 'dart:convert';

import '../../rcrtc_error_code.dart';
import '../../rcrtc_live_info.dart';
import '../../utils/rcrtc_debug_checker.dart';
import '../../utils/rcrtc_log.dart';
import '../stream/rcrtc_camera_output_stream.dart';
import '../stream/rcrtc_input_stream.dart';
import '../stream/rcrtc_mic_output_stream.dart';
import '../stream/rcrtc_output_stream.dart';
import 'rcrtc_user.dart';

class RCRTCLocalUser extends RCRTCUser {
  static const _tag = "RCRTCLocalUser";

  final List<RCRTCOutputStream> streamList = List<RCRTCOutputStream>();

  RCRTCLocalUser.fromJson(Map<String, dynamic> jsonObj) : super.fromJson(jsonObj) {
    List<dynamic> jsonStreams = jsonObj['streams'];
    for (var stream in jsonStreams) {
      if (stream['tag'] == 'RongCloudRTC') {
        if (stream['type'] == 0) {
          streamList.add(RCRTCMicOutputStream.fromJson(stream));
          continue;
        } else if (stream['type'] == 1) {
          streamList.add(RCRTCCameraOutputStream.fromJson(stream));
          continue;
        }
      }
      RCRTCDebugChecker.throwError('Unknown stream type!');
    }
    print('streams = $streamList');
  }

  List<RCRTCOutputStream> getStreams() {
    return streamList;
  }

  Future<int> publishDefaultStreams() async {
    return await methodChannel.invokeMethod('publishDefaultStreams');
  }

  Future<void> unpublishDefaultStreams() async {
    await methodChannel.invokeMethod('unpublishDefaultStreams');
  }

  Future<int> publishStreams(List<RCRTCOutputStream> streams) async {
    var jsonStreams = streams.map<String>((stream) => jsonEncode(stream)).toList();
    return await methodChannel.invokeMethod("publishStreams", jsonStreams);
  }

  Future<int> unPublishStreams(List<RCRTCOutputStream> streams) async {
    var jsonStreams = streams.map<String>((stream) => jsonEncode(stream)).toList();
    return await methodChannel.invokeMethod("unpublishStreams", jsonStreams);
  }

  Future<int> subscribeStreams(List<RCRTCInputStream> streams) async {
    String streamListJson = jsonEncode(streams);
    RCRTCLog.d(_tag, "subscribeStreams $streamListJson");
    int code = await methodChannel.invokeMethod('subscribeStreams', streamListJson);
    if (code == RCRTCErrorCode.OK) {
//      for (RCRTCInputStream stream in streamList) stream.subscribed = true;
    }
    return code;
  }

  Future<int> unsubscribeStreams(List<RCRTCInputStream> streamList) async {
    String streamListJson = jsonEncode(streamList);
    RCRTCLog.d(_tag, "unsubscribeStreams $streamListJson");
    int code = await methodChannel.invokeMethod('unsubscribeAVStream', streamListJson);
    if (code == RCRTCErrorCode.OK) {
//      for (RCRTCInputStream stream in streamList) stream.subscribed = false;
    }
    return code;
  }

  Future<void> publishDefaultLiveStreams(
    void onSuccess(RCRTCLiveInfo liveInfo),
    void onError(int code, String message),
  ) async {
    String json = await methodChannel.invokeMethod('publishLiveStreams');
    Map<String, dynamic> result = jsonDecode(json);
    RCRTCLog.d(_tag, "publishDefaultLiveStreams $result");
    int code = result['code'];
    String content = result["content"];
    if (code == 0) {
      onSuccess(RCRTCLiveInfo.fromJSON(jsonDecode(content)));
    } else {
      onError(code, content);
    }
  }

// Future<void> publishLiveStream(RCRTCOutputStream stream, {OnSuccess<RCRTCLiveInfo> onSuccess, OnError<int> onError}) async {
//   String jsonStr = await methodChannel.invokeMethod("publishLiveStream", jsonEncode(stream));
//   Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
//   int code = jsonObj["code"];
//   if (code == 0) {
//     onSuccess(RCRTCLiveInfo.fromJSON(jsonDecode(jsonObj["content"])));
//   } else {
//     onError(code);
//   }
// }
}
