#import "RCFlutterVideoCapture.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterOutputStream+Private.h"
#import "RCFlutterVideoCapture+Apis.h"
#import "RCFlutterRTCManager.h"
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterEngine.h"
#import "RCFlutterRenderViewFactory.h"
#import "RCFlutterOutputStream+Private.h"
#import "RCFlutterTools.h"
@interface RCFlutterOutputStream ()

@property(nonatomic, strong) RCRTCOutputStream *rtcOutputStream;

@end
@interface RCFlutterVideoCapture ()

/**
 rtc video capture
 */
@property(nonatomic, strong) RCRTCCameraOutputStream *rtcVideoCapture;
@end

@implementation RCFlutterVideoCapture

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    NSLog(@"RCFlutterVideoCapture registerWithRegistrar");
}
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KStartCapture]) {
        RCLogI(@"ios start capture");
        [self startCapture];
        result([NSNumber numberWithInt:0]);
    } else if ([call.method isEqualToString:KRenderView]) {
        [self getRenderView:(NSNumber *) call.arguments];
        result([NSNumber numberWithInt:0]);
    } else if ([call.method isEqualToString:KSwitchCamera]) {
        bool isFront = [self switchCamera];
        result([NSNumber numberWithBool:isFront]);
    } else if ([call.method isEqualToString:KStopCamera]) {
        [self stopCamera];
        result([NSNumber numberWithInt:0]);
    } else if ([call.method isEqualToString:KSetVideoConfig]) {
        NSDictionary *dic = [RCFlutterTools decodeToDic:call.arguments];
        [self setVideoConfigFromFlutter:dic];
        result([NSNumber numberWithInt:0]);
    } else if ([call.method isEqualToString:KMute]){
        [super handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - instance
SingleInstanceM(VideoCapture);
- (instancetype)init {
    if (self = [super init]) {
        // 默认加载摄像头资源
        [self rtcVideoCapture];
    }
    return self;
}
- (void)setVideoConfigFromFlutter:(NSDictionary *)config {
    RCRTCVideoStreamConfig *videoConfig = [self getStreamConfig:config];
    [self setVideoConfig:videoConfig];
}

- (void)getRenderView:(NSNumber *)args {
    dispatch_async(dispatch_get_main_queue(), ^{
        int viewId = args.intValue;
        RCFlutterRenderView *localView =
        (RCRTCLocalVideoView *) [[RCFlutterRenderViewFactory sharedViewFactory] getViewWithId:viewId andType:RongFlutterRenderViewTypeLocalView];
        [self renderLocalView:localView];
    });
}

- (void)renderLocalView:(RCFlutterRenderView *)localView {
    [self renderView:localView.previewView];
}

- (RCRTCCameraOutputStream *)rtcVideoCapture{
    if (_rtcVideoCapture) {
        return _rtcVideoCapture;
    } else {
        RCRTCCameraOutputStream *camera = [[RCFlutterRTCManager sharedRTCManager] getRTCCameraOutputStream];
        _rtcVideoCapture = camera;
        self.rtcOutputStream = camera;
        [self registerStreamChannel];
        return camera;
    }
}

- (RCRTCVideoStreamConfig *)getStreamConfig:(NSDictionary *)dic {
    RCRTCVideoStreamConfig *config = [[RCRTCVideoStreamConfig alloc] init];
    config.maxBitrate = [dic[@"maxRate"] unsignedIntegerValue];
    config.minBitrate = [dic[@"minRate"] unsignedIntegerValue];
    config.videoFps = [dic[@"videoFps"] unsignedIntegerValue];
    config.videoSizePreset = [self getResolution:dic[@"videoResolution"]];
    return config;
}
- (RCRTCVideoSizePreset)getResolution:(NSString *)resolution {
    NSDictionary *resolutionDic = @{
        @"RESOLUTION_132_176":@(RCRTCVideoSizePreset176x144),
        @"RESOLUTION_144_256":@(RCRTCVideoSizePreset256x144),
        @"RESOLUTION_180_320":@(RCRTCVideoSizePreset320x180),
        @"RESOLUTION_240_240":@(RCRTCVideoSizePreset240x240),
        @"RESOLUTION_240_320":@(RCRTCVideoSizePreset320x240),
        @"RESOLUTION_360_480":@(RCRTCVideoSizePreset480x360),
        @"RESOLUTION_360_640":@(RCRTCVideoSizePreset640x360),
        @"RESOLUTION_480_480":@(RCRTCVideoSizePreset480x480),
        @"RESOLUTION_480_640":@(RCRTCVideoSizePreset640x480),
        @"RESOLUTION_480_720":@(RCRTCVideoSizePreset720x480),
        @"RESOLUTION_720_1280":@(RCRTCVideoSizePreset1280x720),
    };
    if ([resolutionDic.allKeys containsObject:resolution]) {
        return [resolutionDic[resolution] intValue];
    } else {
        return RCRTCVideoSizePreset640x480;
    }
}
- (void)destroy {
   
}

@end
