#import "RCFlutterRoom+RTCRoomProtocol.h"
#import "RCFlutterRemoteUser+Private.h"

#import "RCFlutterTools.h"

#import "RCFlutterInputStream+Private.h"
#import "RCFlutterAVStream+Private.h"

#import "RCFlutterUser+Private.h"

#import <RongIMLib/RongIMLib.h>

@interface RCFlutterMessageFactory : NSObject
+ (NSString *)message2String:(RCMessage *)message;
@end

@implementation RCFlutterRoom (RTCRoomProtocol)

- (void)didJoinUser:(RCRTCRemoteUser *)user {
    // {\"remoteUser\":{\"id\":\"15699998823_873B_ios\",\"streamList\":[]}}
    RCFlutterRemoteUser *remoteUser = [[RCFlutterRemoteUser alloc] init];
    remoteUser.rtcUser = user;
    [self addRemoteUser:remoteUser];
    NSDictionary *dic = [remoteUser toDesc];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    [userDic setValue:dic forKey:@"remoteUser"];
    NSString *json = [RCFlutterTools dictionaryToJson:userDic];
    [self.methodChannel invokeMethod:KOnUserJoin arguments:json];
}

- (void)didOfflineUser:(RCRTCRemoteUser *)user {
    RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:user.userId];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *userDic = [remoteUser toDesc];
    [dic setValue:userDic forKey:@"remoteUser"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    [self.methodChannel invokeMethod:KOnUserOffline arguments:json];
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
        self.rtcRoom = [RCRTCEngine sharedInstance].room;
        NSString *userId = @"";
        // 增量
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCRTCInputStream *stream in streams) {
            RCFlutterInputStream *inputStream = [[RCFlutterInputStream alloc] init];
            inputStream.rtcInputStream = stream;
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
            userId = stream.userId;
            RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:userId];
            [remoteUser addStream:inputStream];
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
        self.rtcRoom = [RCRTCEngine sharedInstance].room;
        NSString *userId = @"";
        // 增量
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCRTCInputStream *stream in streams) {
            RCFlutterInputStream *inputStream = [[RCFlutterInputStream alloc] init];
            inputStream.rtcInputStream = stream;
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
            userId = stream.userId;
            RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:userId];
            [remoteUser removeStream:inputStream];
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

- (void)stream:(RCRTCInputStream *)stream didAudioMute:(BOOL)mute {
    NSString *userId = stream.userId;
    NSString *streamId = stream.streamId;
    RTCMediaType mediaType = stream.mediaType;
    RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:userId];
    RCFlutterInputStream *remoteStream = nil;
    for (RCFlutterInputStream *stream in remoteUser.remoteAVStreams) {
        if ([stream.rtcInputStream.streamId isEqualToString:streamId] && stream.rtcInputStream.mediaType == mediaType) {
            remoteStream = stream;
            break;
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[remoteUser toDesc] forKey:@"remoteUser"];
    [dic setValue:[remoteStream toDesc] forKey:@"inputStream"];
    [dic setValue:@(mute) forKey:@"mute"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    [self.methodChannel invokeMethod:KOnRemoteUserMuteAudio arguments:json];
}

- (void)stream:(RCRTCInputStream *)stream didVideoEnable:(BOOL)enable {
    NSString *userId = stream.userId;
    NSString *streamId = stream.streamId;
    RTCMediaType mediaType = stream.mediaType;
    RCFlutterRemoteUser *remoteUser = [self getRemoteUserFromUserId:userId];
    RCFlutterInputStream *remoteStream = nil;
    for (RCFlutterInputStream *stream in remoteUser.remoteAVStreams) {
        if ([stream.rtcInputStream.streamId isEqualToString:streamId] && stream.rtcInputStream.mediaType == mediaType) {
            remoteStream = stream;
            break;
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[remoteUser toDesc] forKey:@"remoteUser"];
    [dic setValue:[remoteStream toDesc] forKey:@"inputStream"];
    BOOL mute = !enable;
    [dic setValue:@(mute) forKey:@"mute"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    [self.methodChannel invokeMethod:KOnRemoteUserMuteVideo arguments:json];
}

-(void)didPublishLiveStreams:(NSArray<RCRTCInputStream *> *)streams {
    dispatch_to_workQueue(^{
        self.rtcRoom = [RCRTCEngine sharedInstance].room;
        // 增量
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCRTCInputStream *stream in streams) {
            RCFlutterInputStream *inputStream = [[RCFlutterInputStream alloc] init];
            inputStream.rtcInputStream = stream;
            [inputStream registerStreamChannel];
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
        }
        NSMutableDictionary *allDic = [NSMutableDictionary dictionary];
        [allDic setValue:streamList forKey:@"streamList"];
        NSString *json = [RCFlutterTools dictionaryToJson:allDic];
        [self.methodChannel invokeMethod:kOnRemoteUserPublishLiveStream arguments:json];
    });
}

-(void)didUnpublishLiveStreams:(NSArray<RCRTCInputStream *> *)streams {
    dispatch_to_workQueue(^{
        self.rtcRoom = [RCRTCEngine sharedInstance].room;
        // 增量
        NSMutableArray *streamList = [NSMutableArray array];
        for (RCRTCInputStream *stream in streams) {
            RCFlutterInputStream *inputStream = [[RCFlutterInputStream alloc] init];
            inputStream.rtcInputStream = stream;
            NSDictionary *dic = [inputStream toDesc];
            [streamList addObject:dic];
        }
        
        NSMutableDictionary *allDic = [NSMutableDictionary dictionary];
        [allDic setValue:streamList forKey:@"streamList"];
        NSString *json = [RCFlutterTools dictionaryToJson:allDic];
        [self.methodChannel invokeMethod:KOnRemoteUserUnPublishLiveStream arguments:json];
    });
}

- (void)didReceiveMessage:(RCMessage *)message {
    NSString *msg = [RCFlutterMessageFactory message2String:message];
    [self.methodChannel invokeMethod:KOnReceiveMessage arguments:msg];
}

@end
