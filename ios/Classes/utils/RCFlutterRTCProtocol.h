#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN
/*!
 某些操作的回调
 
 @param isSuccess 操作是否成功
 @param desc 成功或者失败描述的错误码
 @discussion
 某些操作的回调
 
 @remarks 资源管理
 */
typedef void(^RongFlutterOperationCallback)(BOOL isSuccess, RCRTCCode desc);

/*!
 观众观看直播的回调
 
 @param desc 成功或者失败描述的错误码
 @param inputStream 当前直播流
 @discussion
 观众观看直播的回调
 
 @remarks 资源管理
 */
typedef void(^RCFlutterLiveCallback)(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream);

/*!
 直播操作的回调
 
 @param isSuccess 操作是否成功
 @param desc 成功或者失败描述的错误码
 @param liveInfo 当前直播主持人的数据模型
 @discussion
 直播操作的回调
 
 @remarks 资源管理
 */
typedef void(^RCFlutterLiveOperationCallback)(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo);


@protocol RCFlutterLiveProtocol <NSObject>

/*!
 加入房间, 可配置加入房间场景。
 
 @param roomId 房间 Id, 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符
 @param config 加入房间的配置, 主要用于配置直播场景。
 @param completion 加入房间回调, 其中 room 对象中的 remoteUsers, 存储当前房间中的所有人, 包括发布资源和没有发布资源的人
 @discussion
 加入房间
 
 @remarks 房间管理
 */
- (void)joinRTCRoom:(NSString *)roomId
          config:(RCRTCRoomConfig *)config
      completion:(nullable void (^)( RCRTCRoom  * _Nullable room, RCRTCCode code))completion;

/*!
 发布主播默认音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @param completion 发布完成回调
 @discussion
 发布主播默认音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishDefaultLiveStreams:(RCFlutterLiveOperationCallback)completion;

/*!
 发布直播音视频流
 
 @param stream 发布的音视频流
 @param completion 发布的音视频流结果, 包括此主播的推流 url
 @discussion
 发布直播音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishLiveStream:(nonnull RCRTCOutputStream *)stream
                completion:(nonnull RCFlutterLiveOperationCallback)completion;

/*!
仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用，此接口可具体订阅音频流或视频流或大小流

@param url 主播直播的 url
@param streamType 需要具体订阅的媒体类型
@param completion  动作的回调, 会依次回调主播的 RCRTCInputStream, 根据 streamType 区分是音频流还是视频流, 如主播发布了音视频流, 此回调会回调两次, 分别为音频的 RCRTCInputStream,  和视频的 RCRTCInputStream 。
@discussion
仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用

@remarks 资源管理
*/
- (void)subscribeLiveStream:(nonnull NSString *)url
                 streamType:(RCRTCAVStreamType)streamType
                 completion:(nullable RCFlutterLiveCallback)completion;

/*!
 仅直播模式可用, 作为观众, 退出观看主播的直播, 仅观众端使用
 @param url 主播直播的 url
 @param completion 动作的回调
 @discussion
 仅直播模式可用, 作为观众, 退出观看主播的直播, 仅观众端使用
 
 @remarks 资源管理
 */
- (void)unsubscribeLiveStream:(nonnull NSString *)url
                   completion:(void (^)(BOOL isSuccess, RCRTCCode code))completion;

@end


#pragma mark - room 相关接口
@protocol RCFlutterRoomProtocol <NSObject>
/*!
 加入房间
 
 @param roomId 房间 Id , 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符
 @param completion 加入房间回调,其中, room 对象中的 remoteUsers , 存储当前房间中的所有人, 包括发布资源和没有发布资源的人
 @discussion
 加入房间
 
 @remarks 房间管理
 */
- (void)joinRTCRoom:(NSString *)roomId
         completion:(void (^)(RCRTCRoom *_Nullable, RCRTCCode code))completion;

/*!
 离开房间
 
 @param leaveRTCRoom 加入房间回调
 @discussion
 离开房间时不需要调用取消资源发布和关闭摄像头, SDK 内部会做好取消发布和关闭摄像头资源释放逻辑
 
 @remarks 房间管理
 */
- (void)leaveRTCRoom:(void (^)(BOOL, RCRTCCode code))completion;

/*!
 切换使用外放/听筒
 
 @param useSpeaker YES 使用扬声器  NO 不使用
 @discussion
 切换使用外放/听筒
 
 @remarks 音频配置
 */
- (void)useSpeaker:(BOOL)useSpeaker;

@end



#pragma mark - local user 相关接口
@protocol RCFlutterLocalUserProtocol <NSObject>

/*!
 发布默认音视频直播流
 
 @param completion 发布完成回调
 @discussion
 发布默认音视频直播流
 
 @remarks 资源管理
 */
- (void)publishRTCDefaultLiveStreams:(RCFlutterLiveOperationCallback)completion;

/*!
 发布直播音视频流
 
 @param stream 发布的音视频流
 @param completion 发布的音视频流结果, 包括此主播的推流 url
 @discussion
 发布直播音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishRTCLiveStream:(nonnull RCRTCOutputStream *)stream
                  completion:(nonnull RCFlutterLiveOperationCallback)completion;

/*!
 发布默认音视频流
 
 @param completion 发布完成回调
 @discussion
 发布默认音视频流
 
 @remarks 资源管理
 */
- (void)publishRTCDefaultAVStreams:(RongFlutterOperationCallback)completion;

/*!
 取消发布默认音视频流
 
 @param completion 取消发布完成回调
 @discussion
 取消发布默认音视频流
 
 @remarks 资源管理
 */
- (void)unpublishDefaultStreams:(RongFlutterOperationCallback)completion;

/*!
 发布音视频流
 
 @param streams 发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 发布音视频流
 
 @remarks 资源管理
 */
- (void)publishStreams:(nullable NSArray<RCRTCOutputStream *> *)streams
            completion:(nonnull RongFlutterOperationCallback)completion;

/*!
 取消发布音视频流
 
 @param streams 取消发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 取消发布音视频流
 
 @remarks 资源管理
 */
- (void)unpublishStreams:(nullable NSArray<RCRTCOutputStream *> *)streams
              completion:(RongFlutterOperationCallback)completion;
/*!
 订阅流
 
 @param avStreams 普通流
 @param tinyStreams 需要携带小流的流数组
 @param completion 完成的回调
 @discussion
 avStreams 表示正常大流, tinyStreams 需要订阅的小流, 两个数组至少有一个不为空, 如果全为空, SDK 将断言, 如果小流数组中包含大流z数组中的流, 则 SDK 认为为订阅小流
 
 @remarks 资源管理
 */
- (void)subscribeStreams:(nullable NSArray<RCRTCInputStream *> *)avStreams
             tinyStreams:(nullable NSArray<RCRTCInputStream *> *)tinyStreams
              completion:(nullable RCRTCOperationCallback)completion;

/*!
 取消接收音视频流
 
 @param streams 发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 取消接收音视频流
 
 @remarks 资源管理
 */
- (void)unsubscribeStreams:(NSArray <RCRTCInputStream *> *)streams
               completion:(nonnull RCRTCOperationCallback)completion;

/*!
 设置用户属性
 
 @param attributeValue 属性值
 @param key 属性名称
 @param message 是否在设置属性的时候携带消息内容，传空则不往房间中发送消息（也不会收到有用户属性变换的回调）
 @param completion 设置完成回调
 @discussion
 设置用户属性
 
 @remarks 房间管理
 */
- (void)setAttributeValue:(NSString *)attributeValue
                   forKey:(NSString *)key
                  message:(RCMessageContent *)message
               completion:(RCRTCOperationCallback)completion;

/*!
 删除用户属性
 
 @param attributeKeys 属性名称数组
 @param message 是否在设置属性的时候携带消息内容，传空则不往房间中发送消息
 @param completion 删除完成回调
 @discussion
 删除用户属性
 
 @remarks 房间管理
 */
- (void)deleteAttributes:(NSArray <NSString *> *)attributeKeys
                 message:(RCMessageContent *)message
              completion:(RCRTCOperationCallback)completion;

/*!
 获取用户属性
 
 @param attributeKeys 属性名称
 @param completion 获取结果回调
 @discussion
 获取用户属性
 
 @remarks 房间管理
 */
- (void)getAttributes:(NSArray <NSString *> *)attributeKeys
           completion:(RCRTCAttributeOperationCallback)completion;

@end

#pragma mark - remote user api
@protocol RCFlutterRemoteUserProtocol <NSObject>

/*!
 将一个视频流切换成小码率视频流
 
 @param remoteUser 要切换的user
 @param streams 要切换的流
 @param completion 切换是否成功
 @discussion
 将一个视频流切换成小码率视频流
 
 @remarks 资源管理
 */
- (void)remoteUser:(RCRTCRemoteUser *)remoteUser
switchToTinyStream:(nonnull NSArray<RCRTCInputStream *> *)streams
        completion:(nullable RCRTCOperationCallback)completion;

/*!
 将一个视频流切换成正常码率视频流
 
 @param remoteUser 要切换的user
 @param streams 要切换的视频流
 @param completion 切换是否成功
 @discussion
 将一个视频流切换成正常码率视频流
 
 @remarks 资源管理
 */
- (void)remoteUser:(RCRTCRemoteUser *)remoteUser
switchToNormalStream:(nonnull NSArray<RCRTCInputStream *> *)streams
        completion:(nullable RCRTCOperationCallback)completion;
@end

#pragma mark - video capture 相关接口
@protocol RCFlutterVideoCaptureProtocol <NSObject>

/// 获取默认视频流
- (RCRTCCameraOutputStream *)getRTCCameraOutputStream;

/// 开启摄像头
- (void)startCapture;

- (void)startCapture:(NSNumber *)type;

/// 切换前后摄像头
- (bool)switchCamera;

/// 关闭摄像头
- (void)stopCamera;

/*!
 摄像头是否支持手动对焦功能
 
 @discussion
 摄像头是否支持手动对焦功能
 
 @remarks 摄像头配置
 */
- (BOOL)isCameraFocusSupported;

/*!
 摄像头是否支持手动曝光功能
 
 @discussion
 摄像头是否支持手动曝光功能
 
 @remarks 摄像头配置
 */
- (BOOL)isCameraExposurePositionSupported;

/*!
 手动设置对焦位置，并触发对焦
 
 @param point 对焦点，视图上的坐标点
 @discussion
 改变对焦位置
 
 @remarks 设置对焦位置
 */
- (BOOL)setCameraFocusPositionInPreview:(CGPoint)point;

/*!
 设置摄像头手动曝光位置
 
 @param point 曝光点，视图上的坐标点
 @discussion
 改变曝光位置
 
 @remarks 设置曝光位置
 */
- (BOOL)setCameraExposurePositionInPreview:(CGPoint)point;

/// 是否禁用
/// @param mute 是否禁用
- (void)setIsMute:(BOOL)mute;

/// 渲染纹理视图
/// @param view 纹理视图
- (void)setVideoTextureView:(RCRTCVideoTextureView *)view;

/// 视频配置
/// @param config 配置视频
- (void)setVideoConfig:(RCRTCVideoStreamConfig *)config;
@end


#pragma mark - audio capture 相关接口

@protocol RCFlutterAudioCaptureProtocol <NSObject>

/// 获取默认音频流
- (RCRTCMicOutputStream *)getRTCAudioOutputStream;

/// setMicrophoneDisable
- (void)setMicrophoneDisable:(BOOL)disable;

/// 是否禁用
/// @param mute 是否禁用
- (void)setIsMute:(BOOL)mute;

- (void)adjustRecordingVolume:(int)volume;

- (int)getRecordingVolume;

@end


#pragma mark - audio effect manager 相关接口

@protocol RCFlutterAudioEffectManagerProtocol <NSObject>

/// 预加载指定的音效文件，filePath 必须可用
/// @param soundId 指定的音效 ID
/// @param filePath 音效路径
- (RCRTCCode)preloadEffect:(NSInteger)soundId filePath:(NSString *_Nullable)filePath;

/// 取消加载的音效文件
/// @param soundId 指定的音效 ID
- (RCRTCCode)unloadEffect:(NSInteger)soundId;

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


#pragma mark - audio mixer 相关接口

@protocol RCFlutterAudioMixerProtocol <NSObject>

/*!
 开始混音(目前只支持混合本地音频数据), 开始新混音之前需要先调用 stop 结束混音, 重复调用会忽略操作
 @param fileURL 文件 URL  仅支持本地文件
 @param isPlay   是否播放
 @param mode 混音行为模式
 @param count 循环混音或者播放次数

 @discussion
 混音功能

 @remarks 音频配置
 @return 开始是否成功
 */
- (BOOL)startMixingWithURL:(NSURL *)fileURL
                  playback:(BOOL)isPlay
                 mixerMode:(RCRTCMixerMode)mode
                 loopCount:(NSUInteger)count;

/*!
 音频文件混音时的输入音量, 取值范围 [0,100], 默认值 100
 */
- (void)setMixingVolume:(NSUInteger)volume;

/*!
 音频文件混音时的输入音量, 取值范围 [0,100], 默认值 100
 */
- (NSUInteger)getMixingVolume;

/*!
 音频文件本地播放音量, 取值范围 [0,100], 默认值 100
 */
- (void)setPlaybackVolume:(NSUInteger)volume;

/*!
 音频文件本地播放音量, 取值范围 [0,100], 默认值 100
 */
- (NSUInteger)getPlaybackVolume;

/*!
 同时设置, 取值范围 [0,100], 默认值 100
 */
- (void)setVolume:(NSUInteger)volume;

/*!
 获取指定音频文件的时长

 @param url  音频文件的 File URL, 仅支持本地文件
 @discussion
 获取指定音频文件的时长

 @remarks 音频配置
 @return 音频文件的时长
 */
- (Float64)getDurationMillis:(NSURL *)url;

/*!
 设置播放进度
 @param position 设置播放进度 取值范围 [0,1]
 @discussion
 设置播放进度

 @remarks 音频配置
 */
- (void)seekTo:(float)position;

/*!
 暂停

 @remarks 音频配置
 @return 暂停是否成功
 */
- (BOOL)pause;

/*!
 恢复

 @remarks 音频配置
 @return 恢复是否成功
 */
- (BOOL)resume;

/*!
 结束

 @remarks 音频配置
 @return 结束是否成功
 */
- (BOOL)stop;

@end


#pragma mark - 接口集合

@protocol RCFlutterRTCProtocol <RCFlutterLiveProtocol,
                                RCFlutterRoomProtocol,
                                RCFlutterLocalUserProtocol,
                                RCFlutterRemoteUserProtocol,
                                RCFlutterVideoCaptureProtocol,
                                RCFlutterAudioCaptureProtocol,
                                RCFlutterAudioEffectManagerProtocol,
                                RCFlutterAudioMixerProtocol>

@end

NS_ASSUME_NONNULL_END
