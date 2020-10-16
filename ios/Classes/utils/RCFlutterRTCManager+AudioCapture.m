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
@end

#pragma clang diagnostic pop
