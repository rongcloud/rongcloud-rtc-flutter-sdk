#import <objc/message.h>

#import "RCFlutterEngine.h"
#import "RLogUtil.h"
#import "RCFlutterRoom.h"
#import "RCFlutterRoom+Private.h"
#import "RCFlutterVideoCapture.h"
#import "RCFlutterAudioCapture.h"
#import "RCFlutterVideoCapture+Apis.h"
#import "RCFlutterAudioCapture+Apis.h"
#import "RCFlutterTextureViewFactory.h"
#import "RCFlutterTools.h"

#import "RCFlutterAVStream+Private.h"
#import "RCFlutterInputStream.h"
#import "RCFlutterInputStream+Private.h"

#import "RCFlutterAudioEffectManager+Private.h"
#import "RCFlutterAudioMixer.h"

@interface RCFlutterEngine () <NSCopying, RCRTCStatusReportDelegate>

/**
 rtc room
 */
@property (nonatomic, strong) RCFlutterRoom *room;

@property (nonatomic, strong) NSMutableDictionary *createdOutputStreams;

@end

@implementation RCFlutterEngine

#pragma mark - flutter 映射

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KInit]) {
        result(nil);
    } else if ([call.method isEqualToString:KUnInit]) {
        result(nil);
    } else if ([call.method isEqualToString:KJoinRoom]) {
        [self joinRTCRoom:call result:result];
    } else if ([call.method isEqualToString:KLeaveRTCRoom]) {
        [self leaveRTCRoom:call result:result];
    } else if ([call.method isEqualToString:KGetDefaultVideoStream]) {
        [self getDefaultVideoStream:result];
    } else if ([call.method isEqualToString:KGetDefaultAudioStream]) {
        [self getDefaultAudioStream:result];
    } else if ([call.method isEqualToString:KSubscribeLiveStream]) {
        [self subscribeLiveStream:call result:result];
    } else if ([call.method isEqualToString:KUnsubscribeLiveStream]) {
        [self unsubscribeLiveStream:call result:result];
    } else if ([call.method isEqualToString:KSetMediaServerUrl]) {
        [self setMediaServerUrl:call result:result];
    } else if ([call.method isEqualToString:KEnableSpeaker]) {
        BOOL enable = ((NSNumber *)(call.arguments)).boolValue;
        [self enableSpeaker:enable];
    } else if ([call.method isEqualToString:KRegisterStatusReportListener]) {
        [self registerStatusReportListener:result];
    } else if ([call.method isEqualToString:KUnRegisterStatusReportListener]) {
        [self unRegisterStatusReportListener:result];
    } else if ([call.method isEqualToString:KCreateVideoOutputStream]) {
        [self createVideoOutputStream:call result:result];
    } else if ([call.method isEqualToString:KCreateVideoTextureView]) {
        [self createVideoTextureView:call result:result];
    } else if ([call.method isEqualToString:KReleaseVideoTextureView]) {
        [self releaseVideoTextureView:call result:result];
    } else if ([call.method isEqualToString:KGetAudioEffectManager]) {
        [self getAudioEffectManager:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setPluginRegister:(NSObject<FlutterPluginRegistrar> *)pluginRegister {
    _pluginRegister = pluginRegister;
    
    [[RCFlutterTextureViewFactory sharedViewFactory] withTextureRegistry:pluginRegister.textures messenger:pluginRegister.messenger];
    [RCFlutterAudioMixer sharedAudioMixer];
}

#pragma mark - instance
SingleInstanceM(Engine);

- (void)allocInstance {
    self.room = [[RCFlutterRoom alloc] init];
    self.createdOutputStreams = [[NSMutableDictionary alloc] init];
}

- (void)destroyCache {
    self.room = nil;
    [self.createdOutputStreams removeAllObjects];
    self.createdOutputStreams = nil;
    [[RCFlutterAudioEffectManager sharedAudioEffectManager] destroy];
    [[RCFlutterTextureViewFactory sharedViewFactory] destroy];
}

#pragma mark - 调用原生

- (void)joinRTCRoom:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self allocInstance];
    NSDictionary *dic = (NSDictionary *)call.arguments;
    NSString *roomId = dic[@"roomId"];
    NSDictionary *roomConfig = dic[@"roomConfig"];
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = ((NSNumber *)roomConfig[@"roomType"]).integerValue == 0 ? RCRTCRoomTypeNormal : RCRTCRoomTypeLive;
    config.liveType = ((NSNumber *)roomConfig[@"liveType"]).integerValue;
    
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
            NSMutableDictionary *dic = [selfStrong.room toDesc];
            dic[@"code"] = @(RCRTCCodeSuccess);
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:dic];
            RLogV(@"ios join room success");
            result(jsonObj);
        } else {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            dic[@"code"] = @((int) code);
            dic[@"data"] = @"ios join room error";
            NSString *json = [RCFlutterTools dictionaryToJson:dic];
            RLogV(@"ios join room error");
            result(json);
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

- (RCFlutterAudioEffectManager *)audioEffectManager {
    return [RCFlutterAudioEffectManager sharedAudioEffectManager];
}

- (void)createVideoTextureView:(FlutterMethodCall *)call result:(FlutterResult)result {
    RCFlutterTextureView *view = [[RCFlutterTextureViewFactory sharedViewFactory] createTextureView];
    NSDictionary *resultDic = @{@"textureId":@(view.textureId)};
    NSString *jsonResult = [RCFlutterTools dictionaryToJson:resultDic];
    result(jsonResult);
}

- (void)releaseVideoTextureView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = (NSDictionary *)call.arguments;
    NSNumber *textureId = dic[@"textureId"];
    [[RCFlutterTextureViewFactory sharedViewFactory] remove:textureId.integerValue];
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

- (void)createVideoOutputStream:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *tag = call.arguments;
    RCRTCCameraOutputStream *stream = [[RCRTCCameraOutputStream alloc] initVideoOutputStreamWithTag:tag];
    RCFlutterVideoOutputStream *output = [[RCFlutterVideoOutputStream alloc] init];
    [output registerStream:stream];
    [output registerStreamChannel];
    NSDictionary *desc = [output toDesc];
    NSString *jsonObj = [RCFlutterTools dictionaryToJson:desc];
    [_createdOutputStreams setObject:output
                              forKey:[NSString stringWithFormat:@"%@_%d_%@", output.streamId, (int) output.streamType, tag]];
    result(jsonObj);
}

- (void)getAudioEffectManager:(FlutterResult)result{
    RCFlutterAudioEffectManager *manager = self.audioEffectManager;
    NSDictionary *dic = [manager toDic];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)subscribeLiveStream:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = (NSDictionary *)call.arguments;
    NSString *url = dic[@"url"];
    RCRTCAVStreamType type = [dic[@"type"] intValue];
    [[RCFlutterRTCManager sharedRTCManager] subscribeLiveStream:url streamType:type completion:^(RCRTCCode code, RCRTCInputStream * _Nullable inputStream) {
        if (code == RCRTCCodeSuccess) {
            [_channel invokeMethod:@"onSuccess" arguments:nil];
        } else {
            NSMutableDictionary *desc = [NSMutableDictionary dictionary];
            [desc setObject:[NSNumber numberWithInt:(int)code] forKey:@"code"];
            [desc setObject:[RCRTCCodeDefine codeDesc:code] forKey:@"message"];
            NSString *json = [RCFlutterTools dictionaryToJson:desc];
            [_channel invokeMethod:@"onFailed" arguments:json];
        }
        
        if ([inputStream mediaType] == RTCMediaTypeAudio) {
            RCFlutterInputStream *stream = [[RCFlutterInputStream alloc] init];
            stream.rtcInputStream = inputStream;
            [stream registerStreamChannel];
            NSString *json = [RCFlutterTools dictionaryToJson:[stream toDesc]];
            [_channel invokeMethod:@"onAudioStreamReceived" arguments:json];
        } else if ([inputStream mediaType] == RTCMediaTypeVideo) {
            RCFlutterInputStream *stream = [[RCFlutterInputStream alloc] init];
            stream.rtcInputStream = inputStream;
            [stream registerStreamChannel];
            NSString *json = [RCFlutterTools dictionaryToJson:[stream toDesc]];
            [_channel invokeMethod:@"onVideoStreamReceived" arguments:json];
        }
    }];
}

- (void)unsubscribeLiveStream:(FlutterMethodCall *)call result:(FlutterResult)result {
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

- (void)setMediaServerUrl:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *url = (NSString *)call.arguments;
    [[RCRTCEngine sharedInstance] setMediaServerUrl:url];
    result(nil);
}

- (void)registerStatusReportListener:(FlutterResult)result {
    [RCRTCEngine sharedInstance].statusReportDelegate = self;
    result(nil);
}

- (void)unRegisterStatusReportListener:(FlutterResult)result {
    [RCRTCEngine sharedInstance].statusReportDelegate = self;
    result(nil);
}

- (void)didReportStatusForm:(RCRTCStatusForm*)form {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *vss = [NSMutableDictionary dictionary];
    NSMutableDictionary *ass = [NSMutableDictionary dictionary];
    for (RCRTCStreamStat *stat in form.sendStats) {
        NSDictionary *avs = [self toDic:stat];
        NSString *newTrackId = [self _convertFormartWithStr:stat.trackId];
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
            [vss setObject:avs forKey:newTrackId];
        } else {
            [ass setObject:avs forKey:newTrackId];
        }
    }
    
    NSMutableDictionary *vrs = [NSMutableDictionary dictionary];
    NSMutableDictionary *ars = [NSMutableDictionary dictionary];
    for (RCRTCStreamStat *stat in form.recvStats) {
        NSDictionary *avs = [self toDic:stat];
        NSString *newTrackId = [self _convertFormartWithStr:stat.trackId];
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
            [vrs setObject:avs forKey:newTrackId];
        } else {
            [ars setObject:avs forKey:newTrackId];
        }
    }
    
    [dic setObject:vss forKey:@"statusVideoSends"];
    [dic setObject:ass forKey:@"statusAudioSends"];
    [dic setObject:vrs forKey:@"statusVideoRcvs"];
    [dic setObject:ars forKey:@"statusAudioRcvs"];
    
    [dic setObject:@(form.totalSendBitRate) forKey:@"bitRateSend"];
    [dic setObject:@(form.totalRecvBitRate) forKey:@"bitRateRcv"];
    
    [dic setObject:@(form.rtt) forKey:@"rtt"];
    
    [dic setObject:form.networkType.length ? form.networkType : @"Unknown" forKey:@"networkType"];
    NSString *ipAddress = form.ipAddress != nil ? form.ipAddress : @"Unknown";
    [dic setObject:ipAddress forKey:@"ipAddress"];
    [dic setObject:@(form.availableReceiveBandwidth) forKey:@"googAvailableReceiveBandwidth"];
    [dic setObject:@(form.availableSendBandwidth) forKey:@"googAvailableSendBandwidth"];
    [dic setObject:@(form.packetsDiscardedOnSend) forKey:@"packetsDiscardedOnSend"];
    
    [_channel invokeMethod:@"onConnectionStats" arguments:[RCFlutterTools dictionaryToJson:dic]];
}
    
- (NSString *)_convertFormartWithStr:(NSString *)string {
    NSError *error = nil;
    string = [string replacingWithPattern:@"_tiny$"
                             withTemplate:@""
                                    error:&error];
    string = [string replacingWithPattern:@"_audio$"
                             withTemplate:@""
                                    error:&error];
    string = [string replacingWithPattern:@"_video$"
                             withTemplate:@""
                                    error:&error];
    return string;
}

- (NSDictionary *)toDic:(RCRTCStreamStat *)stat {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:stat.trackId forKey:@"id"];
    NSString *uid = [RCRTCStatusForm fetchUserIdFromTrackId:stat.trackId];
    [dic setObject:uid != nil ? uid : @"Unknown" forKey:@"uid"];
    [dic setObject:stat.codecName forKey:@"codecName"];
    [dic setObject:stat.mediaType forKey:@"mediaType"];
    [dic setObject:@(stat.packetLoss) forKey:@"packetLostRate"];
//    [dic setObject:@"Unknown" forKey:@"isSend"];
    [dic setObject:@(stat.frameWidth) forKey:@"frameWidth"];
    [dic setObject:@(stat.frameHeight) forKey:@"frameHeight"];
    [dic setObject:@(stat.frameRate) forKey:@"frameRate"];
    [dic setObject:@(stat.bitRate) forKey:@"bitRate"];
    [dic setObject:@(stat.rtt) forKey:@"rtt"];
    [dic setObject:@(stat.jitterReceived) forKey:@"googJitterReceived"];
//    [dic setObject:@"Unknown" forKey:@"googFirsReceived"];
    [dic setObject:@(stat.renderDelayMs) forKey:@"googRenderDelayMs"];
    [dic setObject:@(stat.audioLevel) forKey:@"audioOutputLevel"];
    NSString *codecImplementationName = stat.codecImplementationName != nil ? stat.codecImplementationName : @"Unknown";
    [dic setObject:codecImplementationName forKey:@"codecImplementationName"];
    [dic setObject:@(stat.googNacksReceived) forKey:@"googNacksReceived"];
//    [dic setObject:@"Unknown" forKey:@"googPlisReceived"];
    return dic;
}

@end
