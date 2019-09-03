class RCRTCMethodKey {
  static const String Config = "Config";
  static const String JoinRTCRoom = "JoinRTCRoom";
  static const String LeaveRTCRoom = "LeaveRTCRoom";
  static const String StartCapture = "StartCapture";
  static const String PublishAVStream = "PublishAVStream";
  static const String UnpublishAVStream = "UnpublishAVStream";
  static const String RenderLocalVideo = "RenderLocalVideo";
  static const String RenderRemoteVideo = "RenderRemoteVideo";
  static const String SubscribeAVStream = "SubscribeAVStream";
  static const String UnsubscribeAVStream = "UnsubscribeAVStream";
  static const String GetRemoteUsers = "GetRemoteUsers";
  static const String RemovePlatformView = "RemovePlatformView";
  static const String MuteLocalAudio = "MuteLocalAudio";
  static const String MuteRemoteAudio = "MuteRemoteAudio";
  static const String SwitchCamera = "SwitchCamera";
  static const String ExchangeVideo = "ExchangeVideo";
  static const String SetSpeakerEnable = "SetSpeakerEnable";
}

class RCRTCMethodCallBackKey {
  static const String JoinRTCRoom = "JoinRTCRoom";
  static const String UserJoined = "UserJoinedCallBack";
  static const String UserLeaved = "UserLeavedCallBack";
  static const String RemoteUserPublishStreams = "RemoteUserPublishStreamsCallBack";
  static const String RemoteUserUnpublishStreams = "RemoteUserUnpublishStreamsCallBack";
  static const String RemoteUserVideoEnabled = "RemoteUserVideoEnabledCallBack";
  static const String RemoteUserAudioEnabled = "RemoteUserAudioEnabledCallBack";
  static const String RemoteUserFirstKeyframe = "RemoteUserFirstKeyframeCallBack";
}