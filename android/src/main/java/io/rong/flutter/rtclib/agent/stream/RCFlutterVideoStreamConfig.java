package io.rong.flutter.rtclib.agent.stream;

import cn.rongcloud.rtc.base.RCRTCParamsType.RCRTCVideoFps;
import cn.rongcloud.rtc.base.RCRTCParamsType.RCRTCVideoResolution;

public class RCFlutterVideoStreamConfig {
  private int maxRate;
  private int minRate;
  private int videoFps; // array index
  private RCRTCVideoResolution videoResolution; // array index

  public int getMaxRate() {
    return maxRate;
  }

  public int getMinRate() {
    return minRate;
  }

  public RCRTCVideoFps getVideoFps() {
    switch (videoFps) {
      case 0:
        {
          return RCRTCVideoFps.Fps_10;
        }
      case 1:
        {
          return RCRTCVideoFps.Fps_15;
        }
      case 2:
        {
          return RCRTCVideoFps.Fps_24;
        }
      case 3:
        {
          return RCRTCVideoFps.Fps_30;
        }
    }

    return RCRTCVideoFps.Fps_15;
  }

  public RCRTCVideoResolution getVideoResolution() {

    return this.videoResolution;
  }

  public void setMaxRate(int maxRate) {
    this.maxRate = maxRate;
  }

  public void setMinRate(int minRate) {
    this.minRate = minRate;
  }

  public void setVideoFps(int videoFps) {
    this.videoFps = videoFps;
  }

  public void setVideoResolution(String videoResolution) {
    if (videoResolution != null && !videoResolution.equals("")) {
      this.videoResolution = RCRTCVideoResolution.valueOf(videoResolution);
    } else {
      this.videoResolution = RCRTCVideoResolution.RESOLUTION_480_640;
    }
  }
}
