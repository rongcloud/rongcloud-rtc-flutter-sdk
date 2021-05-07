#import "RCFlutterRoom.h"
#import "RCFlutterLocalUser+Apis.h"
#import "RCFlutterRemoteUser+Private.h"
#import "RCFlutterEngine.h"
#import "RCFlutterRoom+Private.h"
#import "RCFlutterInputStream.h"
#import "RCFlutterInputStream+Private.h"
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterUser+Private.h"
#import "ThisClassShouldNotBelongHere.h"
#import "RCFlutterTools.h"

@interface RCFlutterRoom ()

@property(nonatomic, strong) RCRTCRoom *rtcRoom;
@property(nonatomic, copy) NSString *roomId;
@property(nonatomic, strong) RCFlutterLocalUser *localUser;
@property(nonatomic, strong,) NSArray<RCFlutterRemoteUser *> *remoteUsers;
@property(nonatomic, strong) FlutterMethodChannel *methodChannel;
@end

@implementation RCFlutterRoom

- (void)dealloc {
    RCLogI(@"RCFlutterRoom dealloc");
    self.localUser = nil;
    self.remoteUsers = nil;
    self.rtcRoom = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        self.localUser = [[RCFlutterLocalUser alloc] init];
        self.remoteUsers = [NSMutableArray array];
    }
    return self;;
}

- (void)registerRoomChannel {
    if (!self.rtcRoom.roomId) {
        return;
    }
    NSString *channelId = [NSString stringWithFormat:@"%@%@",KRoom,self.rtcRoom.roomId];
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:channelId binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:channel];
    self.methodChannel = channel;
}

- (void)setRtcRoom:(RCRTCRoom *)rtcRoom {
    @synchronized (self) {
        _rtcRoom = rtcRoom;
        _rtcRoom.delegate = self;
        self.roomId = rtcRoom.roomId;
        self.localUser.rtcUser = rtcRoom.localUser;
        [self.localUser registerChannel];
        NSMutableArray *arr = [NSMutableArray array];
        for (RCRTCRemoteUser *remoteUser in rtcRoom.remoteUsers) {
            RCFlutterRemoteUser *rfru = [[RCFlutterRemoteUser alloc] init];
            rfru.rtcUser = remoteUser;
            [rfru registerChannel];
            [arr addObject:rfru];
        }
        self.remoteUsers = arr.copy;
        [self registerRoomChannel];
    }
}

- (RCFlutterRemoteUser *)getRemoteUserFromUserId:(NSString *)userId {
    RCFlutterRemoteUser *rfru = [[RCFlutterRemoteUser alloc] init];
    for (RCFlutterRemoteUser *remoteUser in self.remoteUsers) {
        if ([remoteUser.userId isEqualToString:userId]) {
            rfru = remoteUser;
            break;
        }
    }
    return rfru;;
}

- (NSMutableDictionary *)toDesc {
    NSMutableDictionary *roomDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dic = [self getRoomJsonFromRoom:self.rtcRoom].mutableCopy;
    roomDic[@"data"] = dic;
    return roomDic;
}

- (NSMutableDictionary *)getRoomJsonFromRoom:(RCRTCRoom *)room {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // local user
    NSDictionary *ldic = [self getLocalUserJsonFromLocalUser:self.localUser];
    // remote user
    NSArray *arr = [self getRemoteStreamListFromRemoteUsers:self.remoteUsers];
    dic[@"id"] = room.roomId;
    dic[@"localUser"] = ldic;
    dic[@"remoteUserList"] = arr;
    return dic;
}

- (NSDictionary *)getLocalUserJsonFromLocalUser:(RCFlutterLocalUser *)localUser {
    NSDictionary *dic = [localUser toDesc];
    return dic;
}

- (NSArray *)getRemoteStreamListFromRemoteUsers:(NSArray<RCFlutterRemoteUser *> *)remoteUsers {
    NSMutableArray *arr = [NSMutableArray array];
    for (RCFlutterRemoteUser *ruser in remoteUsers) {
        NSDictionary *streamDic = [ruser toDesc];
        [arr addObject:streamDic];
    }
    return arr;;
}

- (NSArray<RCFlutterInputStream *> *)getFlutterRemoteInputStreamsFromRoom:(NSArray<NSDictionary *> *)dics{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in dics) {
        for (RCFlutterRemoteUser *remoteUser in self.remoteUsers) {
            for (RCFlutterInputStream *inputStream in remoteUser.remoteAVStreams) {
                if ([inputStream isEqualToStreamDic:dic]) {
                    [arr addObject:inputStream];
                }
            }
        }
    }
    return arr;
}

- (NSArray<RCRTCInputStream *> *)getRTCRemoteInputStreamsFromRoom:(NSArray<NSDictionary *> *)dics{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in dics) {
        for (RCFlutterRemoteUser *remoteUser in self.remoteUsers) {
            for (RCFlutterInputStream *inputStream in remoteUser.remoteAVStreams) {
                if ([inputStream isEqualToStreamDic:dic]) {
                    [arr addObject:inputStream.rtcInputStream];
                }
            }
        }
    }
    
    RCRTCRoom *room = [[RCRTCEngine sharedInstance] room];
    for (RCRTCInputStream *stream in [room getLiveStreams]) {
        for (NSDictionary *dic in dics) {
            if ([dic[@"streamId"] isEqual:[stream streamId]] && [dic[@"type"] intValue] == [stream mediaType]) {
                [arr addObject:stream];
            }
        }
    }
    return arr;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KSetRoomAttributeValue]) {
        [self setRoomAttributeValue:call result:result];
    } else if ([call.method isEqualToString:KDeleteRoomAttributes]) {
        [self deleteRoomAttributes:call result:result];
    } else if ([call.method isEqualToString:KGetRoomAttributes]) {
        [self getRoomAttributes:call result:result];
    } else if ([call.method isEqualToString:KSendMessage]) {
        [self sendMessage:call result:result];
    } else if ([call.method isEqualToString:KGetLiveStreams]) {
        [self getLiveStreams:call result:result];
    } else if ([call.method isEqualToString:KGetSessionId]) {
        [self getSessionId:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setRoomAttributeValue:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSString *key = dic[@"key"];
    NSString *value = dic[@"value"];
    NSString *object = dic[@"object"];
    NSString *content = dic[@"content"];
    RCMessageContent *message = [ThisClassShouldNotBelongHere string2MessageContent:object content:content];
    [_rtcRoom setRoomAttributeValue:value
                     forKey:key
                    message:message
                 completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)deleteRoomAttributes:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSArray *keys = [RCFlutterTools decodeToArray:dic[@"keys"]];
    NSString *object = dic[@"object"];
    NSString *content = dic[@"content"];
    RCMessageContent *message = [ThisClassShouldNotBelongHere string2MessageContent:object content:content];
    [_rtcRoom deleteRoomAttributes:keys
                   message:message
                completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)getRoomAttributes:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSArray *keys = [RCFlutterTools decodeToArray:dic[@"keys"]];
    [_rtcRoom getRoomAttributes:keys
             completion:^(BOOL isSuccess, RCRTCCode desc, NSDictionary * _Nullable attr) {
        result(attr);
    }];
}

- (void)sendMessage:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSString *object = dic[@"object"];
    NSString *content = dic[@"content"];
    RCMessageContent *message = [ThisClassShouldNotBelongHere string2MessageContent:object content:content];
    [_rtcRoom sendMessage:message
                  success:^(long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"id"];
        [dic setObject:[NSNumber numberWithInt:0] forKey:@"code"];
        result(dic);
    }
                    error:^(RCErrorCode nErrorCode, long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"id"];
        [dic setObject:[NSNumber numberWithInt:(int) nErrorCode] forKey:@"code"];
        result(dic);
    }];
}

- (void)getLiveStreams:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSMutableArray *arr = [NSMutableArray array];
    NSArray *streams = [self.rtcRoom getLiveStreams];
    for (RCRTCInputStream *inputStream in streams) {
        RCFlutterInputStream *stream = [[RCFlutterInputStream alloc] init];
        stream.rtcInputStream = inputStream;
        [stream registerStreamChannel];
        [arr addObject:[RCFlutterTools dictionaryToJson:[stream toDesc]]];
    }
    result(arr);
}

- (void)getSessionId:(FlutterResult)result {
    result(self.rtcRoom.sessionId);
}

@end
