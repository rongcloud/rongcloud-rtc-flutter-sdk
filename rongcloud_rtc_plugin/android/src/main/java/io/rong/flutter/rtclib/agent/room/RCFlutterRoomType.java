package io.rong.flutter.rtclib.agent.room;

import java.util.Map;

import cn.rongcloud.rtc.base.RCRTCRoomType;

public class RCFlutterRoomType {
  private static final String ROOM_TYPE = "roomType";
  private static final String LIVE_TYPE = "liveType";
  private static final int ROOM_TYPE_NORMAL = 0;
  private static final int ROOM_TYPE_LIVE = 1;
  private static final int LIVE_TYPE_AUDIO_VIDEO = 0;
  private static final int LIVE_TYPE_AUDIO = 1;
  private RCRTCRoomType rcrtcRoomType;

  public RCFlutterRoomType(RCRTCRoomType rcrtcRoomType) {
    this.rcrtcRoomType = rcrtcRoomType;
  }

  public static RCFlutterRoomType from(Map<String, Integer> roomTypeMap) {
    int roomType = roomTypeMap.get(ROOM_TYPE);
    int liveType = roomTypeMap.get(LIVE_TYPE);
    RCRTCRoomType realRoomType = null;
    if (roomType == ROOM_TYPE_LIVE) {
      if (liveType == LIVE_TYPE_AUDIO) {
        realRoomType = RCRTCRoomType.LIVE_AUDIO;
      } else {
        realRoomType = RCRTCRoomType.LIVE_AUDIO_VIDEO;
      }
    } else {
      realRoomType = RCRTCRoomType.MEETING;
    }
    return new RCFlutterRoomType(realRoomType);
  }

  public RCRTCRoomType nativeRoomType() {
    return this.rcrtcRoomType;
  }
}
