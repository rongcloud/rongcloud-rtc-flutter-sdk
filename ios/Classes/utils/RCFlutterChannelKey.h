#import <Foundation/Foundation.h>

#pragma mark - channel

FOUNDATION_EXTERN NSString * const KPlugin;

// init camera
FOUNDATION_EXTERN NSString * const KInitCamera;

// init audio
FOUNDATION_EXTERN NSString * const KInitAudio;

// user action
FOUNDATION_EXTERN NSString * const KUser;

// rtc tag
FOUNDATION_EXTERN NSString * const KRTCTag;

// mediastream channel
FOUNDATION_EXTERN NSString * const KMediaStream ;

// room channel
FOUNDATION_EXTERN NSString * const KRoom;

// audio effect manager channel
FOUNDATION_EXTERN NSString * const KAudioEffectManager;

// audio mixer channel
FOUNDATION_EXTERN NSString * const KAudioMixer;

#pragma mark - action on channel
// init
FOUNDATION_EXTERN NSString * const KInit;

// unInit
FOUNDATION_EXTERN NSString * const KUnInit;

// join room
FOUNDATION_EXTERN NSString * const KJoinRoom;

// startCapture
FOUNDATION_EXTERN NSString * const KStartCapture;

// switchCamera
FOUNDATION_EXTERN NSString * const KSwitchCamera;

// setVideoConfig
FOUNDATION_EXTERN NSString * const KSetVideoConfig;

// stopCamera
FOUNDATION_EXTERN NSString * const KStopCamera;

FOUNDATION_EXTERN NSString * const KIsCameraFocusSupported;

FOUNDATION_EXTERN NSString * const KIsCameraExposurePositionSupported;

FOUNDATION_EXTERN NSString * const KSetCameraExposurePositionInPreview;

FOUNDATION_EXTERN NSString * const KSetCameraFocusPositionInPreview;

FOUNDATION_EXTERN NSString * const KSetCameraCaptureOrientation;

// mute
FOUNDATION_EXTERN NSString * const KMute;

// setMicrophoneDisable
FOUNDATION_EXTERN NSString * const KSetMicrophoneDisable;

FOUNDATION_EXTERN NSString * const KAdjustRecordingVolume;

FOUNDATION_EXTERN NSString * const KGetRecordingVolume;

// enableSpeaker
FOUNDATION_EXTERN NSString * const KEnableSpeaker;

// leaveRTCRoom
FOUNDATION_EXTERN NSString * const KLeaveRTCRoom;

FOUNDATION_EXTERN NSString * const KGetStreams;

// publish default streams
FOUNDATION_EXTERN NSString * const KPublishDefaultLiveStreams;

// publish live stream
FOUNDATION_EXTERN NSString * const KPublishLiveStream;

// publish default streams
FOUNDATION_EXTERN NSString * const KPublishDefaultStreams;

// unpublish default streams
FOUNDATION_EXTERN NSString * const KUnPublishDefaultStreams;

// publishStreams
FOUNDATION_EXTERN NSString * const KPublishStreams;

// unpublishStreams
FOUNDATION_EXTERN NSString * const KUnPublishStreams;

// getDefaultVideoStream
FOUNDATION_EXTERN NSString * const KGetDefaultVideoStream;

// getDefaultAudioStream
FOUNDATION_EXTERN NSString * const KGetDefaultAudioStream;

FOUNDATION_EXTERN NSString * const KGetAudioEffectManager;

FOUNDATION_EXTERN NSString * const KSetVideoTextureView;

FOUNDATION_EXTERN NSString * const KCreateVideoTextureView;

FOUNDATION_EXTERN NSString * const KReleaseVideoTextureView;

// subscribe live stream
FOUNDATION_EXTERN NSString * const KSubscribeLiveStream;

// unsubscribe live stream
FOUNDATION_EXTERN NSString * const KUnsubscribeLiveStream;

// subscribe stream
FOUNDATION_EXTERN NSString * const KSubscribeStream;

// unsubscribe stream
FOUNDATION_EXTERN NSString * const KUnSubscribeStream;

// switchToNormalStream
FOUNDATION_EXTERN NSString * const KSwitchToNormalStream;

// switchToTinyStream
FOUNDATION_EXTERN NSString * const KSwitchToTinyStream;

// on user join
FOUNDATION_EXTERN NSString * const KOnUserJoin;

// on user left
FOUNDATION_EXTERN NSString * const KOnUserLeft;

// on remote user publish stream
FOUNDATION_EXTERN NSString * const kOnRemoteUserPublishStream;

// on remote user unpublish stream
FOUNDATION_EXTERN NSString * const KOnRemoteUserUnPublishStream;

FOUNDATION_EXTERN NSString * const KPreloadEffect;

FOUNDATION_EXTERN NSString * const KUnloadEffect;

FOUNDATION_EXTERN NSString * const KPlayEffect;

FOUNDATION_EXTERN NSString * const KPauseEffect;

FOUNDATION_EXTERN NSString * const KPauseAllEffects;

FOUNDATION_EXTERN NSString * const KResumeEffect;

FOUNDATION_EXTERN NSString * const KResumeAllEffects;

FOUNDATION_EXTERN NSString * const KStopEffect;

FOUNDATION_EXTERN NSString * const KStopAllEffects;

FOUNDATION_EXTERN NSString * const KSetEffectsVolume;

FOUNDATION_EXTERN NSString * const KGetEffectsVolume;

FOUNDATION_EXTERN NSString * const KSetEffectVolume;

FOUNDATION_EXTERN NSString * const KGetEffectVolume;

FOUNDATION_EXTERN NSString * const KSetAttributeValue;

FOUNDATION_EXTERN NSString * const KDeleteAttributes;

FOUNDATION_EXTERN NSString * const KGetAttributes;

FOUNDATION_EXTERN NSString * const KSetRoomAttributeValue;

FOUNDATION_EXTERN NSString * const KDeleteRoomAttributes;

FOUNDATION_EXTERN NSString * const KGetRoomAttributes;

FOUNDATION_EXTERN NSString * const KSendMessage;

FOUNDATION_EXTERN NSString * const KAddPublishStreamUrl;

FOUNDATION_EXTERN NSString * const KRemovePublishStreamUrl;

FOUNDATION_EXTERN NSString * const KSetMixConfig;

FOUNDATION_EXTERN NSString * const KStartMix;

FOUNDATION_EXTERN NSString * const KSetMixingVolume;

FOUNDATION_EXTERN NSString * const KGetMixingVolume;

FOUNDATION_EXTERN NSString * const KSetPlaybackVolume;

FOUNDATION_EXTERN NSString * const KGetPlaybackVolume;

FOUNDATION_EXTERN NSString * const KSetVolume;

FOUNDATION_EXTERN NSString * const KGetDurationMillis;

FOUNDATION_EXTERN NSString * const KGetCurrentPosition;

FOUNDATION_EXTERN NSString * const KSeekTo;

FOUNDATION_EXTERN NSString * const KPause;

FOUNDATION_EXTERN NSString * const KResume;

FOUNDATION_EXTERN NSString * const KStop;

FOUNDATION_EXTERN NSString * const KCreateVideoOutputStream;

FOUNDATION_EXTERN NSString * const KSetMediaServerUrl;

FOUNDATION_EXTERN NSString * const KRegisterStatusReportListener;

FOUNDATION_EXTERN NSString * const KUnRegisterStatusReportListener;
