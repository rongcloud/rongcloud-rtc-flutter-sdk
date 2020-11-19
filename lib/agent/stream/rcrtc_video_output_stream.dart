import 'dart:convert';

import 'rcrtc_output_stream.dart';
import 'rcrtc_video_stream_config.dart';

class RCRTCVideoOutputStream extends RCRTCOutputStream {
  static const String _tag = 'RCRTCVideoOutputStream';

  RCRTCVideoOutputStream.fromJson(stream) : super.fromJson(stream);

  Future<void> setTextureView(int id) async {
    return await channel.invokeMethod('setTextureView', id);
  }

  setVideoConfig(RCRTCVideoStreamConfig config) async {
    var json = jsonEncode(config);
    await channel.invokeMethod("setVideoConfig", json);
  }
}
