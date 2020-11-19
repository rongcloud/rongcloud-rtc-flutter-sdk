//
//  RCFlutterAudioMixer.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/11/3.
//

#import "RCFlutterAudioMixer.h"
#import "RCFlutterAudioMixer+Apis.h"
#import "RCFlutterChannelKey.h"
#import "RCFlutterTools.h"
#import "RCFlutterEngine.h"

@interface RCFlutterAudioMixer () {
    float position;
}

@property(nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation RCFlutterAudioMixer

SingleInstanceM(AudioMixer);

- (instancetype) init {
    self = [super init];
    if (self) {
        position = 0;
        [[RCRTCAudioMixer sharedInstance] setDelegate:self];
        [self registerChannel];
    }
    return self;
}

- (void)registerChannel {
    _channel = [FlutterMethodChannel methodChannelWithName:KAudioMixer
                                           binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
    [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:_channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KStartMix]) {
        [self startMix:call result:result];
    } else if ([call.method isEqualToString:KSetMixingVolume]) {
        [self setMixingVolume:call result:result];
    } else if ([call.method isEqualToString:KGetMixingVolume]) {
        [self getMixingVolume:result];
    } else if ([call.method isEqualToString:KSetPlaybackVolume]) {
        [self setPlaybackVolume:call result:result];
    } else if ([call.method isEqualToString:KGetPlaybackVolume]) {
        [self getPlaybackVolume:result];
    } else if ([call.method isEqualToString:KSetVolume]) {
        [self setVolume:call result:result];
    } else if ([call.method isEqualToString:KGetDurationMillis]) {
        [self getDurationMillis:call result:result];
    } else if ([call.method isEqualToString:KGetCurrentPosition]) {
        [self getCurrentPosition:result];
    } else if ([call.method isEqualToString:KSeekTo]) {
        [self seekTo:call result:result];
    } else if ([call.method isEqualToString:KPause]) {
        [self pause:result];
    } else if ([call.method isEqualToString:KResume]) {
        [self resume:result];
    } else if ([call.method isEqualToString:KStop]) {
        [self stop:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)startMix:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSString *path = arguments[@"path"];
    NSString *assets = arguments[@"assets"];
    NSString *file = path != nil ? path : [self getAssetsPath:assets];
    int mode = [arguments[@"mode"] intValue];
    bool playback = [arguments[@"playback"] boolValue];
    int loopCount = [arguments[@"loopCount"] intValue];
    bool success = [self startMixingWithURL:[NSURL fileURLWithPath:file]
                                   playback:playback
                                  mixerMode:(RCRTCMixerMode)mode
                                  loopCount:loopCount];
    result(@(success));
}

- (NSString *)getAssetsPath:(NSString *)assets {
    return [[NSBundle mainBundle] pathForResource:[[RCFlutterEngine sharedEngine].pluginRegister lookupKeyForAsset:assets] ofType:nil];
}

- (void)setMixingVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    int volume = [arguments[@"volume"] intValue];
    [self setMixingVolume:volume];
    result(nil);
}

- (void)getMixingVolume:(FlutterResult)result {
    NSUInteger volume = [self getMixingVolume];
    result(@((int) volume));
}

- (void)setPlaybackVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    int volume = [arguments[@"volume"] intValue];
    [self setPlaybackVolume:volume];
    result(nil);
}

- (void)getPlaybackVolume:(FlutterResult)result {
    NSUInteger volume = [self getPlaybackVolume];
    result(@((int) volume));
}

- (void)setVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    int volume = [arguments[@"volume"] intValue];
    [self setVolume:volume];
    result(nil);
}

- (void)getDurationMillis:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSString *path = arguments[@"path"];
    Float64 duration = [self getDurationMillis:[NSURL fileURLWithPath:path]];
    result(@([[NSNumber numberWithFloat:duration] intValue]));
}

- (void)getCurrentPosition:(FlutterResult)result {
    result(@(position));
}

- (void)seekTo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    float position = [arguments[@"position"] floatValue];
    [self seekTo:position];
    result(nil);
}

- (void)pause:(FlutterResult)result {
    [self pause];
    result(nil);
}

- (void)resume:(FlutterResult)result {
    [self resume];
    result(nil);
}

- (void)stop:(FlutterResult)result {
    [self stop];
    result(nil);
}

- (void)didReportPlayingProgress:(float)progress {
    position = progress;
}

- (void)didPlayToEnd {
    [_channel invokeMethod:@"onMixEnd" arguments:nil];
}

@end
