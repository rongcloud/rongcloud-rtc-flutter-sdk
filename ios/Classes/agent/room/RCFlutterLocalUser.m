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

#import "RCFlutterLiveInfo.h"

#import "RCFlutterRoom.h"
#import "RCFlutterRoom+Private.h"

#import "RCFlutterRemoteUser.h"
#import "RCFlutterRemoteUser+Private.h"

#import "RCFlutterTools.h"
#import "RCFlutterVideoCapture.h"
#import "RCFlutterAudioCapture.h"

#import "ThisClassShouldNotBelongHere.h"

@implementation RCFlutterLocalUser

- (void)dealloc {
    RCLogI(@"RCFlutterLocalUser dealloc");
    self.rtcUser = nil;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KGetStreams]) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCRTCOutputStream *outputStream in ((RCRTCLocalUser *)self.rtcUser).localStreams) {
            RCFlutterOutputStream *stream = nil;
            if ([outputStream isMemberOfClass:[RCRTCCameraOutputStream class]]) {
                stream = [RCFlutterVideoCapture sharedVideoCapture];
            } else if ([outputStream isMemberOfClass:[RCRTCMicOutputStream class]]) {
                stream = [RCFlutterAudioCapture sharedAudioCapture];
            } else {
                continue;
            }
            [array addObject:[RCFlutterTools dictionaryToJson:[stream toDesc]]];
        }
        result(array);
    } else if ([call.method isEqualToString:KPublishDefaultLiveStreams]) {
        [self publishRTCDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (isSuccess) {
                RCFlutterLiveInfo *info = [RCFlutterLiveInfo flutterLiveInfoWithLiveInfo:liveInfo roomId:[[[RCRTCEngine sharedInstance] currentRoom] roomId] userId:self.userId];
                [dic setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dic setObject:[RCFlutterTools dictionaryToJson:[info toDesc]] forKey:@"content"];
            } else {
                [dic setObject:[NSNumber numberWithInt:(int)desc] forKey:@"code"];
                [dic setObject:[RCRTCCodeDefine codeDesc:desc] forKey:@"content"];
            }
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:dic];
            result(jsonObj);
        }];
    } else if ([call.method isEqualToString:KPublishLiveStream]) {
        NSString *json = call.arguments;
        RCRTCOutputStream *stream = [self getOutputStreamFromJSON:json];
        [self publishRTCLiveStream:stream
                        completion:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (isSuccess) {
                RCFlutterLiveInfo *info = [RCFlutterLiveInfo flutterLiveInfoWithLiveInfo:liveInfo roomId:[[[RCRTCEngine sharedInstance] currentRoom] roomId] userId:self.userId];
                [dic setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dic setObject:[RCFlutterTools dictionaryToJson:[info toDesc]] forKey:@"content"];
            } else {
                [dic setObject:[NSNumber numberWithInt:(int)desc] forKey:@"code"];
                [dic setObject:[RCRTCCodeDefine codeDesc:desc] forKey:@"content"];
            }
            NSString *jsonObj = [RCFlutterTools dictionaryToJson:dic];
            result(jsonObj);
        }];
    } else if ([call.method isEqualToString:KPublishDefaultStreams]) {
        [self publishRTCDefaultAVStreams:^(BOOL isSuccess, RCRTCCode desc) {
            result(@(desc));
        }];
    } else if ([call.method isEqualToString:KUnPublishDefaultStreams]) {
        [self unpublishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
            result(@(desc));
        }];
    } else if ([call.method isEqualToString:KPublishStreams]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *json in (NSArray *)call.arguments) {
            NSDictionary *dic = [RCFlutterTools decodeToDic:json];
            [arr addObject:dic];
        }
        [self publishStreams:arr result:result];
    } else if ([call.method isEqualToString:KUnPublishStreams]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *json in (NSArray *)call.arguments) {
            NSDictionary *dic = [RCFlutterTools decodeToDic:json];
            [arr addObject:dic];
        }
        [self unpublishStreams:arr result:result];
    } else if ([call.method isEqualToString:KSubscribeStream]) {
        NSArray *streams = [RCFlutterTools decodeToArray:call.arguments];
        [self subscribeStreams:streams result:result];
    } else if ([call.method isEqualToString:KUnSubscribeStream]) {
        NSArray *streams = [RCFlutterTools decodeToArray:call.arguments];
        [self unsubscribeStreams:streams result:result];
    } else if ([call.method isEqualToString:KSetAttributeValue]) {
        [self setAttributeValue:call result:result];
    } else if ([call.method isEqualToString:KDeleteAttributes]) {
        [self deleteAttributes:call result:result];
    } else if ([call.method isEqualToString:KGetAttributes]) {
        [self getAttributes:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setRtcUser:(RCRTCUser *)rtcUser {
    [super setRtcUser:rtcUser];
    [self registerChannel];
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.userId forKey:@"id"];
    return dic;
}

- (void)publishStreams:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray *array = [self getPublishRTCStreamsFromEngineWithArr:streams];
    [self publishStreams:array completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)unpublishStreams:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray *array = [self getUnPublishStreamsFromLocalUserWithArr:streams];
    [self unpublishStreams:array completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)subscribeStreams:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray<RCRTCInputStream *> *inputStreams = [self getAllStreamsWithArr:streams];
    [self subscribeStreams:nil tinyStreams:inputStreams completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)unsubscribeStreams:(NSArray<NSDictionary *> *)streams result:(FlutterResult)result {
    NSArray<RCRTCInputStream *> *inputStreams = [self getAllStreamsWithArr:streams];
    [self unsubscribeStreams:inputStreams completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (RCRTCOutputStream *)getOutputStreamFromJSON:(NSString *)json {
    NSDictionary *dic = [RCFlutterTools decodeToDic:json];
    RCRTCCameraOutputStream *videoStream = [RCRTCEngine sharedInstance].defaultVideoStream;
    RCRTCMicOutputStream *audioStream = [RCRTCEngine sharedInstance].defaultAudioStream;
    if ([self stream:videoStream isEqualToStreamDic:dic]) {
        return videoStream;
    } else if ([self stream:audioStream isEqualToStreamDic:dic]) {
        return audioStream;
    } else {
        NSString *streamId = dic[@"streamId"];
        int type = [dic[@"type"] intValue];
        NSString *tag = dic[@"tag"];
        NSString *key = [NSString stringWithFormat:@"%@_%d_%@", streamId, type, tag];
        RCFlutterOutputStream *stream = RCFlutterEngine.sharedEngine.createdOutputStreams[key];
        if (stream != nil) {
            return stream.rtcOutputStream;
        }
    }
    return nil;
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

- (void)setAttributeValue:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSString *key = dic[@"key"];
    NSString *value = dic[@"value"];
    NSString *object = dic[@"object"];
    NSString *content = dic[@"content"];
    RCMessageContent *message = [ThisClassShouldNotBelongHere string2MessageContent:object content:content];
    [self setAttributeValue:value
                     forKey:key
                    message:message
                 completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)deleteAttributes:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSArray *keys = [RCFlutterTools decodeToArray:dic[@"keys"]];
    NSString *object = dic[@"object"];
    NSString *content = dic[@"content"];
    RCMessageContent *message = [ThisClassShouldNotBelongHere string2MessageContent:object content:content];
    [self deleteAttributes:keys
                   message:message
                completion:^(BOOL isSuccess, RCRTCCode desc) {
        result(@(desc));
    }];
}

- (void)getAttributes:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    NSArray *keys = [RCFlutterTools decodeToArray:dic[@"keys"]];
    [self getAttributes:keys
             completion:^(BOOL isSuccess, RCRTCCode desc, NSDictionary * _Nullable attr) {
        result(attr);
    }];
}

@end
