import 'package:flutter/services.dart';
import 'package:rongcloud_rtc_plugin/utils/rcrtc_callbacks.dart';

import 'rcrtc_audio_output_stream.dart';

class RCRTCMicOutputStream extends RCRTCAudioOutputStream {
  RCRTCMicOutputStream.fromJson(stream) : super.fromJson(stream) {
    bool state = stream['state'];
    _isMicrophoneDisable = state ?? false;
  }

  void release() {
    _syncActions.clear();
    _syncActions = null;
  }

  @override
  Future<dynamic> methodHandler(MethodCall call) async {
    switch (call.method) {
      case "changeAudioScenarioSyncActions":
        _handleChangeAudioScenarioSyncActions(call.arguments);
        break;
      default:
        return super.methodHandler(call);
    }
  }

  void _handleChangeAudioScenarioSyncActions(String id) {
    SyncActions actions = _syncActions.remove(id);
    if (actions != null) actions();
  }

  Future<int> setMicrophoneDisable(bool disable) async {
    int code = await channel.invokeMethod("setMicrophoneDisable", disable);
    if (code == 0) _isMicrophoneDisable = disable;
    return code;
  }

  bool isMicrophoneDisable() {
    return _isMicrophoneDisable;
  }

  // Future<void> setAudioConfig(RCRTCAudioStreamConfig config) async {
  //   await channel.invokeMethod("setAudioConfig", config.toJSON());
  // }

  // Future<void> changeAudioScenario(RCRTCAudioScenario audioScenario, SyncActions syncActions) async {
  //   String id = "null";
  //   if (syncActions != null) {
  //     id = "${DateTime.now().microsecondsSinceEpoch}_${syncActions.hashCode}";
  //     _syncActions[id] = syncActions;
  //   }
  //   Map<String, dynamic> arguments = {
  //     "audioScenario": audioScenario.index,
  //     "id": id,
  //   };
  //   await channel.invokeMethod("changeAudioScenario", arguments);
  // }

  Future<void> adjustRecordingVolume(int volume) async {
    await channel.invokeMethod("adjustRecordingVolume", volume);
  }

  Future<int> getRecordingVolume() async {
    int volume = await channel.invokeMethod("getRecordingVolume");
    return Future.value(volume);
  }

  bool _isMicrophoneDisable;

  Map<String, SyncActions> _syncActions = Map();
}
