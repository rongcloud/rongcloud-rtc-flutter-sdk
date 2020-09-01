import 'dart:convert';

import '../view/rcrtc_video_view.dart';
import 'rcrtc_output_stream.dart';
import 'rcrtc_video_stream_config.dart';

class RCRTCVideoOutputStream extends RCRTCOutputStream {
  static const String _tag = 'RCRTCVideoOutputStream';

  RCRTCVideoView _videoView;

  RCRTCVideoOutputStream.fromJson(stream) : super.fromJson(stream);

  void setVideoView(RCRTCVideoView view) async {
    _videoView = view;
    await channel.invokeMethod('setVideoView', view.id);
  }

  setVideoConfig(RCRTCVideoStreamConfig config) async {
    var json = jsonEncode(config);
    await channel.invokeMethod("setVideoConfig", json);
  }

  RCRTCVideoView get videoView => _videoView;
}
