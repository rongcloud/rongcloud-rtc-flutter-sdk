//
//  RCFlutterRTCWrapper.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/4.
//

#import "RCFlutterRTCWrapper.h"
#import "RCFlutterRTCMethodKey.h"
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>

@interface RCFlutterRTCWrapper ()
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) RongRTCRoom *rtcRoom;
@end

@implementation RCFlutterRTCWrapper
+ (instancetype)sharedInstance {
    static RCFlutterRTCWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)saveMethodChannel:(FlutterMethodChannel *)channel {
    self.channel = channel;
}
- (void)rtcHandleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([RCFlutterRTCMethodKeyInit isEqualToString:call.method]) {
        [self initWithAppKey:call.arguments];
    }else if([RCFlutterRTCMethodKeyConnect isEqualToString:call.method]) {
        [self connect:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyJoinRTCRoom isEqualToString:call.method]) {
        [self joinRTCRoom:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyLeaveRTCRoom isEqualToString:call.method]) {
        [self leaveRTCRoom:call.arguments result:result];
    }
//   else {
//        result(FlutterMethodNotImplemented);
//    }
}

- (void)initWithAppKey:(id)arg {
    if([arg isKindOfClass:[NSString class]]) {
        NSString *appkey = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] initWithAppKey:appkey];
         NSLog(@"iOS init appkey %@",appkey);
    }
}

- (void)connect:(id)arg result:(FlutterResult)result {
    NSLog(@"iOS connect start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *token = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
            result(@(0));
            NSLog(@"iOS connect end success");
        } error:^(RCConnectErrorCode status) {
            result(@(status));
            NSLog(@"iOS connect end error %@",@(status));
        } tokenIncorrect:^{
            result(@(RC_CONN_TOKEN_INCORRECT));
            NSLog(@"iOS connect end error %@",@(RC_CONN_TOKEN_INCORRECT));
        }];
    }
}

- (void)joinRTCRoom:(id)arg result:(FlutterResult)result {
    NSLog(@"iOS joinRTCRoom start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        __weak typeof(self) ws = self;
        [[RongRTCEngine sharedEngine] joinRoom:roomId completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
            if(!room) {
                ws.rtcRoom = room;
            }
            result(@(code));
            NSLog(@"iOS joinRTCRoom end %@",@(code));
        }];
    }
}

- (void)leaveRTCRoom:(id)arg result:(FlutterResult)result {
    NSLog(@"iOS leaveRTCRoom start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        [[RongRTCEngine sharedEngine] leaveRoom:roomId completion:^(BOOL isSuccess, RongRTCCode code) {
            result(@(code));
            NSLog(@"iOS leaveRTCRoom end %@",@(code));
        }];
    }
}
@end
