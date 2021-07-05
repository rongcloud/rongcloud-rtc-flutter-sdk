import 'package:flutter/services.dart';

import '../../utils/rcrtc_log.dart';
import 'rcrtc_video_output_stream.dart';

typedef RCRTCFileStreamOnEvent = void Function();

class RCRTCFileVideoOutputStream extends RCRTCVideoOutputStream {
  static const tag = 'FileVideoOutputStream';
  RCRTCFileStreamOnEvent? onStart;
  RCRTCFileStreamOnEvent? onComplete;
  RCRTCFileStreamOnEvent? onFailed;

  RCRTCFileVideoOutputStream.fromJson(stream) : super.fromJson(stream);

  @override
  Future<dynamic> methodHandler(MethodCall call) async {
    RCRTCLog.d(tag, 'methodHandler ${call.arguments}');
    super.methodHandler(call);
    switch (call.method) {
      case 'onStart':
        onStart?.call();
        break;
      case 'onComplete':
        onComplete?.call();
        break;
      case 'onFailed':
        onFailed?.call();
        break;
    }
  }
}
