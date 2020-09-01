package io.rong.flutter.rtclib;

import cn.rongcloud.rtc.api.RCRTCConfig;

public class RCFlutterRTCConfig {

  private RCRTCConfig rtcConfig = null;

  private RCFlutterRTCConfig() {
    rtcConfig = RCRTCConfig.Builder.create().build();
  }

  private boolean cameraEnable;

  private static class SingleHolder {

    static RCFlutterRTCConfig instance = new RCFlutterRTCConfig();
  }

  public static RCFlutterRTCConfig getInstance() {
    return SingleHolder.instance;
  }

  public RCRTCConfig getRTCConfig() {
    return rtcConfig;
  }

  public boolean isCameraEnable() {
    return cameraEnable;
  }
}
