import 'rcrtc_input_stream.dart';

class RCRTCVideoInputStream extends RCRTCInputStream {
  RCRTCVideoInputStream.fromJson(stream) : super.fromJson(stream);

  Future<void> setTextureView(int id) async {
    return await channel.invokeMethod('setTextureView', id);
  }
}
