class MethodKey {
  static const String Init = "Init";
  static const String Connect = "Connect";
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
}

class MethodCallBackKey {
  static const String JoinRTCRoom = "JoinRTCRoom";
  static const String UserJoined = "UserJoinedCallBack";
  static const String UserLeaved = "UserLeavedCallBack";
  static const String OthersPublishStreams = "OthersPublishStreamsCallBack";
}