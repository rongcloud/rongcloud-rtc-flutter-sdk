#import <Foundation/Foundation.h>

#pragma mark - channel

FOUNDATION_EXTERN NSString const *KPlugin;

// render view
FOUNDATION_EXTERN NSString const *RongFlutterRenderViewKey;

// init camera
FOUNDATION_EXTERN NSString const *KInitCamera;

// init audio
FOUNDATION_EXTERN NSString const *KInitAudio;

// user action
FOUNDATION_EXTERN NSString const *KUser;

// rtc tag
FOUNDATION_EXTERN NSString const *KRTCTag;

// mediastream channel
FOUNDATION_EXTERN NSString const *KMediaStream ;

// room channel
FOUNDATION_EXTERN NSString const *KRoom;


#pragma mark - action on channel
// init
FOUNDATION_EXTERN NSString const *KInit;
// join room
FOUNDATION_EXTERN NSString const *KJoinRoom;

// join live room
FOUNDATION_EXTERN NSString const *KJoinLiveRoom;

// startCapture
FOUNDATION_EXTERN NSString const *KStartCapture;

// switchCamera
FOUNDATION_EXTERN NSString const *KSwitchCamera;

// setVideoConfig
FOUNDATION_EXTERN NSString const *KSetVideoConfig;

// stopCamera
FOUNDATION_EXTERN NSString const *KStopCamera;

// mute
FOUNDATION_EXTERN NSString const *KMute;

// setMicrophoneDisable
FOUNDATION_EXTERN NSString const *KSetMicrophoneDisable;

// enableSpeaker
FOUNDATION_EXTERN NSString const *KEnableSpeaker;

// leaveRTCRoom
FOUNDATION_EXTERN NSString const *KLeaveRTCRoom;

// publish default streams
FOUNDATION_EXTERN NSString const *KPublishDefaultLiveStreams;

// publish default streams
FOUNDATION_EXTERN NSString const *KPublishDefaultStreams;

// unpublish default streams
FOUNDATION_EXTERN NSString const *KUnPublishDefaultStreams;

// publishStreams
FOUNDATION_EXTERN NSString const *KPublishStreams;

// unpublishStreams
FOUNDATION_EXTERN NSString const *KUnpublishStreams;

// getDefaultVideoStream
FOUNDATION_EXTERN NSString const *KGetDefaultVideoStream;

// getDefaultAudioStream
FOUNDATION_EXTERN NSString const *KGetDefaultAudioStream;

// render view
FOUNDATION_EXTERN NSString const *KRenderView;

// releasevideoview
FOUNDATION_EXTERN NSString const *KReleaseVideoView;

// subscribe live stream
FOUNDATION_EXTERN NSString const *KSubscribeLiveStream;

FOUNDATION_EXTERN NSString const *KUnsubscribeLiveStream;

// subscribe stream
FOUNDATION_EXTERN NSString const *KSubscribeStream;

// unsubscribe stream
FOUNDATION_EXTERN NSString const *KUnSubscribeStream;

// switchToNormalStream
FOUNDATION_EXTERN NSString const *KSwitchToNormalStream;

// switchToTinyStream
FOUNDATION_EXTERN NSString const *KSwitchToTinyStream;

// on user join
FOUNDATION_EXTERN NSString const *KOnUserJoin;

// on user left
FOUNDATION_EXTERN NSString const *KOnUserLeft;

// on remote user publish stream
FOUNDATION_EXTERN NSString const *kOnRemoteUserPublishStream;

// on remote user unpublish stream
FOUNDATION_EXTERN NSString const *KOnRemoteUserUnPublishStream;
