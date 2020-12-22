import 'dart:convert';

import 'package:flutter/services.dart';

import '../rcrtc_error_code.dart';

typedef EffectFinishedCallback(int effectId);

class RCRTCAudioEffectManager {
  RCRTCAudioEffectManager.fromJson(Map<String, dynamic> json)
      : _channel = MethodChannel('rong.flutter.rtclib/AudioEffectManager:${json['id']}'),
        _callbacks = new List() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  void release() {
    _callbacks.clear();
  }

  Future<dynamic> _methodCallHandler(MethodCall call) {
    switch (call.method) {
      case 'onEffectFinished':
        _handleOnEffectFinished(call.arguments);
        break;
    }
    return null;
  }

  void _handleOnEffectFinished(String string) {
    Map<String, dynamic> json = jsonDecode(string);
    int effectId = json['effectId'];
    for (EffectFinishedCallback callback in _callbacks) callback(effectId);
  }

  int registerEffectFinishedCallback(EffectFinishedCallback callback) {
    _callbacks.add(callback);
    return RCRTCErrorCode.OK;
  }

  int unregisterStateObserver(EffectFinishedCallback callback) {
    return _callbacks.remove(callback) ? RCRTCErrorCode.OK : RCRTCErrorCode.UnknownError;
  }

  Future<int> preloadEffectFromAssets(String assets, int effectId) async {
    Map<String, dynamic> arguments = {'assets': assets, 'effectId': effectId};
    String result = await _channel.invokeMethod("preloadEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> preloadEffect(String path, int effectId) async {
    Map<String, dynamic> arguments = {'path': path, 'effectId': effectId};
    String result = await _channel.invokeMethod("preloadEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> unloadEffect(int effectId) async {
    Map<String, dynamic> arguments = {'effectId': effectId};
    String result = await _channel.invokeMethod("unloadEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> playEffect(int effectId, int loopCount, int volume) async {
    Map<String, dynamic> arguments = {'effectId': effectId, 'loopCount': loopCount, 'volume': volume};
    String result = await _channel.invokeMethod("playEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> pauseEffect(int effectId) async {
    Map<String, dynamic> arguments = {'effectId': effectId};
    String result = await _channel.invokeMethod("pauseEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> pauseAllEffects() async {
    String result = await _channel.invokeMethod("pauseAllEffects");
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> resumeEffect(int effectId) async {
    Map<String, dynamic> arguments = {'effectId': effectId};
    String result = await _channel.invokeMethod("resumeEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> resumeAllEffects() async {
    String result = await _channel.invokeMethod("resumeAllEffects");
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> stopEffect(int effectId) async {
    Map<String, dynamic> arguments = {'effectId': effectId};
    String result = await _channel.invokeMethod("stopEffect", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> stopAllEffects() async {
    String result = await _channel.invokeMethod("stopAllEffects");
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> setEffectsVolume(int volume) async {
    Map<String, dynamic> arguments = {'volume': volume};
    String result = await _channel.invokeMethod("setEffectsVolume", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> getEffectsVolume() async {
    String result = await _channel.invokeMethod("getEffectsVolume");
    Map<String, dynamic> json = jsonDecode(result);
    int volume = json['volume'];
    return volume;
  }

  Future<int> setEffectVolume(int effectId, int volume) async {
    Map<String, dynamic> arguments = {'effectId': effectId, 'volume': volume};
    String result = await _channel.invokeMethod("setEffectVolume", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int code = json['code'];
    return code;
  }

  Future<int> getEffectVolume(int effectId) async {
    Map<String, dynamic> arguments = {'effectId': effectId};
    String result = await _channel.invokeMethod("getEffectVolume", arguments);
    Map<String, dynamic> json = jsonDecode(result);
    int volume = json['volume'];
    return volume;
  }

  final MethodChannel _channel;

  final List<EffectFinishedCallback> _callbacks;
}
