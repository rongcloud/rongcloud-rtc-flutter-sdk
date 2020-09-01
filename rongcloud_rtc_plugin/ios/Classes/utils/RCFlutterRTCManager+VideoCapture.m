#import "RCFlutterRTCManager+VideoCapture.h"

@implementation RCFlutterRTCManager (VideoCapture)

- (RCRTCCameraOutputStream *)getRTCCameraOutputStream {
    return [RCRTCEngine sharedInstance].defaultVideoStream;
}

- (void)startCapture {
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
}

- (void)switchCamera {
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
}

- (void)stopCamera {
    [[RCRTCEngine sharedInstance].defaultVideoStream stopCapture];
}

- (void)renderView:(RCRTCLocalVideoView *)localView {
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:localView];
}

- (void)setVideoConfig:(RCRTCVideoStreamConfig *)config {
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:config];
}

- (void)setIsMute:(BOOL)mute {
    [[RCRTCEngine sharedInstance].defaultVideoStream setIsMute:mute];
}
@end
