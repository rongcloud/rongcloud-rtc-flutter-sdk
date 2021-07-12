#import "RCFlutterVideoCapture.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterOutputStream+Private.h"
#import "RCFlutterVideoCapture+Apis.h"
#import "RCFlutterRTCManager.h"
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterEngine.h"
#import "RCFlutterTextureViewFactory.h"
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

- (void)dealloc{
    NSLog(@"RCFlutterVideoCapture dealloc");
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KStartCapture]) {
        RCLogI(@"ios start capture");
        [self startCapture];
        result([NSNumber numberWithInt:0]);
    } else if ([call.method isEqualToString:KStartCaptureByType]) {
        [self startCapture:(NSNumber *)call.arguments];
        result([NSNumber numberWithInt:0]);
    } else if ([call.method isEqualToString:KSetVideoTextureView]) {
        [self setVideoTextureView:call result:result];
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
    } else if ([call.method isEqualToString:KSetTinyVideoConfig]) {
        NSDictionary *dic = [RCFlutterTools decodeToDic:call.arguments];
        BOOL res = [self setTinyVideoConfigFromFlutter:dic];
        result([NSNumber numberWithBool:res]);
    } else if ([call.method isEqualToString:KEnableTinyStream]) {
        NSNumber *enable = (NSNumber *)call.arguments;
        [self enableTinyStream:[enable boolValue]];
        result(nil);
    } else if ([call.method isEqualToString:KIsCameraFocusSupported]) {
        [self isCameraFocusSupported:result];
    } else if ([call.method isEqualToString:KIsCameraExposurePositionSupported]) {
        [self isCameraExposurePositionSupported:result];
    } else if ([call.method isEqualToString:KSetCameraFocusPositionInPreview]) {
        [self setCameraFocusPositionInPreview:call result:result];
    } else if ([call.method isEqualToString:KSetCameraExposurePositionInPreview]) {
        [self setCameraExposurePositionInPreview:call result:result];
    } else if ([call.method isEqualToString:KSetCameraCaptureOrientation]) {
        [self setCameraCaptureOrientation:call result:result];
    } else if ([call.method isEqualToString:KSetEncoderMirror]) {
        [self setEncoderMirror:call result:result];
    } else if ([call.method isEqualToString:KMute]){
        [super handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)enableTinyStream:(bool)enable {
    [[RCRTCEngine sharedInstance].defaultVideoStream setEnableTinyStream:enable];
}

- (void)isCameraFocusSupported:(FlutterResult)result {
    BOOL supported = [self isCameraFocusSupported];
    result(@(supported));
}

- (void)isCameraExposurePositionSupported:(FlutterResult)result {
    BOOL supported = [self isCameraExposurePositionSupported];
    result(@(supported));
}

- (void)setCameraFocusPositionInPreview:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    float x = [dic[@"x"] floatValue];
    float y = [dic[@"y"] floatValue];
    CGPoint point = CGPointMake(x, y);
    BOOL success = [self setCameraFocusPositionInPreview:point];
    result(@(success));
}

- (void)setCameraExposurePositionInPreview:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    float x = [dic[@"x"] floatValue];
    float y = [dic[@"y"] floatValue];
    CGPoint point = CGPointMake(x, y);
    BOOL success = [self setCameraExposurePositionInPreview:point];
    result(@(success));
}

- (void)setCameraCaptureOrientation:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    int orientation = [dic[@"orientation"] intValue] + 1;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoOrientation:(AVCaptureVideoOrientation)orientation];
    result(nil);
}

- (void)setEncoderMirror:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL mirror = [call.arguments boolValue];
    [[RCRTCEngine sharedInstance].defaultVideoStream setIsEncoderMirror:mirror];
    result(nil);
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

- (BOOL)setTinyVideoConfigFromFlutter:(NSDictionary *)config {
    RCRTCVideoStreamConfig *videoConfig = [self getStreamConfig:config];
    return [self setTinyVideoConfig:videoConfig];
}

- (void)setVideoTextureView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *textureId = (NSNumber *)call.arguments;
    RCFlutterTextureView *view = [[RCFlutterTextureViewFactory sharedViewFactory] get:textureId.integerValue];
    [self setVideoTextureView:view.nativeView];
}

- (RCRTCCameraOutputStream *)rtcVideoCapture {
    if (_rtcVideoCapture) {
        return _rtcVideoCapture;
    } else {
        RCRTCCameraOutputStream *camera = [[RCFlutterRTCManager sharedRTCManager] getRTCCameraOutputStream];
        _rtcVideoCapture = camera;
        self.rtcOutputStream = camera;
        [self registerStream:camera];
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
        @"RESOLUTION_144_176":@(RCRTCVideoSizePreset176x144),
        @"RESOLUTION_144_256":@(RCRTCVideoSizePreset256x144),
    
        @"RESOLUTION_180_180":@(RCRTCVideoSizePreset180x180),
        @"RESOLUTION_180_240":@(RCRTCVideoSizePreset240x180),
        @"RESOLUTION_180_320":@(RCRTCVideoSizePreset320x180),
    
        @"RESOLUTION_240_240":@(RCRTCVideoSizePreset240x240),
        @"RESOLUTION_240_320":@(RCRTCVideoSizePreset320x240),
    
        @"RESOLUTION_360_360":@(RCRTCVideoSizePreset360x360),
        @"RESOLUTION_360_480":@(RCRTCVideoSizePreset480x360),
        @"RESOLUTION_360_640":@(RCRTCVideoSizePreset640x360),
    
        @"RESOLUTION_480_480":@(RCRTCVideoSizePreset480x480),
        @"RESOLUTION_480_640":@(RCRTCVideoSizePreset640x480),
        @"RESOLUTION_480_720":@(RCRTCVideoSizePreset720x480),
    
        @"RESOLUTION_720_1280":@(RCRTCVideoSizePreset1280x720),
    
        @"RESOLUTION_1080_1920":@(RCRTCVideoSizePreset1920x1080),
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
