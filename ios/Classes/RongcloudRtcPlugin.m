#import "RongcloudRtcPlugin.h"
#import "RCFlutterRTCWrapper.h"
#import "RCFlutterRTCViewFactory.h"

@implementation RongcloudRtcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.rongcloud.im/rtc_plugin"
            binaryMessenger:[registrar messenger]];
    RongcloudRtcPlugin* instance = [[RongcloudRtcPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [[RCFlutterRTCWrapper sharedInstance] saveMethodChannel:channel];
    RCFlutterRTCViewFactory * viewFactory = [RCFlutterRTCViewFactory sharedInstance];
    [viewFactory initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:viewFactory withId:@"plugins.rongcloud.im/rtc_view"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[RCFlutterRTCWrapper sharedInstance] rtcHandleMethodCall:call result:result];
}

@end
