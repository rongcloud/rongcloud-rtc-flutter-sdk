#import "RCFlutterRTCManager+VideoCapture.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation RCFlutterRTCManager (VideoCapture)

- (RCRTCCameraOutputStream *)getRTCCameraOutputStream {
    return [RCRTCEngine sharedInstance].defaultVideoStream;
}

- (void)startCapture {
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
}

- (bool)switchCamera {
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
    return [RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition  == RCRTCCaptureDeviceFront;
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

#pragma clang diagnostic pop
