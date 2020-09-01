#import "RCFlutterRoom.h"
#import "RCFlutterLocalUser+Apis.h"
#import "RCFlutterRemoteUser+Private.h"
#import "RCFlutterEngine.h"
#import "RCFlutterRoom+Private.h"
#import "RCFlutterInputStream.h"
#import "RCFlutterInputStream+Private.h"
#import "RCFlutterAVStream+Private.h"
#import "RCFlutterUser+Private.h"
@interface RCFlutterRoom ()

@property(nonatomic, strong) RCRTCRoom *rtcRoom;
@property(nonatomic, copy) NSString *roomId;
@property(nonatomic, strong) RCFlutterLocalUser *localUser;
@property(nonatomic, strong,) NSArray<RCFlutterRemoteUser *> *remoteUsers;
@property(nonatomic, strong) FlutterMethodChannel *methodChannel;
@end

@implementation RCFlutterRoom

- (instancetype)init {
    if (self = [super init]) {
        self.localUser = [[RCFlutterLocalUser alloc] init];
        self.remoteUsers = [NSMutableArray array];
    }
    return self;;
}

- (void)registerRoomChannel {
    NSString *channelId = [NSString stringWithFormat:@"%@%@",KRoom,self.rtcRoom.roomId];
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:channelId binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    self.methodChannel = channel;
}

- (void)dealloc {
    RCLogI(@"RCFlutterRoom dealloc");
    self.localUser = nil;
    self.remoteUsers = nil;
    self.rtcRoom = nil;
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
    roomDic[@"room"] = dic;
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

- (NSArray<RCFlutterInputStream *> *)getFlutterRemoteInputStreamsFromRoom:(NSArray<NSDictionary *> *)streamDics{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streamDics) {
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
- (NSArray<RCRTCInputStream *> *)getRTCRemoteInputStreamsFromRoom:(NSArray<NSDictionary *> *)streamics{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streamics) {
        for (RCFlutterRemoteUser *remoteUser in self.remoteUsers) {
            for (RCFlutterInputStream *inputStream in remoteUser.remoteAVStreams) {
                if ([inputStream isEqualToStreamDic:dic]) {
                    [arr addObject:inputStream.rtcInputStream];
                }
            }
        }
    }
    return arr;
}
@end
