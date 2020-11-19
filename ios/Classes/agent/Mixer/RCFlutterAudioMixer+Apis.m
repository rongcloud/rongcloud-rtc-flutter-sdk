//
//  RCFlutterAudioMixer+Apis.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/11/3.
//

#import "RCFlutterAudioMixer+Apis.h"

@implementation RCFlutterAudioMixer (Apis)

- (BOOL)startMixingWithURL:(NSURL *)fileURL
                  playback:(BOOL)isPlay
                 mixerMode:(RCRTCMixerMode)mode
                 loopCount:(NSUInteger)count {
    return [[RCFlutterRTCManager sharedRTCManager] startMixingWithURL:fileURL
                                                             playback:isPlay
                                                            mixerMode:mode
                                                            loopCount:count];
}

- (void)setMixingVolume:(NSUInteger)volume {
    [[RCFlutterRTCManager sharedRTCManager] setMixingVolume:volume];
}

- (NSUInteger)getMixingVolume {
    return [[RCFlutterRTCManager sharedRTCManager] getMixingVolume];
}

- (void)setPlaybackVolume:(NSUInteger)volume {
    [[RCFlutterRTCManager sharedRTCManager] setPlaybackVolume:volume];
}

- (NSUInteger)getPlaybackVolume {
    return [[RCFlutterRTCManager sharedRTCManager] getPlaybackVolume];
}

- (void)setVolume:(NSUInteger)volume {
    [[RCFlutterRTCManager sharedRTCManager] setVolume:volume];
}

- (Float64)getDurationMillis:(NSURL *)url {
    return [[RCFlutterRTCManager sharedRTCManager] getDurationMillis:url];
}

- (void)seekTo:(float)position {
    [[RCFlutterRTCManager sharedRTCManager] seekTo:position];
}

- (BOOL)pause {
    return [[RCFlutterRTCManager sharedRTCManager] pause];
}

- (BOOL)resume {
    return [[RCFlutterRTCManager sharedRTCManager] resume];
}

- (BOOL)stop {
    return [[RCFlutterRTCManager sharedRTCManager] stop];
}


@end
