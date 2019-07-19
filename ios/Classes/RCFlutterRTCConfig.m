//
//  RCFlutterRTCConfig.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/19.
//

#import "RCFlutterRTCConfig.h"

@interface RCFlutterRTCConfig ()
@property(nonatomic,strong) RongRTCVideoCaptureParam *captureParam;
@end

@implementation RCFlutterRTCConfig
+ (instancetype)sharedConfig {
    static RCFlutterRTCConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

- (void)updateParam:(NSDictionary *)dic {
    int videoSize = [dic[@"videoSize"] intValue];
    int cameraType = [dic[@"cameraType"] intValue];
    BOOL turnOnCamera = [dic[@"turnOnCamera"] boolValue];
    
    self.captureParam.videoSizePreset = [self genVideoSizePreset:videoSize];
    self.captureParam.camera = [self genCameraType:cameraType];
    self.captureParam.turnOnCamera = turnOnCamera;
}

- (RongRTCVideoSizePreset)genVideoSizePreset:(int)value {
    RongRTCVideoSizePreset size = RongRTCVideoSizePreset640x480;
    switch (value) {
        case 256144:
            size = RongRTCVideoSizePreset256x144;
            break;
        case 320240:
            size = RongRTCVideoSizePreset320x240;
            break;
        case 480360:
            size = RongRTCVideoSizePreset480x360;
            break;
        case 640360:
            size = RongRTCVideoSizePreset640x360;
            break;
        case 640480:
            size = RongRTCVideoSizePreset640x480;
            break;
        case 720480:
            size = RongRTCVideoSizePreset720x480;
            break;
        case 1280720:
            size = RongRTCVideoSizePreset1280x720;
            break;
        default:
            //todo
            break;
    }
    return size;
}

- (RongRTCDeviceCamera)genCameraType:(int)value {
    RongRTCDeviceCamera type = RongRTCCaptureDeviceFront;
    if(1 == type) {
        type = RongRTCCaptureDeviceFront;
    }else if(2 == type) {
        type = RongRTCCaptureDeviceBack;
    }else {
        //todo
    }
    return type;
}

- (RongRTCVideoCaptureParam *)captureParam {
    if(!_captureParam) {
        _captureParam = [RongRTCVideoCaptureParam defaultParameters];
    }
    return _captureParam;
}

@end
