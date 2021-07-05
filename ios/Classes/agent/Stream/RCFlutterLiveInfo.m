//
//  RCFlutterLiveInfo.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/9/27.
//

#import "RCFlutterLiveInfo.h"
#import "RCFlutterEngine.h"
#import "RCFlutterEngine+Private.h"
#import "RCFlutterChannelKey.h"
#import "RCFlutterTools.h"

@interface RCFlutterLiveInfo ()

@property(nonatomic, copy) NSString *roomId;

@property(nonatomic, copy) NSString *userId;

@property(nonatomic, strong) RCRTCLiveInfo *liveInfo;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar;

- (void)registerChannel;

@end

@implementation RCFlutterLiveInfo

@synthesize roomId = _roomId;
@synthesize userId = _userId;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

+ (RCFlutterLiveInfo *) flutterLiveInfoWithLiveInfo:(RCRTCLiveInfo *)liveInfo roomId:(NSString *)roomId userId:(NSString *)userId {
    RCFlutterLiveInfo *info = [[RCFlutterLiveInfo alloc] init];
    info.liveInfo = liveInfo;
    info.roomId = roomId;
    info.userId = userId;
    [info registerChannel];
    return info;
}

- (void)registerChannel {
    NSString *channelId = [NSString stringWithFormat:@"rong.flutter.rtclib/LiveInfo:%@", self.roomId];
    FlutterMethodChannel *streamChannel = [FlutterMethodChannel methodChannelWithName:channelId binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:streamChannel];
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.liveInfo) {
        dic[@"roomId"] = self.roomId;
        dic[@"userId"] = self.userId;
        dic[@"liveUrl"] = self.liveInfo.liveUrl;
    }
    return dic;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KAddPublishStreamUrl]) {
        [self addPublishStreamUrl:call result:result];
    } else if ([call.method isEqualToString:KRemovePublishStreamUrl]) {
        [self removePublishStreamUrl:call result:result];
    } else if ([call.method isEqualToString:KSetMixConfig]) {
        [self setMixConfig:call result:result];
    }
}

- (void)addPublishStreamUrl:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *url = call.arguments;
    [self.liveInfo addPublishStreamUrl:url
                            completion:^(BOOL isSuccess, RCRTCCode code, NSArray *urls) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"code"] = @((int) code);
        if (isSuccess) {
            dic[@"data"] = urls;
        } else {
            dic[@"data"] = @"add publish stream url error!";
        }
        result(dic);
    }];
}

- (void)removePublishStreamUrl:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *url = call.arguments;
    [self.liveInfo removePublishStreamUrl:url
                               completion:^(BOOL isSuccess, RCRTCCode code, NSArray * urls) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"code"] = @((int) code);
        if (isSuccess) {
            dic[@"data"] = urls;
        } else {
            dic[@"data"] = @"remove publish stream url error!";
        }
        result(dic);
    }];
}

- (void)setMixConfig:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *json = call.arguments;
    NSDictionary *dic = [RCFlutterTools decodeToDic:json];
    RCRTCMixConfig *config = [self parseMixConfig:dic];
    [self.liveInfo setMixConfig:config completion:^(BOOL isSuccess, RCRTCCode code) {
        result(@(code));
    }];
}

// 设置合流布局
- (RCRTCMixConfig *)parseMixConfig:(NSDictionary *)dic {
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    
    RCRTCMixLayoutMode mode = [dic[@"mode"] integerValue];
    streamConfig.layoutMode = mode;
    
    NSString *streamId = [dic objectForKey:@"host_stream_id"];
    NSString *userId = [dic objectForKey:@"host_user_id"];
    if (![streamId isEqual:[NSNull null]] && ![userId isEqual:[NSNull null]]) {
        NSArray<RCRTCOutputStream *> *streams = RCRTCEngine.sharedInstance.room.localUser.streams;
        for (RCRTCOutputStream *stream in streams) {
            if (stream.mediaType == RTCMediaTypeVideo &&
                [[stream streamId] isEqualToString:streamId] &&
                [[stream userId] isEqualToString:userId]) {
                streamConfig.hostVideoStream = stream;
            }
        }
    }

    NSDictionary *output = [dic objectForKey:@"output"];
    if (![output isEqual:[NSNull null]]) {
        NSDictionary *video = [output objectForKey:@"video"];
        if (![video isEqual:[NSNull null]]) {

            NSDictionary *normal = [video objectForKey:@"normal"];
            if (![normal isEqual:[NSNull null]]) {
                [streamConfig.mediaConfig.videoConfig.videoLayout setValuesForKeysWithDictionary:normal];
            }
            NSDictionary *tiny = [video objectForKey:@"tiny"];
            if (![tiny isEqual:[NSNull null]]) {
                [streamConfig.mediaConfig.videoConfig.tinyVideoLayout setValuesForKeysWithDictionary:normal];
            }
            
            NSDictionary *exparams = [video objectForKey:@"exparams"];
            if (![exparams isEqual:[NSNull null]]) {
                streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = [exparams[@"renderMode"] integerValue];
            } else {
                streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = RCRTCVideoRenderModeCrop;
            }

        }
        
        NSDictionary *audio = [output objectForKey:@"audio"];
        if (![audio isEqual:[NSNull null]]) {
            streamConfig.mediaConfig.audioConfig.bitrate = [audio[@"bitrate"] integerValue];
        }
    }
    
    NSDictionary *input = [dic objectForKey:@"input"];
    NSArray *customs = nil;
    if (![input isEqual:[NSNull null]]) {
        customs = [input objectForKey:@"video"];
    }
    if (mode == RCRTCMixLayoutModeCustom && ![customs isEqual:[NSNull null]]) {
        NSMutableArray<RCRTCStream *> *streams = [NSMutableArray array];
        NSArray<RCRTCRemoteUser *> *users = RCRTCEngine.sharedInstance.room.remoteUsers;
        for (RCRTCRemoteUser* user in users) {
            for (RCRTCInputStream *stream in user.remoteStreams) {
                if (stream.mediaType == RTCMediaTypeVideo) {
                    [streams addObject:stream];
                }
            }
        }
        
        for (RCRTCOutputStream *stream in RCRTCEngine.sharedInstance.room.localUser.streams) {
            if (stream.mediaType == RTCMediaTypeVideo) {
                [streams addObject:stream];
            }
        }
        
        
        NSMutableArray<RCRTCCustomLayout *> *layouts = [self customLayoutsWithStreams:streams withConfigArr:customs];
        streamConfig.customLayouts = layouts;

        streamConfig.customMode = YES;
    } else {
        streamConfig.customMode = NO;
    }
    return streamConfig;
}

- (NSMutableArray<RCRTCCustomLayout *> *)customLayoutsWithStreams:(NSMutableArray *)streams
                                                    withConfigArr:(NSArray *)configs {
//    NSInteger streamCount = streams.count;
//    int itemWidth = 150;
//    int itemHeight = itemWidth;
    NSMutableArray <RCRTCCustomLayout *>* result = [NSMutableArray array];
    for (RCRTCStream *stream in streams) {
        RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
        for (NSDictionary *dic in configs) {
            if ([dic[@"user_id"] isEqualToString:stream.userId] && [dic[@"stream_id"] isEqualToString:stream.streamId]) {
                inputConfig.x = [dic[@"x"] integerValue];
                inputConfig.y = [dic[@"y"] integerValue];
                inputConfig.width = [dic[@"width"] integerValue];
                inputConfig.height = [dic[@"width"] integerValue];
                inputConfig.videoStream = stream;
            } else {
                // TODO: 流的数量和配置数量不对应怎么办?
                //需要 json 转 model的解析工具封装且不能影响 RCRTCLib层的代码
            }
        }
        [result addObject:inputConfig];
    }
    return result;
}





@end
