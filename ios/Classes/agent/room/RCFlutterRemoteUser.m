#import "RCFlutterRemoteUser.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterInputStream+Private.h"
#import "RCFlutterUser+Private.h"
#import "RCFlutterRemoteUser+Private.h"
#import "RCFlutterRTCManager.h"
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterRemoteUser+Apis.h"
#import "RCFlutterTools.h"
#import "RCFlutterRoom+Private.h"
#import "RCFlutterEngine.h"
#import "RCFlutterEngine+Private.h"

@interface RCFlutterRemoteUser ()

@property(nonatomic, copy) NSArray<RCFlutterInputStream *> *remoteAVStreams;


@end

@implementation RCFlutterRemoteUser

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@", call.method);
    if ([call.method isEqualToString:KSubscribeStream]) {
        result(FlutterMethodNotImplemented);
    } else if ([call.method isEqualToString:KSwitchToTinyStream]) {
        NSArray
        *streams = [RCFlutterTools decodeToArray:call.arguments];
        [self switchToTinyStream:streams result:result];
    } else if ([call.method isEqualToString:KSwitchToNormalStream]) {
        NSArray
        *streams = [RCFlutterTools decodeToArray:call.arguments];
        [self switchToNormalStream:streams result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.remoteAVStreams = [NSMutableArray array];
    }
    return self;
}
- (void)setRtcUser:(RCRTCUser *)rtcUser {
    [super setRtcUser:rtcUser];
    [self registerChannel];
    NSMutableArray *arr = [NSMutableArray array];
    for (RCRTCInputStream *inputStream in ((RCRTCRemoteUser *)rtcUser).remoteStreams) {
        RCFlutterInputStream *rfistm = [[RCFlutterInputStream alloc] init];
        rfistm.rtcInputStream = inputStream;
        [rfistm registerStreamChannel];
        [arr addObject:rfistm];
    }
    self.remoteAVStreams = arr;
}

- (void)switchToTinyStream:(NSArray *)streams result:(FlutterResult)result {
    NSArray *toTinys = [self getRTCRemoteInputStreamsFromRemoteUser:streams];
    
    [self remoteUser:((RCRTCRemoteUser *)self.rtcUser) switchToTinyStream:toTinys completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
    
}
- (void)switchToNormalStream:(NSArray *)streams result:(FlutterResult)result {
    NSArray *toNormalss = [self getRTCRemoteInputStreamsFromRemoteUser:streams];
    
    [self remoteUser:self.rtcUser switchToNormalStream:toNormalss completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (NSArray<RCFlutterInputStream *> *)getFlutterRemoteInputStreamsFromRemoteUser:(NSArray<NSDictionary *> *)streamDics{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streamDics) {
        for (RCFlutterInputStream *inputStream in self.remoteAVStreams) {
            if ([inputStream isEqualToStreamDic:dic]) {
                [arr addObject:inputStream];
            }
        }
    }
    // 耗时全量获取
    if (arr.count <= 0) {
        arr = [[RCFlutterEngine sharedEngine].room getFlutterRemoteInputStreamsFromRoom:streamDics].copy;
    }
    return arr.copy;
}
- (NSArray<RCRTCInputStream *> *)getRTCRemoteInputStreamsFromRemoteUser:(NSArray<NSDictionary *> *)streamDics{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streamDics) {
        for (RCFlutterInputStream *inputStream in self.remoteAVStreams) {
            if ([inputStream isEqualToStreamDic:dic]) {
                [arr addObject:inputStream.rtcInputStream];
            }
        }
    }
    // 耗时全量获取
    if (arr.count <= 0) {
        arr = [[RCFlutterEngine sharedEngine].room getRTCRemoteInputStreamsFromRoom:streamDics].copy;
    }
    return arr.copy;
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.userId) {
        [dic setObject:self.userId forKey:@"id"];
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCFlutterInputStream *inputStream in self.remoteAVStreams) {
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
        }
        [dic setValue:streamList forKey:@"streamList"];
    }
    return dic;;
}

- (void)dealloc {
    RCLogI(@"RCFlutterRemoteUser dealloc");
    self.remoteAVStreams = nil;
    self.rtcUser = nil;
}
@end
