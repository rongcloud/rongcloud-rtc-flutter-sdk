import 'rcrtc_audio_output_stream.dart';

class RCRTCMicOutputStream extends RCRTCAudioOutputStream {
  bool _isMicrophoneDisable;

  RCRTCMicOutputStream.fromJson(stream) : super.fromJson(stream) {
    bool state = stream['state'];
    _isMicrophoneDisable = state ?? false;
  }

  Future<int> setMicrophoneDisable(bool disable) async {
    int code = await channel.invokeMethod("setMicrophoneDisable", disable);
    if (code == 0) _isMicrophoneDisable = disable;
    return code;
  }

  bool isMicrophoneDisable() {
    return _isMicrophoneDisable;
  }
}
