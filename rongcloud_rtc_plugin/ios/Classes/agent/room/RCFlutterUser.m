#import "RCFlutterUser.h"
#import "RCFlutterEngine.h"
#import "RCFlutterChannelKey.h"
#import "RCFlutterRemoteUser.h"
#import "RCFlutterLocalUser.h"
@interface RCFlutterUser ()

@property(nonatomic, copy) NSString *userId;
@property(nonatomic, strong) RCRTCUser *rtcUser;
@end

@implementation RCFlutterUser

@synthesize userId = _userId;

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@", call.method);
}

+ (void)registerWithRegistrar:(nonnull NSObject <FlutterPluginRegistrar> *)registrar {
    
}
- (void)setRtcUser:(RCRTCUser *)rtcUser {
    _rtcUser = rtcUser;
    [self configUserWithID:rtcUser.userId];
}
- (void)configUserWithID:(NSString *)userId {
    self.userId = userId;
}
- (void)registerChannel {
    if (!_rtcUser) {
        return;
    }
    [self registerUserChannel];
}

/// 注册 user channel ： 用于 user 相关动作
- (void)registerUserChannel {
    //rong.flutter.rtclib/RemoteUser:15699998823_09C2_ios
    NSString *channelId = [NSString stringWithFormat:@"%@%@", KUser, self.userId];
    FlutterMethodChannel *streamChannel = [FlutterMethodChannel
                                           methodChannelWithName:channelId
                                           binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:streamChannel];
}
@end
