//
//  RCFlutterRTCMethodKey.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/4.
//

#ifndef RCFlutterRTCMethodKey_h
#define RCFlutterRTCMethodKey_h

//key 由 flutter 触发，native 响应
static NSString * RCFlutterRTCMethodKeyInit = @"Init";
static NSString * RCFlutterRTCMethodKeyConnect = @"Connect";
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

//callbackkey 由 native 触发，native 响应
static NSString * RCFlutterRTCMethodCallBackKeyUserJoined = @"UserJoinedCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyUserLeaved = @"UserLeavedCallBack";
static NSString * RCFlutterRTCMethodCallBackKeyOthersPublishStreams = @"OthersPublishStreamsCallBack";

//test key
static NSString * RCFlutterRTCMethodKeyChangeViewColorTest = @"ChangeViewColorTest";
#endif /* RCFlutterRTCMethodKey_h */
