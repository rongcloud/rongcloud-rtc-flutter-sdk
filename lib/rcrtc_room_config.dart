/*
* 房间类型*/
enum RCRTCRoomType {
  /*
  * 加入普通房间
  * */
  Normal,
  /*
  * 加入直播房间*/
  Live
}
/*!
 当为 RCRTCRoomTypeLive 类型时，当前直播类型
 */
enum RCRTCLiveType {
/*
* 当前直播为音视频直播*/
  AudioVideo,

/*
* 当前直播为仅音频直播*/
  Audio
}

class RCRTCRoomConfig {
  RCRTCRoomType roomType;
  RCRTCLiveType liveType;
  RCRTCRoomConfig(this.roomType,this.liveType);
  Map<String, dynamic> toJson() => {
    'roomType': this.roomType.index,
    'liveType': this.liveType.index,
  };
}
