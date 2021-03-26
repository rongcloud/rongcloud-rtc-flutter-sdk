/// 房间类型
enum RCRTCRoomType {
  /// 加入普通房间
  Normal,

  /// 加入直播房间
  Live
}

/// 直播类型
enum RCRTCLiveType {
  /// 当前直播为音视频直播
  AudioVideo,

  /// 当前直播为仅音频直播
  Audio
}

//直播类型下的角色区分
enum RCRTCLiveRoleType {
  ///当前直播角色为主播
  Broadcaster,

  ///当前直播角色为观众
  Audience
}

class RCRTCRoomConfig {
  RCRTCRoomType roomType;
  RCRTCLiveType liveType;
  RCRTCLiveRoleType roleType;

  RCRTCRoomConfig(this.roomType, this.liveType, this.roleType);

  Map<String, dynamic> toJson() => {
        'roomType': this.roomType.index,
        'liveType': this.liveType.index,
        'roleType': this.roleType.index,
      };
}
