#import "RCFlutterVideoCapture+Apis.h"

@implementation RCFlutterVideoCapture (Apis)

- (void)startCapture {
    [[RCFlutterRTCManager sharedRTCManager] startCapture];
}

- (bool)switchCamera {
    return [[RCFlutterRTCManager sharedRTCManager] switchCamera];
}

- (void)stopCamera {
    [[RCFlutterRTCManager sharedRTCManager] stopCamera];
}

- (BOOL)isCameraFocusSupported {
    return [[RCFlutterRTCManager sharedRTCManager] isCameraFocusSupported];
}

- (BOOL)isCameraExposurePositionSupported {
    return [[RCFlutterRTCManager sharedRTCManager] isCameraExposurePositionSupported];
}

- (BOOL)setCameraExposurePositionInPreview:(CGPoint)point {
    return [[RCFlutterRTCManager sharedRTCManager] setCameraExposurePositionInPreview:point];
}

- (BOOL)setCameraFocusPositionInPreview:(CGPoint)point {
    return [[RCFlutterRTCManager sharedRTCManager] setCameraFocusPositionInPreview:point];
}

- (void)setVideoTextureView:(RCRTCVideoTextureView *)view {
    [[RCFlutterRTCManager sharedRTCManager] setVideoTextureView:view];
}

- (void)setVideoConfig:(RCRTCVideoStreamConfig *)config {
    [[RCFlutterRTCManager sharedRTCManager] setVideoConfig:config];
}

@end
