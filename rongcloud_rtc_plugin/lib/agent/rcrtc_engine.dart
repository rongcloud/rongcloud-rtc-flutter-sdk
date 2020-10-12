import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../rcrtc_error_code.dart';
import '../rcrtc_room_config.dart';
import '../rongcloud_rtc_plugin.dart';
import 'rcrtc_status_report.dart';
import 'room/rcrtc_room.dart';
import 'stream/rcrtc_camera_output_stream.dart';
import 'stream/rcrtc_file_video_output_stream.dart';
import 'stream/rcrtc_mic_output_stream.dart';
import 'stream/rcrtc_video_input_stream.dart';
import 'stream/rcrtc_video_output_stream.dart';

enum AVStreamType {
  audio,
  video,
  audio_video,
  video_tiny,
  audio_video_tiny,
}

class RCRTCEngine {
  static const MethodChannel _channel = MethodChannel('rong.flutter.rtclib/engine');

  static RCRTCEngine _instance;
  RCRTCCameraOutputStream _cameraOutputStream;
  RCRTCMicOutputStream _audioOutputStream;
  RCRTCRoom _room;
  IRCRTCStatusReportListener _statusReportListener;

  static RCRTCEngine getInstance() {
    if (_instance == null) _instance = RCRTCEngine();
    return _instance;
  }

  RCRTCEngine() {
    _channel.setMethodCallHandler(_handlerMethod);
  }

  Future<dynamic> _handlerMethod(MethodCall call) {
    switch (call.method) {
      case "onAudioReceivedLevel":
        {
          _handlerOnAudioReceivedLevel(call);
          break;
        }

      case "onAudioInputLevel":
        {
          _handlerOnAudioInputLevel(call);
          break;
        }
      case "onConnectionStats":
        {
          _handlerOnConnectionStats(call);
          break;
        }
    }

    return null;
  }

  _handlerOnAudioReceivedLevel(MethodCall call) {
    Map<String, String> data = jsonDecode(call.arguments);
    _statusReportListener.onAudioReceivedLevel(data);
  }

  _handlerOnAudioInputLevel(MethodCall call) {
    String level = call.arguments;
    _statusReportListener?.onAudioInputLevel(level);
  }

  _handlerOnConnectionStats(MethodCall call) {
    var jsonObj = jsonDecode(call.arguments);
    StatusReport report = StatusReport.fromJson(jsonObj);
    _statusReportListener.onConnectionStats(report);
  }

  Future<void> init(Object config) async {
    String jsonStr = jsonEncode(config);
    return await _channel.invokeMethod('init', jsonStr);
  }

  Future<void> unInit() async {
    _channel.invokeMethod('unInit');
  }

  Future<RCRTCCodeResult<RCRTCRoom>> joinRoom({
    @required String roomId,
    @required RCRTCRoomConfig roomConfig,
  }) async {
    Map<String, dynamic> configMap = roomConfig.toJson();
    Map<String, dynamic> roomMap = {'roomId': roomId, 'roomConfig': configMap};
    String jsonStr = await _channel.invokeMethod('joinRoom', roomMap);
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    print("joinRoom json: ${jsonObj.toString()}");

    int resultCode = jsonObj["code"];
    RCRTCCodeResult<RCRTCRoom> result = RCRTCCodeResult(jsonObj['code']);
    if (resultCode == 0) {
      _room = RCRTCRoom.fromJson(jsonObj['data']);
      result.object = _room;
    } else {
      result.reason = jsonObj['data'];
    }
    return result;
  }

  Future<int> leaveRoom() async {
    String jsonStr = await _channel.invokeMethod("leaveRoom");
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    if (jsonObj['code'] == 0) _room = null;
    return jsonObj['code'];
  }

  RCRTCRoom getRoom() {
    return _room;
  }

  Future<RCRTCCameraOutputStream> getDefaultVideoStream() async {
    _cameraOutputStream = _cameraOutputStream ?? RCRTCCameraOutputStream.fromJson(jsonDecode(await _channel.invokeMethod('getDefaultVideoStream')));
    return _cameraOutputStream;
  }

  Future<RCRTCMicOutputStream> getDefaultAudioStream() async {
    _audioOutputStream = _audioOutputStream ?? RCRTCMicOutputStream.fromJson(jsonDecode(await _channel.invokeMethod('getDefaultAudioStream')));
    return _audioOutputStream;
  }

  Future<RCRTCVideoOutputStream> createVideoOutputStream(String tag) async {
    String jsonStr = await _channel.invokeMethod("createVideoOutputStream", tag);
    return RCRTCVideoOutputStream.fromJson(jsonDecode(jsonStr));
  }

  Future<RCRTCFileVideoOutputStream> createFileVideoOutputStream({@required String path, @required String tag, bool replace = true, bool playback = true}) async {
    var args = {"path": path, "tag": tag, "replace": replace ?? false, "playback": playback ?? true};
    String jsonStr = await _channel.invokeMethod("createFileVideoOutputStream", args);
    return RCRTCFileVideoOutputStream.fromJson(jsonDecode(jsonStr));
  }

  Future<void> subscribeLiveStream(
    String url,
    AVStreamType streamType,
    void onSuccess(RCRTCVideoInputStream stream),
    void onError(int code, String message),
  ) async {
    var args = {"url": url, "type": streamType.index};
    String json = await _channel.invokeMethod("subscribeLiveStream", args);
    Map<String, dynamic> result = jsonDecode(json);
    RCRTCLog.d("RCRTCEngine", "subscribeLiveStream $result");
    String callback = result['callback'];
    switch (callback) {
      case 'success':
        RCRTCVideoInputStream video = RCRTCVideoInputStream.fromJson(jsonDecode(result['stream']));
        onSuccess(video);
        break;
      case 'failed':
        int code = result['code'];
        String message = result['message'];
        onError(code, message);
        break;
    }
  }

  enableSpeaker(bool enableSpeaker) async {
    await _channel.invokeMethod("enableSpeaker", enableSpeaker);
  }

  registerStatusReportListener(IRCRTCStatusReportListener listener) async {
    _statusReportListener = listener;
    await _channel.invokeMethod("registerStatusReportListener");
  }

  unRegisterStatusReportListener() async {
    _statusReportListener = null;
    await _channel.invokeMethod("unRegisterStatusReportListener");
  }

  Future<int> unsubscribeLiveStream(String url) async {
    String result = await _channel.invokeMethod("unsubscribeLiveStream", url);
    Map<String, dynamic> json = jsonDecode(result);
    return json['code'];
  }

  setMediaServerUrl(String serverUrl) async {
    await _channel.invokeMethod("mediaServerUrl", serverUrl);
  }

  releaseVideoView(int viewId) async {
    await _channel.invokeMethod("releaseVideoView", viewId);
  }
}
