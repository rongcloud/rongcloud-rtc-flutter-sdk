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
    } else if ([call.method isEqualToString:KMute]){
        [super handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
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
        [self registerStreamChannel];
        return audio;
    }
}
- (void)destroy {
   
}

@end
