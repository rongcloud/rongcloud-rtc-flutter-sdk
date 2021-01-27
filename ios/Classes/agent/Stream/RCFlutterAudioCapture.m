#import "RCFlutterAudioCapture.h"
#import "RCFlutterOutputStream+Private.h"
#import "RCFlutterAudioCapture+Apis.h"
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterEngine.h"
#import "RCFlutterOutputStream+Private.h"

@interface RCFlutterOutputStream ()

@property(nonatomic, strong) RCRTCOutputStream *rtcOutputStream;

@end
@interface RCFlutterAudioCapture()
@property(nonatomic, strong) RCRTCMicOutputStream *rtcAudioCapture;

@end
@implementation RCFlutterAudioCapture

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    NSLog(@"RCFlutterVideoCapture registerWithRegistrar");
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@",call.method);
    if ([call.method  isEqualToString:KSetMicrophoneDisable]) {
        NSNumber *disable = (NSNumber *)call.arguments;
        [self setMicrophoneDisable:disable.boolValue];
        result(@(0));
    } else if ([call.method isEqualToString:KAdjustRecordingVolume]) {
        [self adjustRecordingVolume:call result:result];
    } else if ([call.method isEqualToString:KGetRecordingVolume]) {
        [self getRecordingVolume:result];
    } else if ([call.method isEqualToString:KMute]) {
        [super handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)adjustRecordingVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    int volume = [call.arguments intValue];
    [self adjustRecordingVolume:volume];
    result(nil);
}

- (void)getRecordingVolume:(FlutterResult)result {
    int volume = [self getRecordingVolume];
    result(@(volume));
}

#pragma mark - instance

SingleInstanceM(AudioCapture);

- (instancetype)init {
    if (self = [super init]) {
        // 默认加载麦克风资源
        [self rtcAudioCapture];
    }
    return self;
}

- (RCRTCMicOutputStream *)rtcAudioCapture{
    if (_rtcAudioCapture) {
        return _rtcAudioCapture;
    } else {
        RCRTCMicOutputStream *audio = [[RCFlutterRTCManager sharedRTCManager] getRTCAudioOutputStream];
        _rtcAudioCapture = audio;
        self.rtcOutputStream = audio;
        [self registerStream:audio];
        [self registerStreamChannel];
        return audio;
    }
}

- (void)destroy {
   
}

@end
