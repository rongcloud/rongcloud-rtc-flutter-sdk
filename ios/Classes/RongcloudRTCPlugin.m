#import "RongcloudRtcPlugin.h"
#import "RCFlutterEngine.h"
#import "RCFlutterChannelKey.h"
#import "RCFlutterVideoCapture.h"

@implementation RongcloudRTCPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    // plugin channel
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:KPlugin
              binaryMessenger:[registrar messenger]];
    RCFlutterEngine *engine = [RCFlutterEngine sharedEngine];
    engine.pluginRegister = registrar;
    [registrar addMethodCallDelegate:engine channel:channel];
    
}

@end
