//
//  RCFlutterLiveInfo.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/9/27.
//

#import "RCFlutterLiveInfo.h"
#import "RCFlutterEngine.h"
#import "RCFlutterEngine+Private.h"

@interface RCFlutterLiveInfo ()

@property(nonatomic, copy) NSString *liveUrl;

@property(nonatomic, copy) NSString *roomId;

@property(nonatomic, copy) NSString *userId;

@property(nonatomic, strong) RCRTCLiveInfo *liveInfo;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar;

- (void)registerChannel;

@end

@implementation RCFlutterLiveInfo

@synthesize liveUrl = _liveUrl;
@synthesize roomId = _roomId;
@synthesize userId = _userId;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

+ (RCFlutterLiveInfo *) flutterLiveInfoWithLiveInfo:(RCRTCLiveInfo *)liveInfo roomId:(NSString *)roomId userId:(NSString *)userId {
    RCFlutterLiveInfo *info = [[RCFlutterLiveInfo alloc] init];
    info.liveInfo = liveInfo;
    info.liveUrl = liveInfo.liveUrl;
    info.roomId = roomId;
    info.userId = userId;
    [info registerChannel];
    return info;
}

- (void)registerChannel {
    NSString *channelId = [NSString stringWithFormat:@"rong.flutter.rtclib/LiveInfo:%@", _liveInfo.liveUrl];
    FlutterMethodChannel *streamChannel = [FlutterMethodChannel methodChannelWithName:channelId binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:streamChannel];
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.liveInfo) {
        dic[@"liveUrl"] = self.liveUrl;
        dic[@"roomId"] = self.roomId;
        dic[@"userId"] = self.userId;
    }
    return dic;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    // TODO 方法补齐
}

@end
