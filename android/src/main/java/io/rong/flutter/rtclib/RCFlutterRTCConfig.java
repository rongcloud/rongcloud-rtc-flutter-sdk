package io.rong.flutter.rtclib;

import java.util.Map;

import cn.rongcloud.rtc.RongRTCConfig;

public class RCFlutterRTCConfig {

    private RongRTCConfig rtcConfig = null;

    private RCFlutterRTCConfig() {
        rtcConfig = new RongRTCConfig.Builder().build();
    }

    private boolean cameraEnable;

    private static class SingleHolder {
        static RCFlutterRTCConfig instance = new RCFlutterRTCConfig();
    }

    public static RCFlutterRTCConfig getInstance() {
        return SingleHolder.instance;
    }

    public void updateParam(Map map) {
        int videoSize = (Integer) map.get("videoSize");
        cameraEnable = (Boolean) map.get("cameraEnable");
        RongRTCConfig.Builder confBuild = new RongRTCConfig.Builder().setVideoProfile(genVideoProfile(videoSize));
        rtcConfig = confBuild.build();
    }

    public RongRTCConfig getRTCConfig() {
        return rtcConfig;
    }

    public boolean isCameraEnable() {
        return cameraEnable;
    }

    private RongRTCConfig.RongRTCVideoProfile genVideoProfile(int value) {
        RongRTCConfig.RongRTCVideoProfile profile =  RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_480P_15f_1;
        switch (value) {
            case 256144:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_144P_15f;
                break;
            case 320240:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_240P_15f;
                break;
            case 480360:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_360P_15f_1;
                break;
            case 640360:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_360P_15f_3;
                break;
            case 640480:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_480P_15f_1;
                break;
            case 720480:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_480P_15f_2;
                break;
            case 1280720:
                profile = RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_720P_15f;
                break;

                default:
                    break;
        }
        return profile;
    }
}
