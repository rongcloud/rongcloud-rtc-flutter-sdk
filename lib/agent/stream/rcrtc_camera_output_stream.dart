import 'package:flutter/services.dart';

import '../../utils/rcrtc_log.dart';
import 'rcrtc_video_output_stream.dart';

enum RCRTCCameraCaptureCameraType {
  Front,
  Back,
}

enum RCRTCCameraCaptureOrientation {
  Portrait,
  PortraitUpsideDown,
  LandscapeRight,
  LandscapeLeft,
}

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

  Future<void> startCameraByType(RCRTCCameraCaptureCameraType type) async {
    await channel.invokeMethod("startCameraByType", type.index);
  }

  /// 切换摄像头
  Future<bool> switchCamera() async {
    _isFrontCamera = await channel.invokeMethod("switchCamera");
    return _isFrontCamera;
  }

  Future<bool> switchCameraByType(RCRTCCameraCaptureCameraType type) async {
    if (type == RCRTCCameraCaptureCameraType.Front && !_isFrontCamera) {
      _isFrontCamera = await channel.invokeMethod("switchCamera");
    } else if (type == RCRTCCameraCaptureCameraType.Back && _isFrontCamera) {
      _isFrontCamera = await channel.invokeMethod("switchCamera");
    }
    return _isFrontCamera;
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

  Future<bool> isCameraFocusSupported() async {
    bool supported = await channel.invokeMethod("isCameraFocusSupported");
    return Future.value(supported);
  }

  Future<bool> isCameraExposurePositionSupported() async {
    bool supported = await channel.invokeMethod("isCameraExposurePositionSupported");
    return Future.value(supported);
  }

  Future<bool> setCameraExposurePositionInPreview(double x, double y) async {
    Map<String, dynamic> arguments = {
      "x": x,
      "y": y,
    };
    bool success = await channel.invokeMethod("setCameraExposurePositionInPreview", arguments);
    return Future.value(success);
  }

  Future<bool> setCameraFocusPositionInPreview(double x, double y) async {
    Map<String, dynamic> arguments = {
      "x": x,
      "y": y,
    };
    bool success = await channel.invokeMethod("setCameraFocusPositionInPreview", arguments);
    return Future.value(success);
  }

  Future<void> setCameraCaptureOrientation(RCRTCCameraCaptureOrientation orientation) async {
    Map<String, dynamic> arguments = {
      "orientation": orientation.index,
    };
    await channel.invokeMethod("setCameraCaptureOrientation", arguments);
  }
}
