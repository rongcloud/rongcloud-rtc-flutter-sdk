import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_audio_effect_manager.dart';

import '../rcrtc_error_code.dart';
import '../rcrtc_room_config.dart';
import '../rongcloud_rtc_plugin.dart';
import 'rcrtc_status_report.dart';
import 'room/rcrtc_room.dart';
import 'stream/rcrtc_camera_output_stream.dart';
import 'stream/rcrtc_mic_output_stream.dart';
import 'stream/rcrtc_video_output_stream.dart';

enum AVStreamType {
  audio,
  video,
  audio_video,
  video_tiny,
  audio_video_tiny,
}

class RCRTCEngine {
  static const String version = '5.1.0';

  static const MethodChannel _channel = MethodChannel('rong.flutter.rtclib/engine');

  static RCRTCEngine _instance;
  RCRTCCameraOutputStream _cameraOutputStream;
  RCRTCMicOutputStream _audioOutputStream;
  RCRTCAudioEffectManager _audioEffectManager;
  RCRTCRoom _room;
  IRCRTCStatusReportListener _statusReportListener;

  // void Function() _subscribeLiveStreamSuccess;
  // void Function(RCRTCAudioInputStream stream) _subscribeLiveStreamAudioReceived;
  // void Function(RCRTCVideoInputStream stream) _subscribeLiveStreamVideoReceived;
  // void Function(int code, String message) _subscribeLiveStreamFailed;

  static RCRTCEngine getInstance() {
    if (_instance == null) _instance = RCRTCEngine();
    return _instance;
  }

  RCRTCEngine() {
    _channel.setMethodCallHandler(_handlerMethod);
  }

  Future<dynamic> _handlerMethod(MethodCall call) {
    switch (call.method) {
      case "onConnectionStats":
        _handlerOnConnectionStats(call);
        break;
      // case "onSuccess":
      //   _handlerSubscribeLiveStreamSuccess(call);
      //   break;
      // case "onAudioStreamReceived":
      //   _handlerSubscribeLiveStreamAudioReceived(call);
      //   break;
      // case "onVideoStreamReceived":
      //   _handlerSubscribeLiveStreamVideoReceived(call);
      //   break;
      // case "onFailed":
      //   _handlerSubscribeLiveStreamFailed(call);
      // break;
    }
    return null;
  }

  _handlerOnConnectionStats(MethodCall call) {
    var jsonObj = jsonDecode(call.arguments);
    StatusReport report = StatusReport.fromJson(jsonObj);
    _statusReportListener.onConnectionStats(report);
  }

  // _handlerSubscribeLiveStreamSuccess(MethodCall call) {
  //   _subscribeLiveStreamSuccess?.call();
  // }

  // _handlerSubscribeLiveStreamAudioReceived(MethodCall call) {
  //   if (_subscribeLiveStreamAudioReceived == null) return;
  //   String json = call.arguments;
  //   RCRTCAudioInputStream audio =
  //       RCRTCAudioInputStream.fromJson(jsonDecode(json));
  //   _subscribeLiveStreamAudioReceived.call(audio);
  // }

  // _handlerSubscribeLiveStreamVideoReceived(MethodCall call) {
  //   if (_subscribeLiveStreamVideoReceived == null) return;
  //   String json = call.arguments;
  //   RCRTCVideoInputStream video =
  //       RCRTCVideoInputStream.fromJson(jsonDecode(json));
  //   _subscribeLiveStreamVideoReceived.call(video);
  // }

  // _handlerSubscribeLiveStreamFailed(MethodCall call) {
  //   if (_subscribeLiveStreamFailed == null) return;
  //   String json = call.arguments;
  //   Map<String, dynamic> result = jsonDecode(json);
  //   int code = result['code'];
  //   String message = result['message'];
  //   _subscribeLiveStreamFailed.call(code, message);
  // }

  Future<void> init(Object config) async {
    String jsonStr = jsonEncode(config);
    return await _channel.invokeMethod('init', jsonStr);
  }

  Future<void> unInit() async {
    _cameraOutputStream = null;
    if (_audioOutputStream != null) _audioOutputStream.release();
    _audioOutputStream = null;
    if (_audioEffectManager != null) _audioEffectManager.release();
    _audioEffectManager = null;
    // _subscribeLiveStreamSuccess = null;
    // _subscribeLiveStreamAudioReceived = null;
    // _subscribeLiveStreamVideoReceived = null;
    // _subscribeLiveStreamFailed = null;
    return await _channel.invokeMethod('unInit');
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
    _cameraOutputStream = null;
    if (_audioOutputStream != null) _audioOutputStream.release();
    _audioOutputStream = null;
    if (_audioEffectManager != null) _audioEffectManager.release();
    _audioEffectManager = null;
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

  Future<RCRTCAudioEffectManager> getAudioEffectManager() async {
    _audioEffectManager = _audioEffectManager ?? RCRTCAudioEffectManager.fromJson(jsonDecode(await _channel.invokeMethod('getAudioEffectManager')));
    return _audioEffectManager;
  }

  Future<RCRTCVideoOutputStream> createVideoOutputStream(String tag) async {
    String jsonStr = await _channel.invokeMethod("createVideoOutputStream", tag);
    return RCRTCVideoOutputStream.fromJson(jsonDecode(jsonStr));
  }

  // Future<RCRTCFileVideoOutputStream> createFileVideoOutputStream({@required String path, @required String tag, bool replace = true, bool playback = true}) async {
  //   var args = {"path": path, "tag": tag, "replace": replace ?? false, "playback": playback ?? true};
  //   String jsonStr = await _channel.invokeMethod("createFileVideoOutputStream", args);
  //   return RCRTCFileVideoOutputStream.fromJson(jsonDecode(jsonStr));
  // }

  // Future<void> subscribeLiveStream({
  //   @required String url,
  //   @required AVStreamType streamType,
  //   @required void onSuccess(),
  //   @required void onAudioStreamReceived(RCRTCAudioInputStream stream),
  //   @required void onVideoStreamReceived(RCRTCVideoInputStream stream),
  //   @required void onError(int code, String message),
  // }) async {
  //   var args = {"url": url, "type": streamType.index};
  //   _channel.invokeMethod("subscribeLiveStream", args);
  // _subscribeLiveStreamSuccess = onSuccess;
  // _subscribeLiveStreamAudioReceived = onAudioStreamReceived;
  // _subscribeLiveStreamVideoReceived = onVideoStreamReceived;
  // _subscribeLiveStreamFailed = onError;
  // }

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

  // Future<int> unsubscribeLiveStream(String url) async {
  //   String result = await _channel.invokeMethod("unsubscribeLiveStream", url);
  //   Map<String, dynamic> json = jsonDecode(result);
  //   return json['code'];
  // }

  setMediaServerUrl(String serverUrl) async {
    await _channel.invokeMethod("setMediaServerUrl", serverUrl);
  }

  Future<int> createVideoRenderer() async {
    String result = await _channel.invokeMethod("createVideoRenderer");
    Map<String, dynamic> json = jsonDecode(result);
    return json['textureId'];
  }

  disposeVideoRenderer(int textureId) async {
    await _channel.invokeMethod("disposeVideoRenderer", <String, dynamic>{'textureId': textureId});
  }
}
