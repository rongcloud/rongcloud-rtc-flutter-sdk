enum RCRTCFps {
  fps_10,
  fps_15,
  fps_25,
  fps_30,
}

enum RCRTCVideoResolution {
  RESOLUTION_144_176,
  RESOLUTION_144_256,
  RESOLUTION_180_180,
  RESOLUTION_180_240,
  RESOLUTION_180_320,
  RESOLUTION_240_240,
  RESOLUTION_240_320,
  RESOLUTION_360_360,
  RESOLUTION_360_480,
  RESOLUTION_360_640,
  RESOLUTION_480_480,
  RESOLUTION_480_640,
  RESOLUTION_480_720,
  RESOLUTION_720_1280,
  RESOLUTION_1080_1920,
}

class RCRTCVideoStreamConfig {
  int minRate;
  int maxRate;
  RCRTCFps fps;
  RCRTCVideoResolution resolution;

  RCRTCVideoStreamConfig(this.minRate, this.maxRate, this.fps, this.resolution);

  String toResolutionStr(RCRTCVideoResolution selectResolution) {
    List arr = selectResolution.toString().split('.');
    return arr.last;
  }

  Map<String, dynamic> toJson() => {
        'videoFps': fps.index,
        'minRate': minRate,
        'maxRate': maxRate,
        'videoResolution': toResolutionStr(resolution),
      };
}
