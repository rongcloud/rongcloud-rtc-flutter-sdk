#import <objc/message.h>

#import "RCFlutterEngine.h"
#import "RLogUtil.h"
#import "RCFlutterRoom.h"
#import "RCFlutterRoom+Private.h"
#import "RCFlutterVideoCapture.h"
#import "RCFlutterAudioCapture.h"
#import "RCFlutterVideoCapture+Apis.h"
#import "RCFlutterAudioCapture+Apis.h"
#import "RCFlutterRenderViewFactory.h"
#import "RCFlutterTools.h"

#import "RCFlutterAVStream+Private.h"
#import "RCFlutterInputStream.h"
#import "RCFlutterInputStream+Private.h"


@interface RCFlutterEngine () <NSCopying>

/**
 rtc room
 */
@property (nonatomic, strong) RCFlutterRoom *room;

@end

@implementation RCFlutterEngine

#pragma mark - flutter 映射

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([KJoinRoom isEqualToString:call.method]) {
        [self joinRTCRoom:call result:result];
    } else if ([call.method isEqualToString:KLeaveRTCRoom]) {
        [self leaveRTCRoom:call result:result];
    } else if([call.method isEqualToString:KGetDefaultVideoStream]){
        [self getDefaultVideoStream:result];
    } else if([call.method isEqualToString:KGetDefaultAudioStream]){
        [self getDefaultAudioStream:result];
    } else if([call.method isEqualToString:KJoinLiveRoom]){
        [self joinRTCRoom:call result:result];
    } else if([call.method isEqualToString:KInit]){
        // not implement
    } else if([call.method isEqualToString:KEnableSpeaker]){
        BOOL enable = ((NSNumber *)(call.arguments)).boolValue;
        [self enableSpeaker:enable];
    } else if([call.method isEqualToString:KReleaseVideoView]){
        NSNumber *viewId = ((NSNumber *)(call.arguments));
        [self releaseVideoView:viewId];
    } else if([call.method isEqualToString:KSubscribeLiveStream]) {
        [self subscribeLiveStream:call result:result];
    } else if([call.method isEqualToString:KUnsubscribeLiveStream]) {
        [self unsubscribeLiveStream:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setPluginRegister:(NSObject<FlutterPluginRegistrar> *)pluginRegister {
    _pluginRegister = pluginRegister;
    
    RCFlutterRenderViewFactory *factory = [RCFlutterRenderViewFactory sharedViewFactory];
    [factory withMessenger:pluginRegister.messenger];
    [pluginRegister registerViewFactory:factory withId:RongFlutterRenderViewKey];
    
}

#pragma mark - instance
SingleInstanceM(Engine);
- (void)allocInstance {
    self.room = [[RCFlutterRoom alloc] init];
}
- (void)destroyCache {
    self.room = nil;
    [[RCFlutterRenderViewFactory sharedViewFactory] destroy];
}
#pragma mark - 调用原生

- (void)joinRTCRoom:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self allocInstance];
    NSString *roomId;
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeNormal;
    config.liveType = RCRTCLiveTypeAudioVideo;
    if ([call.arguments isKindOfClass:[NSString class]]) {
        roomId = call.arguments;
        [self joinNormalRoom:roomId result:result];
        
    } else if ([call.arguments isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)call.arguments;
        roomId = dic[@"roomId"];
        NSDictionary *roomConfig = dic[@"roomConfig"];
        config.roomType = ((NSNumber *)roomConfig[@"roomType"]).integerValue == 0 ? RCRTCRoomTypeNormal : RCRTCRoomTypeLive;
        config.liveType = ((NSNumber *)roomConfig[@"liveType"]).integerValue;
        [self joinLiveRoom:roomId roomConfig:config result:result];
    }
    
}

- (void)joinNormalRoom:(NSString *)roomId result:(FlutterResult)result{
    
    RLogV(@"ios joinRTCRoom id = %@", roomId);
    Weak(self);
    [[RCFlutterRTCManager sharedRTCManager] joinRTCRoom:roomId
                                             completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        RLogV(@"ios join room code:%@", @(code));
        Strong(self);
        
        if (code == RCRTCCodeSuccess) {
            selfStrong.room.rtcRoom = room;
            // 注册和房间无关的硬件资源
            //                [[RCFlutterVideoCapture sharedVideoCapture] registerVideo];
            NSMutableDictionary *roomDic = [selfStrong.room toDesc];
            roomDic[@"code"] = @(RCRTCCodeSuccess);
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:roomDic];
            RLogV(@"ios join room success");
            result(jsonObj);
        } else {
            result([NSDictionary new]);
        }
        
    }];
}

- (void)joinLiveRoom:(NSString *)roomId roomConfig:(RCRTCRoomConfig *)config result:(FlutterResult)result{
    
    RLogV(@"ios live joinRTCRoom id = %@", roomId);
    Weak(self);
    [[RCFlutterRTCManager sharedRTCManager] joinRTCRoom:roomId
                                                 config:config
                                             completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        RLogV(@"ios join room code:%@", @(code));
        Strong(self);
        
        if (code == RCRTCCodeSuccess) {
            selfStrong.room.rtcRoom = room;
            // 注册和房间无关的硬件资源
            //                [[RCFlutterVideoCapture sharedVideoCapture] registerVideo];
            NSMutableDictionary *roomDic = [selfStrong.room toDesc];
            roomDic[@"code"] = @(RCRTCCodeSuccess);
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:roomDic];
            RLogV(@"ios join room success");
            result(jsonObj);
        } else {
            result(@{@"code":@(-1)});
        }
        
    }];
}

- (void)leaveRTCRoom:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *roomId = call.arguments;
    RLogV(@"ios leave room id = %@", roomId);
    Weak(self);
    [[RCFlutterRTCManager sharedRTCManager] leaveRTCRoom:roomId?:self.room.roomId
                                              completion:^(BOOL isSuccess, RCRTCCode code) {
        RLogV(@"ios leave room code:%@", @(code));
        Strong(self);
        [selfStrong destroyCache];
        NSDictionary *resultDic = @{@"code":@(code)};
        NSString *jsonResult = [RCFlutterTools dictionaryToJson:resultDic];
        result(jsonResult);
    }];
}

- (void)enableSpeaker:(BOOL)enable {
    [[RCFlutterRTCManager sharedRTCManager] useSpeaker:enable];
}

- (RCFlutterVideoCapture *)defaultVideoStream {
    return [RCFlutterVideoCapture sharedVideoCapture];
}

- (RCFlutterAudioCapture *)defaultAudioStream {
    return [RCFlutterAudioCapture sharedAudioCapture];
}

- (void)releaseVideoView:(NSNumber *)viewId {
    [[RCFlutterRenderViewFactory sharedViewFactory] releaseVideoView:viewId.intValue];
}

- (void)getDefaultVideoStream:(FlutterResult)result{
    RCFlutterVideoCapture *video = self.defaultVideoStream;
    NSDictionary *desc = [video toDesc];
    NSString *jsonObj = [RCFlutterTools dictionaryToJson:desc];
    result(jsonObj);
}

- (void)getDefaultAudioStream:(FlutterResult)result{
    RCFlutterAudioCapture *audio = self.defaultAudioStream;
    NSDictionary *desc = [audio toDesc];
    NSString *jsonObj = [RCFlutterTools dictionaryToJson:desc];
    result(jsonObj);
}

- (void)subscribeLiveStream:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = (NSDictionary *)call.arguments;
    NSString *url = dic[@"url"];
    RCRTCAVStreamType type = [dic[@"type"] intValue];
    [[RCFlutterRTCManager sharedRTCManager] subscribeLiveStream:url streamType:type completion:^(RCRTCCode code, RCRTCInputStream * _Nullable inputStream) {
        if (code != RCRTCCodeSuccess) {
            NSMutableDictionary *desc = [NSMutableDictionary dictionary];
            [desc setObject:@"failed" forKey:@"callback"];
            [desc setObject:[NSNumber numberWithInt:(int)code] forKey:@"code"];
            [desc setObject:[RCRTCCodeDefine codeDesc:code] forKey:@"message"];
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:desc];
            result(jsonObj);
        }
        if ([inputStream mediaType] == RTCMediaTypeVideo) {
            NSMutableDictionary *desc = [NSMutableDictionary dictionary];
            [desc setObject:@"success" forKey:@"callback"];
            RCFlutterInputStream *stream = [[RCFlutterInputStream alloc] init];
            stream.rtcInputStream = inputStream;
            [stream registerStreamChannel];
            [desc setObject:[RCFlutterTools dictionaryToJson:[stream toDesc]] forKey:@"stream"];
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:desc];
            result(jsonObj);
        }
    }];
}

-(void) unsubscribeLiveStream:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *url = (NSString *)call.arguments;
    [[RCFlutterRTCManager sharedRTCManager] unsubscribeLiveStream:url completion:^(BOOL isSuccess, RCRTCCode code) {
        NSMutableDictionary *desc = [NSMutableDictionary dictionary];
        if (isSuccess) {
            [desc setObject:[NSNumber numberWithInt:0] forKey:@"code"];
        } else {
            [desc setObject:[NSNumber numberWithInt:(int)code] forKey:@"code"];
        }
        NSString *jsonObj = [RCFlutterTools dictionaryToJson:desc];
        result(jsonObj);
    }];
}

@end
