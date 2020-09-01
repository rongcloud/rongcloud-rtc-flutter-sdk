import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../rcrtc_error_code.dart';
import '../rcrtc_room_config.dart';
import '../utils/rcrtc_debug_checker.dart';
import 'rcrtc_status_report.dart';
import 'room/rcrtc_room.dart';
import 'stream/rcrtc_audio_input_stream.dart';
import 'stream/rcrtc_camera_output_stream.dart';
import 'stream/rcrtc_input_stream.dart';
import 'stream/rcrtc_mic_output_stream.dart';
import 'stream/rcrtc_video_input_stream.dart';
import 'stream/rcrtc_video_output_stream.dart';

enum LiveType {
  audio,
  video,
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

  Future<RCRTCCodeResult<RCRTCRoom>> joinRoom(String roomId) async {
    String jsonStr = await _channel.invokeMethod('joinRoom', roomId);
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    RCRTCDebugChecker.isTrueWithMessage(jsonObj["code"] == 0, "failed to joinRoom with error code ${jsonObj["code"]}");
    print("joinRoom json: ${jsonObj.toString()}");
    _room = RCRTCRoom.fromJson(jsonObj['room']);
    return RCRTCCodeResult(jsonObj['code'], _room);
  }

  // /// TODO:如下方法替代上面的方法?用一个joinroom方法？根据config区分直播或者normal？
  // Future<RCRTCCodeResult<RCRTCRoom>> joinLiveRoom({
  //   @required String roomId,
  //   RCRTCRoomConfig roomConfig,
  // }) async {
  //   Map<String, dynamic> configMap = roomConfig.toJson();
  //   Map<String, dynamic> roomMap = {'roomId': roomId, 'roomConfig': configMap};
  //   String jsonStr = await _channel.invokeMethod('joinLiveRoom', roomMap);
  //   Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
  //   room = RCRTCRoom.fromJson(jsonObj['room']);
  //   return RCRTCCodeResult(jsonObj['code'], room);
  // }

  Future<int> leaveRoom() async {
    String jsonStr = await _channel.invokeMethod("leaveRoom");
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    if (jsonObj['code'] == 0) _room = null;
    return jsonObj['code'];
  }

  RCRTCRoom get room {
    return _room;
  }

  Future<RCRTCCameraOutputStream> get defaultVideoStream async {
    _cameraOutputStream = _cameraOutputStream ??
        RCRTCCameraOutputStream.fromJson(jsonDecode(await _channel.invokeMethod('getDefaultVideoStream')));
    return _cameraOutputStream;
  }

  Future<RCRTCMicOutputStream> get defaultAudioStream async {
    _audioOutputStream = _audioOutputStream ??
        RCRTCMicOutputStream.fromJson(jsonDecode(await _channel.invokeMethod('getDefaultAudioStream')));
    return _audioOutputStream;
  }

  Future<RCRTCVideoOutputStream> createVideoOutputStream(String tag) async {
    String jsonStr = await _channel.invokeMethod("createVideoOutputStream", tag);
    return RCRTCVideoOutputStream.fromJson(jsonDecode(jsonStr));
  }

  // Future<List<RCRTCInputStream>> subscribeLiveStream(String url, LiveType liveType) async {
  //   var args = {"url": url, "type": liveType.index};
  //   List<String> streams = await _channel.invokeListMethod("subscribeLiveStream", args);
  //   return streams.map<RCRTCInputStream>((stream) {
  //     var json = jsonDecode(stream);
  //     if (json['type'] == 0) {
  //       return RCRTCAudioInputStream.fromJson(json);
  //     } else {
  //       return RCRTCVideoInputStream.fromJson(json);
  //     }
  //   }).toList();
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

  unsubscribeLiveStream(String url) async {
    await _channel.invokeMethod("unsubscribeLiveStream", url);
  }

  setMediaServerUrl(String serverUrl) async {
    await _channel.invokeMethod("mediaServerUrl", serverUrl);
  }
  
  releaseVideoView(int viewId) async {
    await _channel.invokeMethod("releaseVideoView", viewId);
  }
}
