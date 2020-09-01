#import "RCFlutterAudioCapture+Apis.h"

@implementation RCFlutterAudioCapture (Apis)

- (void)setMicrophoneDisable:(BOOL)disable {
    [[RCFlutterRTCManager sharedRTCManager] setMicrophoneDisable:disable];
}

@end
