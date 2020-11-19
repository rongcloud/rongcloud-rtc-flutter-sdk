//
//  RCFlutterRTCManager+AudioEffectManager.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/27.
//

#import "RCFlutterRTCManager+AudioEffectManager.h"

@implementation RCFlutterRTCManager (AudioEffectManager)

- (RCRTCCode)preloadEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath {
    return [[RCRTCEngine sharedInstance].audioEffectManager preloadEffect:soundId filePath:filePath];
}

- (RCRTCCode)unloadEffect:(NSInteger)soundId {
    return [[RCRTCEngine sharedInstance].audioEffectManager unloadEffect:soundId];
}

- (RCRTCCode)playEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath loopCount:(int)loopCount publish:(BOOL)publish {
    return [[RCRTCEngine sharedInstance].audioEffectManager playEffect:soundId filePath:filePath loopCount:loopCount publish:publish];
}

- (RCRTCCode)stopEffect:(NSInteger)soundId {
    return [[RCRTCEngine sharedInstance].audioEffectManager stopEffect:soundId];
}

- (RCRTCCode)stopAllEffects {
    return [[RCRTCEngine sharedInstance].audioEffectManager stopAllEffects];
}

- (RCRTCCode)pauseEffect:(NSInteger)soundId {
    return [[RCRTCEngine sharedInstance].audioEffectManager pauseEffect:soundId];
}

- (RCRTCCode)pauseAllEffects {
    return [[RCRTCEngine sharedInstance].audioEffectManager pauseAllEffects];
}

- (RCRTCCode)resumeEffect:(NSInteger)soundId {
    return [[RCRTCEngine sharedInstance].audioEffectManager resumeEffect:soundId];
}

- (RCRTCCode)resumeAllEffects {
    return [[RCRTCEngine sharedInstance].audioEffectManager resumeAllEffects];
}

- (RCRTCCode)setEffectsVolume:(NSUInteger)volume {
    return [[RCRTCEngine sharedInstance].audioEffectManager setEffectsVolume:volume];
}

- (RCRTCCode)setVolumeOfEffect:(NSInteger)soundId withVolume:(NSUInteger)volume {
    return [[RCRTCEngine sharedInstance].audioEffectManager setVolumeOfEffect:soundId withVolume:volume];
}

- (NSUInteger)getVolumeOfEffectId:(NSInteger)soundId {
    return [[RCRTCEngine sharedInstance].audioEffectManager getVolumeOfEffectId:soundId];
}

- (NSUInteger)getEffectsVolume {
    return [[RCRTCEngine sharedInstance].audioEffectManager getEffectsVolume];
}

@end
