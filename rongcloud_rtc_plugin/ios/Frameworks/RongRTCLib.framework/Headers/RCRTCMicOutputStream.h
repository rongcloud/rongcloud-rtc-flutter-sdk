//
//  RCRTCMicOutputStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/4/16.
//  Copyright © 2020年 RongCloud. All rights reserved.
//

#import "RCRTCOutputStream.h"
#import "RCRTCLibDefine.h"
#import "RCRTCAudioMixer.h"
#import "RCRTCAudioOutputStream.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 麦克风输出流，以麦克风为音频源的音频输出流
 */
@interface RCRTCMicOutputStream : RCRTCAudioOutputStream

/*!
 麦克风的音量, 范围: 0~100, 默认值: 100
 */
@property (nonatomic, assign) NSUInteger recordingVolume;

/*!
 音频码率
*/
@property (nonatomic, assign, readonly) NSInteger bitrateValue;

/*!
 音频编解码方式, 默认: OPUS
 */
@property (nonatomic, assign, readwrite) RCRTCAudioCodecType audioCodecType;

/*!
 音频使用模式，默认: 普通通话模式，RongRTC 支持音乐场景下的使用
 */
@property (nonatomic, assign, readwrite) RCRTCAudioScenario audioScenario;

/*!
 当 RTC 音频为音乐模式时，可以设置音乐演奏模式，默认常规演奏模式
 */
@property (nonatomic, assign, readwrite) RCRTCAudioScenarioMusicPlayMode musicPlayMode;

/*!
 将要发送的音频 pcm 数据的回调
 */
@property (nonatomic, copy, nullable) RCRTCAudioDataCallback willSendAudioBufferCallback;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用，如要获取实例对象，请使用 [RCRTCEngine sharedInstance].defaultAudioStream 获取实例。
 
 @remarks 资源管理
 @return 失败
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用，如要获取实例对象，请使用 [RCRTCEngine sharedInstance].defaultAudioStream 获取实例。
 
 @remarks 资源管理
 @return 失败
 */
- (instancetype)new NS_UNAVAILABLE;

/*!
 关闭/打开麦克风
 
 @param disable YES 关闭，NO 打开
 @discussion
 关闭/打开麦克风
 
 @remarks 音频配置
 */
- (void)setMicrophoneDisable:(BOOL)disable;

/*!
 设置音乐演奏模式
 
 @param mode RCRTCAudioScenarioMusicPlayMode 音乐演奏模式, RCRTCAudioScenarioMusicNormalPlay 常规演奏模式,默认模式
 @discussion
 设置音乐演奏模式
 
 @remarks 音频流处理
 @return 设置是否成功
 */
- (BOOL)changeMusicPlayMode:(RCRTCAudioScenarioMusicPlayMode)mode;

@end

NS_ASSUME_NONNULL_END
