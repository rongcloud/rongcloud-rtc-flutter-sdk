#import "RCFlutterInputStream.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterInputStream+Private.h"
#import "RCFlutterRenderViewFactory.h"

@interface RCFlutterInputStream ()

@property(nonatomic, strong) RCRTCInputStream *rtcInputStream;
@end

@implementation RCFlutterInputStream

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@", call.method);
    if ([call.method isEqualToString:KRenderView]) {
        [self renderView:(NSNumber *) call.arguments];
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

- (void)renderView:(NSNumber *)args {
    int viewId = args.intValue;
    RCFlutterRenderView *remoteView =
        (RCRTCRemoteVideoView *) [[RCFlutterRenderViewFactory sharedViewFactory] getViewWithId:viewId andType:RongFlutterRenderViewTypeRemoteView];
    [(RCRTCVideoInputStream *) (self.rtcInputStream) setVideoView:remoteView.previewView];
}


- (void)dealloc {
    RCLogI(@"RongFlutterInputStream dealloc");
    self.rtcInputStream = nil;
}
@end
