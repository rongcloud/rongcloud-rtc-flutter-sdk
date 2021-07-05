import 'dart:convert';

import 'package:flutter/services.dart';
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

  static RCRTCEngine? _instance;
  RCRTCCameraOutputStream? _cameraOutputStream;
  RCRTCMicOutputStream? _audioOutputStream;
  RCRTCAudioEffectManager? _audioEffectManager;
  RCRTCRoom? _room;
  IRCRTCStatusReportListener? _statusReportListener;

  static RCRTCEngine getInstance() {
    if (_instance == null) _instance = RCRTCEngine();
    return _instance!;
  }

  RCRTCEngine() {
    _channel.setMethodCallHandler(_handlerMethod);
  }

  Future<dynamic> _handlerMethod(MethodCall call) async {
    switch (call.method) {
      case "onConnectionStats":
        _handlerOnConnectionStats(call);
        break;
    }
  }

  _handlerOnConnectionStats(MethodCall call) {
    var jsonObj = jsonDecode(call.arguments);
    StatusReport report = StatusReport.fromJson(jsonObj);
    _statusReportListener?.onConnectionStats(report);
  }

  Future<void> init(Object? config) async {
    String? jsonStr = jsonEncode(config);
    return await _channel.invokeMethod('init', jsonStr);
  }

  Future<void> unInit() async {
    _cameraOutputStream = null;
    _audioOutputStream?.release();
    _audioOutputStream = null;
    _audioEffectManager?.release();
    _audioEffectManager = null;
    await _channel.invokeMethod('unInit');
  }

  Future<RCRTCCodeResult<RCRTCRoom>> joinRoom({
    required String roomId,
    required RCRTCRoomConfig roomConfig,
  }) async {
    Map<String, dynamic> configMap = roomConfig.toJson();
    Map<String, dynamic> roomMap = {'roomId': roomId, 'roomConfig': configMap};
    String? jsonStr = await _channel.invokeMethod('joinRoom', roomMap);
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr!);
    print("joinRoom json: ${jsonObj.toString()}");

    int? ret = jsonObj["code"];
    int code = ret ?? -1;
    RCRTCCodeResult<RCRTCRoom> result = RCRTCCodeResult(code);
    if (code == 0) {
      _room = RCRTCRoom.fromJson(jsonObj['data']);
      result.object = _room;
    } else {
      result.reason = jsonObj['data'];
    }
    return result;
  }

  Future<int> leaveRoom() async {
    String? jsonStr = await _channel.invokeMethod("leaveRoom");
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr!);
    int? ret = jsonObj['code'];
    int code = ret ?? -1;
    if (code == 0) _room = null;
    _cameraOutputStream = null;
    _audioOutputStream?.release();
    _audioOutputStream = null;
    _audioEffectManager?.release();
    _audioEffectManager = null;
    return code;
  }

  RCRTCRoom? getRoom() {
    return _room;
  }

  Future<RCRTCCameraOutputStream?> getDefaultVideoStream() async {
    _cameraOutputStream = _cameraOutputStream ?? RCRTCCameraOutputStream.fromJson(jsonDecode(await _channel.invokeMethod('getDefaultVideoStream')));
    return _cameraOutputStream;
  }

  Future<RCRTCMicOutputStream?> getDefaultAudioStream() async {
    _audioOutputStream = _audioOutputStream ?? RCRTCMicOutputStream.fromJson(jsonDecode(await _channel.invokeMethod('getDefaultAudioStream')));
    return _audioOutputStream;
  }

  Future<RCRTCAudioEffectManager> getAudioEffectManager() async {
    _audioEffectManager = _audioEffectManager ?? RCRTCAudioEffectManager.fromJson(jsonDecode(await _channel.invokeMethod('getAudioEffectManager')));
    return _audioEffectManager!;
  }

  Future<RCRTCVideoOutputStream?> createVideoOutputStream(String tag) async {
    String? jsonStr = await _channel.invokeMethod("createVideoOutputStream", tag);
    if (jsonStr != null) {
      return RCRTCVideoOutputStream.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }

  Future<void> enableSpeaker(bool enableSpeaker) async {
    await _channel.invokeMethod("enableSpeaker", enableSpeaker);
  }

  Future<void> registerStatusReportListener(IRCRTCStatusReportListener listener) async {
    _statusReportListener = listener;
    await _channel.invokeMethod("registerStatusReportListener");
  }

  Future<void> unRegisterStatusReportListener() async {
    _statusReportListener = null;
    await _channel.invokeMethod("unRegisterStatusReportListener");
  }

  Future<void> setMediaServerUrl(String serverUrl) async {
    await _channel.invokeMethod("setMediaServerUrl", serverUrl);
  }

  Future<int> createVideoRenderer() async {
    String? result = await _channel.invokeMethod("createVideoRenderer");
    Map<String, dynamic> json = jsonDecode(result!);
    int? id = json['textureId'];
    return id!;
  }

  Future<void> disposeVideoRenderer(int textureId) async {
    await _channel.invokeMethod("disposeVideoRenderer", <String, dynamic>{'textureId': textureId});
  }
}
