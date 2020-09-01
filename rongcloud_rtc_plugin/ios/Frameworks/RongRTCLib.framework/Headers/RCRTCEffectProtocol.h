//
//  RCRTCEffectProtocol.h
//  RongRTCLib
//
//  Created by 孙承秀 on 2020/8/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCRTCCodeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCRTCEffectProtocol <NSObject>

- (RCRTCCode)playEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath loopCount:(int)loopCount publish:(BOOL)publish;
- (RCRTCCode)stopEffect:(NSInteger)soundId;
- (RCRTCCode)stopAllEffects;

- (float)getEffectsVolume;

/// 获取指定音效的音量
- (float)getEffectsVolumeOfEffect:(NSInteger)soundId;
- (RCRTCCode)setEffectsVolume:(float)volume;
- (RCRTCCode)setVolumeOfEffect:(NSInteger)soundId withVolume:(float)volume;
- (RCRTCCode)preloadEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath;
- (RCRTCCode)unloadEffect:(NSInteger)soundId;
- (RCRTCCode)pauseEffect:(NSInteger)soundId;
- (RCRTCCode)pauseAllEffects;
- (RCRTCCode)resumeEffect:(NSInteger)soundId;
- (RCRTCCode)resumeAllEffects;
@end

NS_ASSUME_NONNULL_END
