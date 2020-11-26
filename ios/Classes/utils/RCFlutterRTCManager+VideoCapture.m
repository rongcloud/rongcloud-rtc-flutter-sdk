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

- (void)startCapture:(NSNumber *)type {
    if (type == 0) {
        [RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition = AVCaptureDevicePositionFront;
        [RCRTCEngine sharedInstance].defaultVideoStream.isPreviewMirror = true;
    } else {
        [RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition = AVCaptureDevicePositionBack;
        [RCRTCEngine sharedInstance].defaultVideoStream.isPreviewMirror = false;
    }
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
}

- (bool)switchCamera {
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
    return [RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition  == RCRTCCaptureDeviceFront;
}

- (void)stopCamera {
    [[RCRTCEngine sharedInstance].defaultVideoStream stopCapture];
}

- (BOOL)isCameraFocusSupported {
    return [[RCRTCEngine sharedInstance].defaultVideoStream isCameraFocusSupported];
}

- (BOOL)isCameraExposurePositionSupported {
    return [[RCRTCEngine sharedInstance].defaultVideoStream isCameraExposurePositionSupported];
}

- (BOOL)setCameraFocusPositionInPreview:(CGPoint)point {
    return [[RCRTCEngine sharedInstance].defaultVideoStream setCameraFocusPositionInPreview:point];
}

- (BOOL)setCameraExposurePositionInPreview:(CGPoint)point {
    return [[RCRTCEngine sharedInstance].defaultVideoStream setCameraExposurePositionInPreview:point];
}

- (void)setVideoTextureView:(RCRTCVideoTextureView *)view {
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoTextureView:view];
}

- (void)setVideoConfig:(RCRTCVideoStreamConfig *)config {
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:config];
}

- (void)setIsMute:(BOOL)mute {
    [[RCRTCEngine sharedInstance].defaultVideoStream setIsMute:mute];
}
@end

#pragma clang diagnostic pop
