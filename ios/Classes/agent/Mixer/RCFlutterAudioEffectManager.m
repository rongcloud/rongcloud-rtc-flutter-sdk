//
//  RCFlutterAudioEffectManager.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/27.
//

#import "RCFlutterAudioEffectManager.h"
#import "RCFlutterAudioEffectManager+Apis.h"
#import "RCFlutterAudioEffectManager+Private.h"
#import "RCFlutterChannelKey.h"
#import "RCFlutterTools.h"
#import "RCFlutterEngine.h"

@interface RCFlutterAudioEffectManager () {
    NSMutableDictionary *_effects;
}

@property(nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation RCFlutterAudioEffectManager

SingleInstanceM(AudioEffectManager);

- (instancetype) init {
    self = [super init];
    if (self) {
        _effects = [NSMutableDictionary dictionary];
        [RCRTCEngine sharedInstance].audioEffectManager.delegate = self;
        [self registerChannel];
    }
    return self;
}

- (NSDictionary *)toDic {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:[NSNumber numberWithInteger:0] forKey:@"id"];
    return dic;
}

- (void)destroy {
    [_effects removeAllObjects];
}

- (void)registerChannel {
    NSString *channelId = [NSString stringWithFormat:@"%@%d", KAudioEffectManager, 0];
    _channel = [FlutterMethodChannel methodChannelWithName:channelId
                                           binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:_channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KPreloadEffect]) {
        [self preloadEffect:call result:result];
    } else if ([call.method isEqualToString:KUnloadEffect]) {
        [self unloadEffect:call result:result];
    } else if ([call.method isEqualToString:KPlayEffect]) {
        [self playEffect:call result:result];
    } else if ([call.method isEqualToString:KPauseEffect]) {
        [self pauseEffect:call result:result];
    } else if ([call.method isEqualToString:KPauseAllEffects]) {
        [self pauseAllEffects:result];
    } else if ([call.method isEqualToString:KResumeEffect]) {
        [self resumeEffect:call result:result];
    } else if ([call.method isEqualToString:KResumeAllEffects]) {
        [self resumeAllEffects:result];
    } else if ([call.method isEqualToString:KStopEffect]) {
        [self stopEffect:call result:result];
    } else if ([call.method isEqualToString:KStopAllEffects]) {
        [self stopAllEffects:result];
    } else if ([call.method isEqualToString:KSetEffectsVolume]) {
        [self setEffectsVolume:call result:result];
    } else if ([call.method isEqualToString:KGetEffectsVolume]) {
        [self getEffectsVolume:result];
    } else if ([call.method isEqualToString:KSetEffectVolume]) {
        [self setEffectVolume:call result:result];
    } else if ([call.method isEqualToString:KGetEffectVolume]) {
        [self getEffectVolume:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)preloadEffect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSString *path = arguments[@"path"];
    NSString *assets = arguments[@"assets"];
    NSString *file = path != nil ? path : [self getAssetsPath:assets];
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    [_effects setObject:file forKey:@(effectId)];
    RCRTCCode code = [self preloadEffect:effectId filePath:file];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
    [self complete:code];
}

- (NSString *)getAssetsPath:(NSString *)assets {
    return [[NSBundle mainBundle] pathForResource:[[RCFlutterEngine sharedEngine].pluginRegister lookupKeyForAsset:assets] ofType:nil];
}

- (void)complete:(RCRTCCode)error {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(error) forKey:@"error"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    [self.channel invokeMethod:@"complete" arguments:json];
}

- (void)unloadEffect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    [_effects removeObjectForKey:@(effectId)];
    RCRTCCode code = [self unloadEffect:effectId];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)playEffect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    NSString *path = [_effects objectForKey:@(effectId)];
    int loopCount = [arguments[@"loopCount"] intValue];
    NSUInteger volume = [arguments[@"volume"] unsignedIntegerValue];
    RCRTCCode code = [self playEffect:effectId filePath:path loopCount:loopCount publish:YES];
    [self setVolumeOfEffect:effectId withVolume:volume];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)pauseEffect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    RCRTCCode code = [self pauseEffect:effectId];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)pauseAllEffects:(FlutterResult)result {
    RCRTCCode code = [self pauseAllEffects];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)resumeEffect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    RCRTCCode code = [self resumeEffect:effectId];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)resumeAllEffects:(FlutterResult)result {
    RCRTCCode code = [self resumeAllEffects];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)stopEffect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    RCRTCCode code = [self stopEffect:effectId];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)stopAllEffects:(FlutterResult)result {
    RCRTCCode code = [self stopAllEffects];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)setEffectsVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSUInteger volume = [arguments[@"volume"] unsignedIntegerValue];
    RCRTCCode code = [self setEffectsVolume:volume];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)getEffectsVolume:(FlutterResult)result {
    NSUInteger volume = [self getEffectsVolume];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(volume) forKey:@"volume"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)setEffectVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    NSUInteger volume = [arguments[@"volume"] unsignedIntegerValue];
    RCRTCCode code = [self setVolumeOfEffect:effectId withVolume:volume];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(code) forKey:@"code"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)getEffectVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSInteger effectId = [arguments[@"effectId"] integerValue];
    NSUInteger volume = [self getVolumeOfEffectId:effectId];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(volume) forKey:@"volume"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    result(json);
}

- (void)didReportEffectPlayingProgress:(float)progress effectId:(NSUInteger)effectId {
    
}

- (void)didEffectFinished:(NSUInteger)effectId {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(effectId) forKey:@"effectId"];
    NSString *json = [RCFlutterTools dictionaryToJson:dic];
    [self.channel invokeMethod:@"onEffectFinished" arguments:json];
}

@end
