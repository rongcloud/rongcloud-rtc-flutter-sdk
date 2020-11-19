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

@property(nonatomic, copy) NSString *liveUrl;

@property(nonatomic, copy) NSString *roomId;

@property(nonatomic, copy) NSString *userId;

@property(nonatomic, strong) RCRTCLiveInfo *liveInfo;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar;

- (void)registerChannel;

@end

@implementation RCFlutterLiveInfo

@synthesize liveUrl = _liveUrl;
@synthesize roomId = _roomId;
@synthesize userId = _userId;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

+ (RCFlutterLiveInfo *) flutterLiveInfoWithLiveInfo:(RCRTCLiveInfo *)liveInfo roomId:(NSString *)roomId userId:(NSString *)userId {
    RCFlutterLiveInfo *info = [[RCFlutterLiveInfo alloc] init];
    info.liveInfo = liveInfo;
    info.liveUrl = liveInfo.liveUrl;
    info.roomId = roomId;
    info.userId = userId;
    [info registerChannel];
    return info;
}

- (void)registerChannel {
    NSString *channelId = [NSString stringWithFormat:@"rong.flutter.rtclib/LiveInfo:%@", _liveInfo.liveUrl];
    FlutterMethodChannel *streamChannel = [FlutterMethodChannel methodChannelWithName:channelId binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:streamChannel];
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.liveInfo) {
        dic[@"liveUrl"] = self.liveUrl;
        dic[@"roomId"] = self.roomId;
        dic[@"userId"] = self.userId;
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
    [self.liveInfo setMixStreamConfig:config
                           completion:^(BOOL isSuccess, RCRTCCode code) {
        result(@(code));
    }];
}

// 设置合流布局
- (RCRTCMixConfig *)parseMixConfig:(NSDictionary *)rawDic{
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    
    RCRTCMixLayoutMode mode = [rawDic[@"mode"] integerValue];
    // 布局配置类
    // 选择模式
    streamConfig.layoutMode = mode;

    // 设置合流视频参数：宽 ,高 ,帧率 ,码率
    NSDictionary *vConfigDic = rawDic[@"output"][@"video"];
    RCRTCVideoConfig *vConfig = [[RCRTCVideoConfig alloc] init];
    [vConfig.videoLayout setValuesForKeysWithDictionary:vConfigDic[@"normal"]];
    
    if ([vConfigDic.allKeys containsObject:@"tiny"] && vConfigDic[@"tiny"] != [NSNull null]) {
        [vConfig.tinyVideoLayout setValuesForKeysWithDictionary:vConfigDic[@"tiny"]];
    }
    // 设置是否裁剪
    streamConfig.mediaConfig.videoConfig = vConfig;
    streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = 1;

    // 音频配置
    NSDictionary *aConfigDic = rawDic[@"output"][@"audio"];
    
    streamConfig.mediaConfig.audioConfig.bitrate = [aConfigDic[@"bitrate"] integerValue];


    NSMutableArray *streamArr = [NSMutableArray array];
    // 添加本地输出流
    NSArray<RCRTCOutputStream *> *localStreams
    = RCRTCEngine.sharedInstance.currentRoom.localUser.localStreams;
    for (RCRTCOutputStream *vStream in localStreams) {
        if (vStream.mediaType == RTCMediaTypeVideo) {
            [streamArr addObject:vStream];
        }
    }

    switch (mode) {
        case RCRTCMixLayoutModeCustom:
            // 自定义布局
        {
            // 如果是自定义布局需要设置下面这些
            NSArray<RCRTCRemoteUser *> *remoteUsers = RCRTCEngine.sharedInstance.currentRoom.remoteUsers;
            for (RCRTCRemoteUser* remoteUser in remoteUsers) {
                for (RCRTCInputStream *inputStream in remoteUser.remoteStreams) {
                    if (inputStream.mediaType == RTCMediaTypeVideo) {
                        [streamArr addObject:inputStream];
                    }
                }
            }
            NSMutableArray <RCRTCCustomLayout *> *customLayouts = [self customLayoutsWithStreams:streamArr withConfigArr:rawDic[@"input"][@"video"]];
            streamConfig.customLayouts = customLayouts;
        }
            break;
        case RCRTCMixLayoutModeSuspension:
            //悬浮布局
        {
            RCRTCOutputStream *vStream = [streamArr lastObject];
            streamConfig.hostVideoStream = vStream;
        }
            break;
        case RCRTCMixLayoutModeAdaptive:
            //自适应布局
        {
            RCRTCOutputStream *vStream = [streamArr lastObject];
            streamConfig.hostVideoStream = vStream;
        }
            break;
        default:
            break;
    }

    return streamConfig;
}

- (NSMutableArray <RCRTCCustomLayout *> *)customLayoutsWithStreams:(NSMutableArray *)streams
                 withConfigArr:(NSArray *)configs
{
//    NSInteger streamCount = streams.count;
//    int itemWidth = 150;
//    int itemHeight = itemWidth;
    NSMutableArray <RCRTCCustomLayout *>* result = [NSMutableArray array];
    for (RCRTCStream *stream in streams) {
        RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
        for (NSDictionary *dic in configs) {
            if ([dic[@"user_id"] isEqualToString:stream.userId]) {
                inputConfig.x = [dic[@"x"] integerValue];
                inputConfig.y = [dic[@"y"] integerValue];
                inputConfig.width = [dic[@"width"] integerValue];
                inputConfig.height = [dic[@"width"] integerValue];
                inputConfig.videoStream = stream;
            }else{
                // TODO: 流的数量和配置数量不对应怎么办?
                //需要 json 转 model的解析工具封装且不能影响 RCRTCLib层的代码
            }
        }
        [result addObject:inputConfig];
    }
    return result;
}





@end
