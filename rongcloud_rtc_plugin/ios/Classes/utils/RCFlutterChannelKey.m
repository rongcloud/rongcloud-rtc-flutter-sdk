#import "RCFlutterChannelKey.h"

#pragma mark - channel

NSString const *KPlugin = @"rong.flutter.rtclib/engine";

// render view
NSString const *RongFlutterRenderViewKey = @"rong.flutter.rtclib/VideoView";

// init camera
NSString const *KInitCamera = @"rong.flutter.rtclib/RCRTCCameraOutputStream";

// init audio
NSString const *KInitAudio = @"rong.flutter.rtclib/RCFlutterMicOutputStream";

// local user action
NSString const *KUser = @"rong.flutter.rtclib/User:";

// rtc tag
NSString const *KRTCTag = @"RongCloudRTC";

// mediastream channel
NSString const *KMediaStream = @"rong.flutter.rtclib/Stream:";

// room channel
NSString const *KRoom = @"rong.flutter.rtclib/Room:";


#pragma mark - action on channel
// init
NSString const *KInit = @"init";
// join room
NSString const *KJoinRoom = @"joinRoom";

// join live room
NSString const *KJoinLiveRoom = @"joinLiveRoom";

// startCapture
NSString const *KStartCapture = @"startCamera";

// switchCamera
NSString const *KSwitchCamera = @"switchCamera";

// setVideoConfig
NSString const *KSetVideoConfig = @"setVideoConfig";

// stopCamera
NSString const *KStopCamera = @"stopCamera";

// mute
NSString const *KMute = @"mute";

// setMicrophoneDisable
NSString const *KSetMicrophoneDisable = @"setMicrophoneDisable";

// enableSpeaker
NSString const *KEnableSpeaker = @"enableSpeaker";

// leaveRTCRoom
NSString const *KLeaveRTCRoom = @"leaveRoom";

// publish default streams
NSString const *KPublishDefaultStreams = @"publishDefaultStreams";

// unpublishStreams
NSString const *KUnpublishStreams = @"unpublishStreams";

// publishStreams
NSString const *KPublishStreams = @"publishStreams";

// unpublish default streams
NSString const *KUnPublishDefaultStreams = @"unpublishDefaultStreams";

// getDefaultVideoStream
NSString const *KGetDefaultVideoStream = @"getDefaultVideoStream";

// getDefaultAudioStream
NSString const *KGetDefaultAudioStream = @"getDefaultAudioStream";

// render view
NSString const *KRenderView = @"setVideoView";

// releasevideoview
NSString const *KReleaseVideoView = @"releaseVideoView";

// subscribe stream
NSString const *KSubscribeStream = @"subscribeStreams";

// subscribe stream
NSString const *KUnSubscribeStream = @"unsubscribeAVStream";

// switchToNormalStream
NSString const *KSwitchToNormalStream = @"switchToNormalStream";

// switchToTinyStream
NSString const *KSwitchToTinyStream = @"switchToTinyStream";

// on user join
NSString const *KOnUserJoin = @"onUserJoined";

// on user left
NSString const *KOnUserLeft = @"onUserLeft";

// on remote user publish stream
NSString const *kOnRemoteUserPublishStream = @"onRemoteUserPublishResource";

// on remote user unpublish stream
NSString const *KOnRemoteUserUnPublishStream = @"onRemoteUserUnpublishResource";
