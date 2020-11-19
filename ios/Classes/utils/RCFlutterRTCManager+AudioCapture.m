#import "RCFlutterRTCManager+AudioCapture.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation RCFlutterRTCManager (AudioCapture)

- (RCRTCMicOutputStream *)getRTCAudioOutputStream{
    return [RCRTCEngine sharedInstance].defaultAudioStream;;
}

- (void)setMicrophoneDisable:(BOOL)disable{
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:disable];
}

- (void)setIsMute:(BOOL)mute{
    [[RCRTCEngine sharedInstance].defaultAudioStream setIsMute:mute];
}

- (void)adjustRecordingVolume:(int)volume {
    [RCRTCEngine sharedInstance].defaultAudioStream.recordingVolume = volume;
}

- (int)getRecordingVolume {
    return [RCRTCEngine sharedInstance].defaultAudioStream.recordingVolume;
}

@end

#pragma clang diagnostic pop
