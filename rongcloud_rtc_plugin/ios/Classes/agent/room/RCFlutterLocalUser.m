#import "RCFlutterLocalUser.h"

#import "RCFlutterOutputStream+Private.h"

#import "RCFlutterUser+Private.h"
#import "RCFlutterLocalUser+Apis.h"

#import "RCFlutterVideoCapture.h"
#import "RCFlutterAudioCapture.h"
#import "RCFlutterAVStream+Private.h"

#import "RCFlutterRTCManager.h"

#import "RCFlutterEngine.h"
#import "RCFlutterEngine+Private.h"

#import "RCFlutterAVStream+Private.h"
#import "RCFlutterInputStream.h"
#import "RCFlutterInputStream+Private.h"

#import "RCFlutterRoom.h"
#import "RCFlutterRoom+Private.h"

#import "RCFlutterRemoteUser.h"
#import "RCFlutterRemoteUser+Private.h"

#import "RCFlutterTools.h"
#import "RCFlutterVideoCapture.h"
#import "RCFlutterAudioCapture.h"
@interface RCFlutterLocalUser ()

@property(nonatomic, copy) NSArray<RCFlutterOutputStream *> *localAVStreams;

/**
 video capture
 */
@property(nonatomic, strong) RCFlutterVideoCapture *videoCapture;

/**
 audio capture
 */
@property(nonatomic, strong) RCFlutterAudioCapture *audioCapture;

@end

@implementation RCFlutterLocalUser

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KPublishDefaultStreams]) {
        [self publishRTCDefaultAVStream:^(BOOL isSuccess, RCRTCCode desc) {
            result(@(desc));
        }];
    } else if ([call.method isEqualToString:KPublishStreams]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *json in (NSArray *)call.arguments) {
            NSDictionary *dic = [RCFlutterTools decodeToDic:json];
            [arr addObject:dic];
        }
        [self publishStream:arr result:result];
        
    } else if ([call.method isEqualToString:KUnpublishStreams]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *json in (NSArray *)call.arguments) {
            NSDictionary *dic = [RCFlutterTools decodeToDic:json];
            [arr addObject:dic];
        }
        [self unpublishStream:arr result:result];
        
    } else if ([call.method isEqualToString:KSubscribeStream]) {
        NSArray
        *streams = [RCFlutterTools decodeToArray:call.arguments];
        [self subscribeStreams:streams result:result];
    } else if ([call.method isEqualToString:KUnPublishDefaultStreams]) {
        [self unpublishDefaultStream:^(BOOL isSuccess, RCRTCCode desc) {
            result(@(desc));
        }];
    } else if ([call.method isEqualToString:KUnSubscribeStream]) {
        NSArray
        *streams = [RCFlutterTools decodeToArray:call.arguments];
        [self unsubscribeStreams:streams result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}
- (void)setRtcUser:(RCRTCUser *)rtcUser {
    [super setRtcUser:rtcUser];
    [self registerChannel];
    NSMutableArray *arr = [NSMutableArray array];
    for (RCRTCOutputStream *outputStream in ((RCRTCLocalUser *)rtcUser).localStreams) {
        RCFlutterOutputStream *rfstm = [[RCFlutterOutputStream alloc] init];
        // 将本地资源摄像头和麦克风分别映射
        if ([outputStream isMemberOfClass:[RCRTCCameraOutputStream class]]) {
            // 映射摄像头资源
            rfstm = [self mapVideoCapture:outputStream];
        } else if ([outputStream isMemberOfClass:[RCRTCMicOutputStream class]]) {
            // 映射麦克风资源
            rfstm = [self mapAudioCapture:outputStream];
        } else {
            // 其他，如文件等
            rfstm.rtcOutputStream = outputStream;
            [rfstm registerStreamChannel];
        }
        [arr addObject:rfstm];
    }
    self.localAVStreams = arr;
    // 如果本地没有发布资源也有可能启动麦克风或者摄像头
    // 此处可掉可不掉
    if (!self.videoCapture && !self.audioCapture) {
        [self privateStartVideoAndAudioCapture];
    }
    
}

- (RCFlutterOutputStream *)mapVideoCapture:(RCRTCOutputStream *)outputStream {
    self.videoCapture = [RCFlutterVideoCapture sharedVideoCapture];
    [self.videoCapture setRtcOutputStream:outputStream];
    [self.videoCapture registerStreamChannel];
    return self.videoCapture;
}

- (RCFlutterOutputStream *)mapAudioCapture:(RCRTCOutputStream *)outputStream {
    self.audioCapture = [RCFlutterAudioCapture sharedAudioCapture];
    [self.audioCapture setRtcOutputStream:outputStream];
    [self.audioCapture registerStreamChannel];
    return self.audioCapture;
}

// 内部初始化摄像头和麦克风
- (void)privateStartVideoAndAudioCapture {
    // 内部初始化音视频资源，可以不用
    self.videoCapture = [RCFlutterVideoCapture sharedVideoCapture];
    [self.videoCapture registerStream:self.videoCapture.rtcOutputStream];
    [self.videoCapture registerStreamChannel];
    
    self.audioCapture = [RCFlutterAudioCapture sharedAudioCapture];
    [self.audioCapture registerStream:self.audioCapture.rtcOutputStream];
    [self.audioCapture registerStreamChannel];
    // 默认挂音视频流
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:self.videoCapture];
    [arr addObject:self.audioCapture];
    self.localAVStreams = arr.copy;
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.userId forKey:@"id"];
    // local streams
    NSMutableArray *streams = [NSMutableArray array];
    for (RCFlutterOutputStream *stream in self.localAVStreams) {
        NSDictionary *_dic = [stream toDesc];
        [streams addObject:_dic];
    }
    [dic setObject:streams forKey:@"streams"];
    return dic;;
}

- (void)publishStream:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray *arr = [self getPublishRTCStreamsFromEngineWithArr:streams];
    for (RCRTCOutputStream *stream in arr) {
        [self publishStream:stream completion:^(BOOL isSuccess, RCRTCCode desc) {
            result(@(desc));
        }];
    }
}

- (void)unpublishStream:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray *arr = [self getUnPublishStreamsFromLocalUserWithArr:streams];
    for (RCRTCOutputStream *stream in arr) {
        [self unpublishStream:stream completion:^(BOOL isSuccess, RCRTCCode desc) {
            result(@(desc));
        }];
    }
}
- (void)subscribeStreams:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray<RCRTCInputStream *> *inputStreams = [self getAllStreamsWithArr:streams];
    [self subscribeStreams:nil tinyStreams:inputStreams completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}
- (void)unsubscribeStreams:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray<RCRTCInputStream *> *inputStreams = [self getAllStreamsWithArr:streams];
    [self unsubscribeStream:inputStreams completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
        
    }];
}
- (void)dealloc {
    RCLogI(@"RCFlutterLocalUser dealloc");
    self.rtcUser = nil;
    self.localAVStreams = nil;
    self.videoCapture = nil;
    self.audioCapture = nil;
}
- (NSArray<RCRTCOutputStream *> *)getUnPublishStreamsFromLocalUserWithArr:(NSArray<NSDictionary *> *)streams {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streams) {
        NSArray *streams = [RCRTCEngine sharedInstance].currentRoom.localUser.localStreams;
        for (RCRTCOutputStream *output in streams) {
            if ([self stream:output isEqualToStreamDic:dic]) {
                [arr addObject:output];
            }
        }
    }
    return arr;
}
- (NSArray<RCRTCOutputStream *> *)getPublishRTCStreamsFromEngineWithArr:(NSArray<NSDictionary *> *)streams {
    NSMutableArray *ori = [NSMutableArray array];
    [ori addObject:[RCRTCEngine sharedInstance].defaultVideoStream];
    [ori addObject:[RCRTCEngine sharedInstance].defaultAudioStream];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streams) {
        for (RCRTCStream *output in ori) {
            if ([self stream:output isEqualToStreamDic:dic]) {
                [arr addObject:output];
            }
        }
    }
    return arr;
}
- (BOOL)stream:(RCRTCStream *)output isEqualToStreamDic:(NSDictionary *)dic{
    NSString *streamid = dic[@"streamId"];
    NSNumber *type = dic[@"type"];
    NSString *tag = dic[@"tag"];
    if ([output.streamId isEqualToString:streamid] && [output.tag isEqualToString:tag] && output.mediaType == type.integerValue) {
        return YES;
    }
    return NO;
}
- (NSArray<RCRTCInputStream *> *)getAllStreamsWithArr:(NSArray<NSDictionary *> *)streams {
    NSArray *arr = [[RCFlutterEngine sharedEngine].room getRTCRemoteInputStreamsFromRoom:streams];
    return arr;
}
- (NSArray<RCRTCInputStream *> *)getRemoteStreamsWithArr:(NSArray<NSDictionary *> *)streams {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in streams) {
        NSString *userId = dic[@"userId"];
        RCFlutterRemoteUser *remoteUser = [[RCFlutterEngine sharedEngine].room getRemoteUserFromUserId:userId];
        NSArray *inputStreams = [remoteUser getRTCRemoteInputStreamsFromRemoteUser:@[dic]];
        [arr addObjectsFromArray:inputStreams];
    }
    return arr;
}
@end
