import 'dart:convert';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../../rcrtc_live_info.dart';
import '../../utils/rcrtc_log.dart';
import '../stream/rcrtc_input_stream.dart';
import '../stream/rcrtc_output_stream.dart';
import 'rcrtc_user.dart';

class RCRTCLocalUser extends RCRTCUser {
  static const _tag = "RCRTCLocalUser";

  final List<RCRTCOutputStream> _streamList = [];

  RCRTCLocalUser.fromJson(Map<String, dynamic> jsonObj) : super.fromJson(jsonObj);

  Future<int> publishDefaultStreams() async {
    int? ret = await methodChannel.invokeMethod('publishDefaultStreams');
    return ret ?? -1;
  }

  Future<void> publishDefaultLiveStreams(
    void onSuccess(RCRTCLiveInfo liveInfo),
    void onError(int code, String? message),
  ) async {
    String? json = await methodChannel.invokeMethod('publishDefaultLiveStreams');
    Map<String, dynamic> result = jsonDecode(json!);
    RCRTCLog.d(_tag, "publishDefaultLiveStreams $result");
    int code = result['code'] ?? -1;
    String? content = result["content"];
    if (code == 0) {
      onSuccess(RCRTCLiveInfo.fromJSON(jsonDecode(content!)));
    } else {
      onError(code, content);
    }
  }

  void publishLiveStream(
    RCRTCOutputStream stream,
    void onSuccess(RCRTCLiveInfo liveInfo),
    void onError(int code, String? message),
  ) async {
    String? json = await methodChannel.invokeMethod("publishLiveStream", jsonEncode(stream));
    Map<String, dynamic> result = jsonDecode(json!);
    RCRTCLog.d(_tag, "publishLiveStream $result");
    int code = result['code'] ?? -1;
    String? content = result["content"];
    if (code == 0) {
      onSuccess(RCRTCLiveInfo.fromJSON(jsonDecode(content!)));
    } else {
      onError(code, content);
    }
  }

  Future<int> publishStreams(List<RCRTCOutputStream> streams) async {
    var jsonStreams = streams.map<String>((stream) => jsonEncode(stream)).toList();
    int? ret = await methodChannel.invokeMethod("publishStreams", jsonStreams);
    return ret ?? -1;
  }

  Future<int> publishStream(RCRTCOutputStream? stream) async {
    if (stream == null) return -1;
    return publishStreams([stream]);
  }

  Future<void> unPublishDefaultStreams() async {
    await methodChannel.invokeMethod('unPublishDefaultStreams');
  }

  Future<int> unPublishStreams(List<RCRTCOutputStream> streams) async {
    var jsonStreams = streams.map<String>((stream) => jsonEncode(stream)).toList();
    int? ret = await methodChannel.invokeMethod("unPublishStreams", jsonStreams);
    return ret ?? -1;
  }

  Future<int> unPublishStream(RCRTCOutputStream? stream) async {
    if (stream == null) return -1;
    return unPublishStreams([stream]);
  }

  Future<int> subscribeStreams(
    List<RCRTCInputStream> streams, {
    bool tiny = false,
  }) async {
    Map<String, dynamic> arguments = {
      "streams": jsonEncode(streams),
      "tiny": tiny,
    };

    String streamListJson = jsonEncode(streams);
    RCRTCLog.d(_tag, "subscribeStreams $streamListJson");
    int? code = await methodChannel.invokeMethod('subscribeStreams', arguments);
    return code ?? -1;
  }

  Future<int> subscribeStream(RCRTCInputStream stream) async {
    return subscribeStreams([stream]);
  }

  Future<int> unsubscribeStreams(List<RCRTCInputStream> streamList) async {
    String streamListJson = jsonEncode(streamList);
    RCRTCLog.d(_tag, "unsubscribeStreams $streamListJson");
    int? code = await methodChannel.invokeMethod('unsubscribeStreams', streamListJson);
    return code ?? -1;
  }

  Future<int> unsubscribeStream(RCRTCInputStream stream) async {
    return unsubscribeStreams([stream]);
  }

  Future<List<RCRTCOutputStream>> getStreams() async {
    _streamList.clear();
    List<dynamic>? jsonList = await methodChannel.invokeListMethod('getStreams');
    jsonList?.forEach((json) {
      _streamList.add(RCRTCOutputStream.fromJson(jsonDecode(json)));
    });
    return _streamList;
  }

  Future<int> setAttributeValue(String key, String value, MessageContent message) async {
    Map<String, dynamic> arguments = {
      "key": key,
      "value": value,
      "object": message.getObjectName(),
      "content": message.encode(),
    };
    int? result = await methodChannel.invokeMethod('setAttributeValue', arguments);
    return result ?? -1;
  }

  Future<int> deleteAttributes(List<String> keys, MessageContent message) async {
    Map<String, dynamic> arguments = {
      "keys": jsonEncode(keys),
      "object": message.getObjectName(),
      "content": message.encode(),
    };
    int? result = await methodChannel.invokeMethod('deleteAttributes', arguments);
    return result ?? -1;
  }

  Future<Map<String, String>?> getAttributes(List<String> keys) async {
    Map<String, dynamic> arguments = {
      "keys": jsonEncode(keys),
    };
    Map<String, String>? results = await methodChannel.invokeMapMethod('getAttributes', arguments);
    return results;
  }
}
