#import "RCFlutterRTCManager+AudioCapture.h"

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
