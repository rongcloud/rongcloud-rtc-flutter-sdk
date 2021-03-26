#import "RCFlutterChannelKey.h"

#pragma mark - channel

NSString * const KPlugin = @"rong.flutter.rtclib/engine";

// init camera
NSString * const KInitCamera = @"rong.flutter.rtclib/RCRTCCameraOutputStream";

// init audio
NSString * const KInitAudio = @"rong.flutter.rtclib/RCFlutterMicOutputStream";

// local user action
NSString * const KUser = @"rong.flutter.rtclib/User:";

// rtc tag
NSString * const KRTCTag = @"RongCloudRTC";

// mediastream channel
NSString * const KMediaStream = @"rong.flutter.rtclib/Stream:";

// room channel
NSString * const KRoom = @"rong.flutter.rtclib/Room:";

// audio effect manager channel
NSString * const KAudioEffectManager = @"rong.flutter.rtclib/AudioEffectManager:";

// audio mixer channel
NSString * const KAudioMixer = @"rong.flutter.rtclib/AudioMixer";

#pragma mark - action on channel
// init
NSString * const KInit = @"init";

// unInit
NSString * const KUnInit = @"unInit";

// join room
NSString * const KJoinRoom = @"joinRoom";

// startCapture
NSString * const KStartCapture = @"startCamera";

// startCapture
NSString * const KStartCaptureByType = @"startCameraByType";

// switchCamera
NSString * const KSwitchCamera = @"switchCamera";

// setVideoConfig
NSString * const KSetVideoConfig = @"setVideoConfig";

// stopCamera
NSString * const KStopCamera = @"stopCamera";

NSString * const KEnableTinyStream = @"enableTinyStream";

NSString * const KIsCameraFocusSupported = @"isCameraFocusSupported";

NSString * const KIsCameraExposurePositionSupported = @"isCameraExposurePositionSupported";

NSString * const KSetCameraExposurePositionInPreview = @"setCameraExposurePositionInPreview";

NSString * const KSetCameraFocusPositionInPreview = @"setCameraFocusPositionInPreview";

NSString * const KSetCameraCaptureOrientation = @"setCameraCaptureOrientation";

// mute
NSString * const KMute = @"mute";

// setMicrophoneDisable
NSString * const KSetMicrophoneDisable = @"setMicrophoneDisable";

NSString * const KAdjustRecordingVolume = @"adjustRecordingVolume";

NSString * const KGetRecordingVolume = @"getRecordingVolume";

// enableSpeaker
NSString * const KEnableSpeaker = @"enableSpeaker";

// leaveRTCRoom
NSString * const KLeaveRTCRoom = @"leaveRoom";

NSString * const KGetStreams = @"getStreams";

// public default live streams
NSString * const KPublishDefaultLiveStreams = @"publishDefaultLiveStreams";

// publish live stream
NSString * const KPublishLiveStream = @"publishLiveStream";

// publish default streams
NSString * const KPublishDefaultStreams = @"publishDefaultStreams";

// unpublish default streams
NSString * const KUnPublishDefaultStreams = @"unPublishDefaultStreams";

// publishStreams
NSString * const KPublishStreams = @"publishStreams";

// unpublishStreams
NSString * const KUnPublishStreams = @"unPublishStreams";

// getDefaultVideoStream
NSString * const KGetDefaultVideoStream = @"getDefaultVideoStream";

// getDefaultAudioStream
NSString * const KGetDefaultAudioStream = @"getDefaultAudioStream";

NSString * const KGetAudioEffectManager = @"getAudioEffectManager";

NSString * const KSetVideoTextureView = @"setTextureView";

NSString * const KCreateVideoTextureView = @"createVideoRenderer";

NSString * const KReleaseVideoTextureView = @"disposeVideoRenderer";

// subscribe live stream
//NSString * const KSubscribeLiveStream = @"subscribeLiveStream";

// unsubscribe live stream
//NSString * const KUnsubscribeLiveStream = @"unsubscribeLiveStream";

// subscribe stream
NSString * const KSubscribeStream = @"subscribeStreams";

// subscribe stream
NSString * const KUnSubscribeStream = @"unsubscribeStreams";

// switchToNormalStream
NSString * const KSwitchToNormalStream = @"switchToNormalStream";

// switchToTinyStream
NSString * const KSwitchToTinyStream = @"switchToTinyStream";

// on user join
NSString * const KOnUserJoin = @"onUserJoined";

// on user offline
NSString * const KOnUserOffline = @"onUserOffline";

// on user left
NSString * const KOnUserLeft = @"onUserLeft";

// on remote user publish stream
NSString * const kOnRemoteUserPublishStream = @"onRemoteUserPublishResource";

// on remote user unpublish stream
NSString * const KOnRemoteUserUnPublishStream = @"onRemoteUserUnPublishResource";

// on remote user publish Live stream
NSString * const kOnRemoteUserPublishLiveStream = @"onRemoteUserPublishLiveResource";

// on remote user unpublish Live stream
NSString * const KOnRemoteUserUnPublishLiveStream = @"onRemoteUserUnPublishLiveResource";

NSString * const KPreloadEffect = @"preloadEffect";

NSString * const KUnloadEffect = @"unloadEffect";

NSString * const KPlayEffect = @"playEffect";

NSString * const KPauseEffect = @"pauseEffect";

NSString * const KPauseAllEffects = @"pauseAllEffects";

NSString * const KResumeEffect = @"resumeEffect";

NSString * const KResumeAllEffects = @"resumeAllEffects";

NSString * const KStopEffect = @"stopEffect";

NSString * const KStopAllEffects = @"stopAllEffects";

NSString * const KSetEffectsVolume = @"setEffectsVolume";

NSString * const KGetEffectsVolume = @"getEffectsVolume";

NSString * const KSetEffectVolume = @"setEffectVolume";

NSString * const KGetEffectVolume = @"getEffectVolume";

NSString * const KSetAttributeValue = @"setAttributeValue";

NSString * const KDeleteAttributes = @"deleteAttributes";

NSString * const KGetAttributes = @"getAttributes";

NSString * const KSetRoomAttributeValue = @"setRoomAttributeValue";

NSString * const KDeleteRoomAttributes = @"deleteRoomAttributes";

NSString * const KGetRoomAttributes = @"getRoomAttributes";

NSString * const KSendMessage = @"sendMessage";

NSString * const KAddPublishStreamUrl = @"addPublishStreamUrl";

NSString * const KRemovePublishStreamUrl = @"removePublishStreamUrl";

NSString * const KGetLiveStreams = @"getLiveStreams";

NSString * const KSetMixConfig = @"setMixConfig";

NSString * const KStartMix = @"startMix";

NSString * const KSetMixingVolume = @"setMixingVolume";

NSString * const KGetMixingVolume = @"getMixingVolume";

NSString * const KSetPlaybackVolume = @"setPlaybackVolume";

NSString * const KGetPlaybackVolume = @"getPlaybackVolume";

NSString * const KSetVolume = @"setVolume";

NSString * const KGetDurationMillis = @"getDurationMillis";

NSString * const KGetCurrentPosition = @"getCurrentPosition";

NSString * const KSeekTo = @"seekTo";

NSString * const KPause = @"pause";

NSString * const KResume = @"resume";

NSString * const KStop = @"stop";

NSString * const KCreateVideoOutputStream = @"createVideoOutputStream";

NSString * const KSetMediaServerUrl = @"setMediaServerUrl";

NSString * const KRegisterStatusReportListener = @"registerStatusReportListener";

NSString * const KUnRegisterStatusReportListener = @"unRegisterStatusReportListener";
