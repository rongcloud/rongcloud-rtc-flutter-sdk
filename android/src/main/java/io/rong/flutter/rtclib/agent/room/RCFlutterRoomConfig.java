package io.rong.flutter.rtclib.agent.room;

import java.util.Map;

import cn.rongcloud.rtc.api.RCRTCRoomConfig;
import cn.rongcloud.rtc.base.RCRTCLiveRole;
import cn.rongcloud.rtc.base.RCRTCRoomType;

public class RCFlutterRoomConfig {

  private final RCRTCRoomConfig config;

  private RCFlutterRoomConfig(RCRTCRoomConfig config) {
    this.config = config;
  }

  public static RCFlutterRoomConfig from(Map<String, Integer> map) {
    int roomTypeIndex = map.get("roomType");
    int liveTypeIndex = map.get("liveType");
    int roleTypeIndex = map.get("roleType");

    RCRTCRoomType roomType = roomTypeIndex == 0 ? RCRTCRoomType.MEETING : (liveTypeIndex == 0 ? RCRTCRoomType.LIVE_AUDIO_VIDEO : RCRTCRoomType.LIVE_AUDIO);
    RCRTCLiveRole roleType = roleTypeIndex == 0 ? RCRTCLiveRole.BROADCASTER : RCRTCLiveRole.AUDIENCE;
    RCRTCRoomConfig config = RCRTCRoomConfig.Builder.create().setRoomType(roomType).setLiveRole(roleType).build();
    return new RCFlutterRoomConfig(config);
  }

  public RCRTCRoomConfig nativeConfig() {
    return config;
  }

}
