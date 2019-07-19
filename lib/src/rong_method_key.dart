class MethodKey {
  static const String Config = "Config";
  static const String JoinRTCRoom = "JoinRTCRoom";
  static const String LeaveRTCRoom = "LeaveRTCRoom";
  static const String PublishAVStream = "PublishAVStream";
  static const String UnpublishAVStream = "UnpublishAVStream";
  static const String RenderLocalVideo = "RenderLocalVideo";
  static const String RenderRemoteVideo = "RenderRemoteVideo";
  static const String SubscribeAVStream = "SubscribeAVStream";
  static const String UnsubscribeAVStream = "UnsubscribeAVStream";
  static const String GetRemoteUsers = "GetRemoteUsers";
  static const String RemoveNativeView = "RemoveNativeView";
  static const String MuteLocalAudio = "MuteLocalAudio";
  static const String MuteRemoteAudio = "MuteRemoteAudio";
  static const String SwitchCamera = "SwitchCamera";
  static const String ExchangeVideo = "ExchangeVideo";
}

class MethodCallBackKey {
  static const String JoinRTCRoom = "JoinRTCRoom";
  static const String UserJoined = "UserJoinedCallBack";
  static const String UserLeaved = "UserLeavedCallBack";
  static const String OthersPublishStreams = "OthersPublishStreamsCallBack";
  static const String OthersUnpublishStreams = "OthersUnpublishStreamsCallBack";
}