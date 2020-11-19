//
//  RCFlutterRTCManager+AudioMixer.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/11/3.
//

#import "RCFlutterRTCManager+AudioMixer.h"

@implementation RCFlutterRTCManager (AudioMixer)

- (BOOL)startMixingWithURL:(NSURL *)fileURL
                  playback:(BOOL)isPlay
                 mixerMode:(RCRTCMixerMode)mode
                 loopCount:(NSUInteger)count {
    return [[RCRTCAudioMixer sharedInstance] startMixingWithURL:fileURL
                                                       playback:isPlay
                                                      mixerMode:mode
                                                      loopCount:count];
}

- (void)setMixingVolume:(NSUInteger)volume {
    [RCRTCAudioMixer sharedInstance].mixingVolume = volume;
}

- (NSUInteger)getMixingVolume {
    return [RCRTCAudioMixer sharedInstance].mixingVolume;
}

- (void)setPlaybackVolume:(NSUInteger)volume {
    [RCRTCAudioMixer sharedInstance].playingVolume = volume;
}

- (NSUInteger)getPlaybackVolume {
    return [RCRTCAudioMixer sharedInstance].playingVolume;
}

- (void)setVolume:(NSUInteger)volume {
    [RCRTCAudioMixer sharedInstance].mixingVolume = volume;
    [RCRTCAudioMixer sharedInstance].playingVolume = volume;
}

- (Float64)getDurationMillis:(NSURL *)url {
    return [RCRTCAudioMixer durationOfAudioFile:url];
}

- (void)seekTo:(float)position {
    [[RCRTCAudioMixer sharedInstance] setPlayProgress:position];
}

- (BOOL)pause {
    return [[RCRTCAudioMixer sharedInstance] pause];
}

- (BOOL)resume {
    return [[RCRTCAudioMixer sharedInstance] resume];
}

- (BOOL)stop {
    return [[RCRTCAudioMixer sharedInstance] stop];
}

@end
