import 'package:flutter/services.dart';

enum AudioMixerMode {
  NONE, // 对端只能听见麦克风采集的声音
  MIX, // 对端能够听到麦克风采集的声音和音频文件的声音
  REPLACE, // 对端只能听到音频文件的声音
}

typedef AudioMixEndCallback();

class RCRTCAudioMixer {
  static RCRTCAudioMixer getInstance() {
    if (_instance == null) _instance = RCRTCAudioMixer._();
    return _instance;
  }

  RCRTCAudioMixer._() : _channel = MethodChannel('rong.flutter.rtclib/AudioMixer') {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> _methodCallHandler(MethodCall call) {
    if (call.method == 'onMixEnd') {
      _handleOnMixEnd();
    }
    return null;
  }

  void _handleOnMixEnd() {
    if (_callback != null) _callback();
  }

  void setAudioMixEndCallback(AudioMixEndCallback callback) {
    _callback = callback;
  }

  Future<bool> startMixFromAssets(String assets, AudioMixerMode mode, bool playback, int loopCount) async {
    Map<String, dynamic> arguments = {
      "assets": assets,
      "mode": mode.index,
      "playback": playback,
      "loopCount": loopCount,
    };
    return await _channel.invokeMethod("startMix", arguments);
  }

  Future<bool> startMix(String path, AudioMixerMode mode, bool playback, int loopCount) async {
    Map<String, dynamic> arguments = {
      "path": path,
      "mode": mode.index,
      "playback": playback,
      "loopCount": loopCount,
    };
    return await _channel.invokeMethod("startMix", arguments);
  }

  // Future<void> setPlayback(bool playback) async {
  //   Map<String, dynamic> arguments = {
  //     "playback": playback,
  //   };
  //   return await _channel.invokeMethod("setPlayback", arguments);
  // }

  Future<void> setMixingVolume(int volume) async {
    Map<String, dynamic> arguments = {
      "volume": volume,
    };
    return await _channel.invokeMethod("setMixingVolume", arguments);
  }

  Future<int> getMixingVolume() async {
    return await _channel.invokeMethod("getMixingVolume");
  }

  Future<void> setPlaybackVolume(int volume) async {
    Map<String, dynamic> arguments = {
      "volume": volume,
    };
    return await _channel.invokeMethod("setPlaybackVolume", arguments);
  }

  Future<int> getPlaybackVolume() async {
    return await _channel.invokeMethod("getPlaybackVolume");
  }

  Future<void> setVolume(int volume) async {
    Map<String, dynamic> arguments = {
      "volume": volume,
    };
    return await _channel.invokeMethod("setVolume", arguments);
  }

  Future<int> getDurationMillis(String path) async {
    Map<String, dynamic> arguments = {
      "path": path,
    };
    return await _channel.invokeMethod("getDurationMillis", arguments);
  }

  Future<double> getCurrentPosition() async {
    return await _channel.invokeMethod("getCurrentPosition");
  }

  Future<void> seekTo(double position) async {
    Map<String, dynamic> arguments = {
      "position": position,
    };
    return await _channel.invokeMethod("seekTo", arguments);
  }

  Future<void> pause() async {
    return await _channel.invokeMethod("pause");
  }

  Future<void> resume() async {
    return await _channel.invokeMethod("resume");
  }

  Future<void> stop() async {
    return await _channel.invokeMethod("stop");
  }

  static RCRTCAudioMixer _instance;

  final MethodChannel _channel;

  AudioMixEndCallback _callback;
}
