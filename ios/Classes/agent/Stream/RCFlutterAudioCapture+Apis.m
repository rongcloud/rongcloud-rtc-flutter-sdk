#import "RCFlutterAudioCapture+Apis.h"

@implementation RCFlutterAudioCapture (Apis)

- (void)setMicrophoneDisable:(BOOL)disable {
    [[RCFlutterRTCManager sharedRTCManager] setMicrophoneDisable:disable];
}

- (void)adjustRecordingVolume:(int)volume {
    [[RCFlutterRTCManager sharedRTCManager] adjustRecordingVolume:volume];
}

- (int)getRecordingVolume {
    return [[RCFlutterRTCManager sharedRTCManager] getRecordingVolume];
}

@end
