#import "RCFlutterInputStream.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterInputStream+Private.h"
#import "RCFlutterTextureViewFactory.h"

@interface RCFlutterInputStream ()

@property(nonatomic, strong) RCRTCInputStream *rtcInputStream;
@end

@implementation RCFlutterInputStream

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self registerStreamChannel];
//    }
//    return self;
//}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"RCFlutterInputStream handleMethodCall %@", call.method);
    if ([call.method isEqualToString:KSetVideoTextureView]) {
        [self setVideoTextureView:(NSNumber *) call.arguments];
    } else if ([call.method isEqualToString:KMute]) {
        [super handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setRtcInputStream:(RCRTCInputStream *)rtcInputStream {
    _rtcInputStream = rtcInputStream;
    if (_rtcInputStream != nil) {
        [self registerStream:rtcInputStream];
    }
}

- (void)setVideoTextureView:(NSNumber *)textureId {
    RCFlutterTextureView *view = [[RCFlutterTextureViewFactory sharedViewFactory] get:textureId.integerValue];
    [(RCRTCVideoInputStream *) (self.rtcInputStream) setVideoTextureView:view.nativeView];
}

- (void)dealloc {
    RCLogI(@"RongFlutterInputStream dealloc");
    self.rtcInputStream = nil;
}
@end
