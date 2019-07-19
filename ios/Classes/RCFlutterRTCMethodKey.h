//
//  RCFlutterRTCMethodKey.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/4.
//

#ifndef RCFlutterRTCMethodKey_h
#define RCFlutterRTCMethodKey_h

//key 由 flutter 触发，native 响应
static NSString * RCFlutterRTCMethodKeyConfig = @"Config";
static NSString * RCFlutterRTCMethodKeyJoinRTCRoom = @"JoinRTCRoom";
static NSString * RCFlutterRTCMethodKeyLeaveRTCRoom = @"LeaveRTCRoom";
static NSString * RCFlutterRTCMethodKeyPublishAVStream = @"PublishAVStream";
static NSString * RCFlutterRTCMethodKeyUnpublishAVStream = @"UnpublishAVStream";
static NSString * RCFlutterRTCMethodKeyRenderLocalVideo = @"RenderLocalVideo";
static NSString * RCFlutterRTCMethodKeyRenderRemoteVideo = @"RenderRemoteVideo";
static NSString * RCFlutterRTCMethodKeySubscribeAVStream = @"SubscribeAVStream";
static NSString * RCFlutterRTCMethodKeyUnsubscribeAVStream = @"UnsubscribeAVStream";
static NSString * RCFlutterRTCMethodKeyGetRemoteUsers = @"GetRemoteUsers";
static NSString * RCFlutterRTCMethodKeyRemoveNativeView = @"RemoveNativeView";
static NSString * RCFlutterRTCMethodKeyMuteLocalAudio = @"MuteLocalAudio";
static NSString * RCFlutterRTCMethodKeyMuteRemoteAudio = @"MuteRemoteAudio";
static NSString * RCFlutterRTCMethodKeySwitchCamera = @"SwitchCamera";
static NSString * RCFlutterRTCMethodKeyExchangeVideo = @"ExchangeVideo";


//callbackkey 由 native 触发，native 响应
static NSString * RCFlutterRTCMethodCallBackKeyUserJoined = @"UserJoinedCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyUserLeaved = @"UserLeavedCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyRemoteUserPublishStreams = @"RemoteUserPublishStreamsCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyRemoteUserUnpublishStreams = @"RemoteUserUnpublishStreamsCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyRemoteUserVideoEnabled = @"RemoteUserVideoEnabledCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyRemoteUserAudioEnabled = @"RemoteUserAudioEnabledCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyRemoteUserFirstKeyframe = @"RemoteUserFirstKeyframeCallBack";

#endif /* RCFlutterRTCMethodKey_h */
