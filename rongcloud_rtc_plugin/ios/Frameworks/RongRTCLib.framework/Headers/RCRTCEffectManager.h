//
//  RCRTCEffectManager.h
//  RongRTCLib
//
//  Created by 孙承秀 on 2020/8/18.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTCCodeDefine.h"
NS_ASSUME_NONNULL_BEGIN
@interface RCRTCEffectManager : NSObject

/// 播放指定音效文件，filePath 必须可用，需要指定唯一的 ID，如果调用`preloadEffect`接口设置过 ID，此 ID 要与其相同
/// 如果前后传入相同的 ID，但是 filePath 不同，会覆盖，播放最新的 filePath 音效
/// @param soundId 音效的唯一 ID
/// @param filePath 音效的路径
/// @param loopCount 音效的循环次数
/// @param publish 是否将音效推送到远端，设置为 YES，其他端可听到此音效声音，如果设置为 NO，只有本端可以听到
- (RCRTCCode)playEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath loopCount:(int)loopCount publish:(BOOL)publish;

/// 停止指定的音效
/// @param soundId 音效唯一 ID
- (RCRTCCode)stopEffect:(NSInteger)soundId;

/// 停止所有的音效
- (RCRTCCode)stopAllEffects;

/// 暂停指定的音效文件
/// @param soundId 指定的音效 ID
- (RCRTCCode)pauseEffect:(NSInteger)soundId;

/// 暂停所有的音效
- (RCRTCCode)pauseAllEffects;

/// 恢复播放指定的音效
/// @param soundId 指定的音效 ID
- (RCRTCCode)resumeEffect:(NSInteger)soundId;

/// 恢复播放所有的音效
- (RCRTCCode)resumeAllEffects;

/// 预加载指定的音效文件，filePath 必须可用
/// @param soundId 指定的音效 ID
/// @param filePath 音效路径
- (RCRTCCode)preloadEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath;

/// 取消加载的音效文件
/// @param soundId 指定的音效 ID
- (RCRTCCode)unloadEffect:(NSInteger)soundId;

/// 设置全局的音效的音量
/// @param volume 音量 [0,100]，默认为 100.
- (RCRTCCode)setEffectsVolume:(NSUInteger)volume;

/// 设置指定音效的音效音量
/// @param soundId 指定的音效 ID
/// @param volume 音量 [0,100]，默认为 100
- (RCRTCCode)setVolumeOfEffect:(NSInteger)soundId withVolume:(NSUInteger)volume;

/// 获取指定音效的音量
- (NSUInteger)getVolumeOfEffectId:(NSInteger)soundId;

/// 获取全局音效的音量
- (NSUInteger)getEffectsVolume;


@end

NS_ASSUME_NONNULL_END
