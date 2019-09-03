class RongRTCConfig {
  
  ///是否打开摄像头，默认值 true 表示打开摄像头，如果为 false 只会发布音频流
  bool cameraEnable;

  ///摄像头输出的视频分辨率，默认 640x480
  ///参见 [RongRTCVideoSize]
  int videoSize;

  static RongRTCConfig defaultConfig(){
      RongRTCConfig config = new RongRTCConfig();
      config.cameraEnable = true;
      config.videoSize = RongRTCVideoSize.Size640x480;
      return config;
  }

  Map toMap(){
    if(cameraEnable == null) {
      cameraEnable = true;
    }
    if(videoSize == null) {
      videoSize = RongRTCVideoSize.Size640x480;
    }
    Map map = {"videoSize":videoSize,"cameraEnable":cameraEnable};
    return map;
  }
}

/// 视频分辨率
class RongRTCVideoSize {
  static const int Size256x144 = 256144;
  static const int Size320x240 = 320240;
  static const int Size480x360 = 480360;
  static const int Size640x360 = 640360;
  static const int Size640x480 = 640480;
  static const int Size720x480 = 720480;
  static const int Size1280x720 = 1280720;
}

enum RongRTCVodioFillMode {
  /// 自适应
  Fit,
  /// 填充
  Fill,
}