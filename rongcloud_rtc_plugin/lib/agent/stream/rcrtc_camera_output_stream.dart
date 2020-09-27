import 'package:flutter/services.dart';

import '../../utils/rcrtc_log.dart';
import 'rcrtc_video_output_stream.dart';

class RCRTCCameraOutputStream extends RCRTCVideoOutputStream {
  static const _tag = "RCRTCCameraOutputStream";

  bool _isFrontCamera;

  RCRTCCameraOutputStream.fromJson(stream) : super.fromJson(stream) {
    bool isFrontCamera = stream['frontCamera'];
    _isFrontCamera = isFrontCamera ?? true;
  }

  Future<dynamic> methodHandler(MethodCall call) async {
    RCRTCLog.d(_tag, "methodHandler ${call.method}: ${call.arguments}");
    super.methodHandler(call);
  }

  /// 开启摄像头采集视频数据
  Future<void> startCamera() async {
    await channel.invokeMethod("startCamera");
  }

  /// 切换摄像头
  Future<void> switchCamera() async {
    _isFrontCamera = await channel.invokeMethod("switchCamera");
  }

  /// 停用摄像头
  Future<void> stopCamera() async {
    await channel.invokeMethod("stopCamera");
  }

  /// 是否开启大小流
  Future<void> enableTinyStream(bool enable) async {
    await channel.invokeMethod("enableTinyStream", enable);
  }

  bool isFrontCamera() {
    return _isFrontCamera;
  }
}
