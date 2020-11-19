#import "RCFlutterRoom+RTCRoomProtocol.h"
#import "RCFlutterRemoteUser+Private.h"

#import "RCFlutterTools.h"

#import "RCFlutterInputStream+Private.h"
#import "RCFlutterAVStream+Private.h"

#import "RCFlutterUser+Private.h"
@implementation RCFlutterRoom (RTCRoomProtocol)

- (void)didJoinUser:(RCRTCRemoteUser *)user {
    // {\"remoteUser\":{\"id\":\"15699998823_873B_ios\",\"streamList\":[]}}
    RCFlutterRemoteUser *remoteUser = [[RCFlutterRemoteUser alloc] init];
    remoteUser.rtcUser = user;
    NSDictionary *dic = [remoteUser toDesc];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    [userDic setValue:dic forKey:@"remoteUser"];
    NSString *json = [RCFlutterTools dictionaryToJson:userDic];
    [self.methodChannel invokeMethod:KOnUserJoin arguments:json];
}

- (void)didLeaveUser:(RCRTCRemoteUser *)user {
    RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:user.userId];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *userDic = [remoteUser toDesc];
    [dic setValue:userDic forKey:@"remoteUser"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    [self.methodChannel invokeMethod:KOnUserLeft arguments:json];
}

- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    dispatch_to_workQueue(^{
        self.rtcRoom = [RCRTCEngine sharedInstance].currentRoom;
        NSString *userId = @"";
        // 增量
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCRTCInputStream *stream in streams) {
            RCFlutterInputStream *inputStream = [[RCFlutterInputStream alloc] init];
            inputStream.rtcInputStream = stream;
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
            userId = stream.userId;
        }
        // 全量
        RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:userId];
        NSDictionary *remoteUserDic = [remoteUser toDesc];
        
        NSMutableDictionary *allDic = [NSMutableDictionary dictionary];
        [allDic setValue:remoteUserDic forKey:@"remoteUser"];
        [allDic setValue:streamList forKey:@"streamList"];
        NSString *json = [RCFlutterTools dictionaryToJson:allDic];
        [self.methodChannel invokeMethod:kOnRemoteUserPublishStream arguments:json];
    });
}

- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    dispatch_to_workQueue(^{
        self.rtcRoom = [RCRTCEngine sharedInstance].currentRoom;
        NSString *userId = @"";
        // 增量
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCRTCInputStream *stream in streams) {
            RCFlutterInputStream *inputStream = [[RCFlutterInputStream alloc] init];
            inputStream.rtcInputStream = stream;
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
            userId = stream.userId;
        }
        // 全量
        RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:userId];
        NSDictionary *remoteUserDic = [remoteUser toDesc];
        
        NSMutableDictionary *allDic = [NSMutableDictionary dictionary];
        [allDic setValue:remoteUserDic forKey:@"remoteUser"];
        [allDic setValue:streamList forKey:@"streamList"];
        NSString *json = [RCFlutterTools dictionaryToJson:allDic];
        [self.methodChannel invokeMethod:KOnRemoteUserUnPublishStream arguments:json];
    });
}
@end
