import '../view/rcrtc_video_view.dart';
import 'rcrtc_input_stream.dart';

class RCRTCVideoInputStream extends RCRTCInputStream {
  RCRTCVideoInputStream.fromJson(stream) : super.fromJson(stream);

  Future<void> setVideoView(RCRTCVideoView view, int id) async {
    await channel.invokeMethod('setVideoView', id);
  }
}
