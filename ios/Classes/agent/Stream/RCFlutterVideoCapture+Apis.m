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

- (void)renderView:(RCRTCLocalVideoView *)localView {
    [[RCFlutterRTCManager sharedRTCManager] renderView:localView];
}

- (void)setVideoConfig:(RCRTCVideoStreamConfig *)config {
    [[RCFlutterRTCManager sharedRTCManager] setVideoConfig:config];
}

@end
