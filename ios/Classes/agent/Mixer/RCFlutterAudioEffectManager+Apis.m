//
//  RCFlutterAudioEffectManager+Apis.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/27.
//

#import "RCFlutterAudioEffectManager+Apis.h"

@implementation RCFlutterAudioEffectManager (Apis)

- (RCRTCCode)preloadEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath {
    return [[RCFlutterRTCManager sharedRTCManager] preloadEffect:soundId filePath:filePath];
}

- (RCRTCCode)unloadEffect:(NSInteger)soundId {
    return [[RCFlutterRTCManager sharedRTCManager] unloadEffect:soundId];
}

- (RCRTCCode)playEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath loopCount:(int)loopCount publish:(BOOL)publish {
    return [[RCFlutterRTCManager sharedRTCManager] playEffect:soundId filePath:filePath loopCount:loopCount publish:publish];
}

- (RCRTCCode)stopEffect:(NSInteger)soundId {
    return [[RCFlutterRTCManager sharedRTCManager] stopEffect:soundId];
}

- (RCRTCCode)stopAllEffects {
    return [[RCFlutterRTCManager sharedRTCManager] stopAllEffects];
}

- (RCRTCCode)pauseEffect:(NSInteger)soundId {
    return [[RCFlutterRTCManager sharedRTCManager] pauseEffect:soundId];
}

- (RCRTCCode)pauseAllEffects {
    return [[RCFlutterRTCManager sharedRTCManager] pauseAllEffects];
}

- (RCRTCCode)resumeEffect:(NSInteger)soundId {
    return [[RCFlutterRTCManager sharedRTCManager] resumeEffect:soundId];
}

- (RCRTCCode)resumeAllEffects {
    return [[RCFlutterRTCManager sharedRTCManager] resumeAllEffects];
}

- (RCRTCCode)setEffectsVolume:(NSUInteger)volume {
    return [[RCFlutterRTCManager sharedRTCManager] setEffectsVolume:volume];
}

- (RCRTCCode)setVolumeOfEffect:(NSInteger)soundId withVolume:(NSUInteger)volume {
    return [[RCFlutterRTCManager sharedRTCManager] setVolumeOfEffect:soundId withVolume:volume];
}

- (NSUInteger)getVolumeOfEffectId:(NSInteger)soundId {
    return [[RCFlutterRTCManager sharedRTCManager] getVolumeOfEffectId:soundId];
}

- (NSUInteger)getEffectsVolume {
    return [[RCFlutterRTCManager sharedRTCManager] getEffectsVolume];
}

@end
