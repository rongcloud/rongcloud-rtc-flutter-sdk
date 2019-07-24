class RongRTCConfig {
  
  ///摄像头输出的视频分辨率，默认 640x480
  ///参见 [RongRTCVideoSize]
  int videoSize;

  static RongRTCConfig defaultConfig(){
      RongRTCConfig config = new RongRTCConfig();
      config.videoSize = RongRTCVideoSize.Size640x480;
      return config;
  }

  Map toMap(){
    Map map = {"videoSize":videoSize};
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