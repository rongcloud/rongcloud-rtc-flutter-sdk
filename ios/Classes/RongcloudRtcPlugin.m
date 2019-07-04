#import "RongcloudRtcPlugin.h"
#import "RCFlutterRTCWrapper.h"

@implementation RongcloudRtcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"rongcloud_rtc_plugin"
            binaryMessenger:[registrar messenger]];
  RongcloudRtcPlugin* instance = [[RongcloudRtcPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [[RCFlutterRTCWrapper sharedInstance] saveMethodChannel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[RCFlutterRTCWrapper sharedInstance] rtcHandleMethodCall:call result:result];
}

@end
