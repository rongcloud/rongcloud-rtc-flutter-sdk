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
        //todo
    }else if([RCFlutterRTCMethodKeyLeaveRTCRoom isEqualToString:call.method]) {
        //todo
    }
//    if ([@"getPlatformVersion" isEqualToString:call.method]) {
//        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
//    } else {
//        result(FlutterMethodNotImplemented);
//    }
}

- (void)initWithAppKey:(id)arg {
    if([arg isKindOfClass:[NSString class]]) {
        NSString *appkey = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] initWithAppKey:appkey];
         NSLog(@"ios init appkey %@",appkey);
    }
}

- (void)connect:(id)arg result:(FlutterResult)result {
    NSLog(@"ios connect start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *token = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
            result(@(0));
            NSLog(@"ios connect end success");
        } error:^(RCConnectErrorCode status) {
            result(@(status));
            NSLog(@"ios connect end error %@",@(status));
        } tokenIncorrect:^{
            result(@(RC_CONN_TOKEN_INCORRECT));
            NSLog(@"ios connect end error %@",@(RC_CONN_TOKEN_INCORRECT));
        }];
    }
}
@end
