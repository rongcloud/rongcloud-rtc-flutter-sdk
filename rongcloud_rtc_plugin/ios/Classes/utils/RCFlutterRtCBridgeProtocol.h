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
 离开房间
 
 @param roomId 房间 Id
 @param completion 加入房间回调
 @discussion
 离开房间时不需要调用取消资源发布和关闭摄像头, SDK 内部会做好取消发布和关闭摄像头资源释放逻辑
 
 @remarks 房间管理
 */
- (void)leaveRTCRoom:(NSString *)roomId
          completion:(void (^)(BOOL, RCRTCCode code))completion;

/*!
 切换使用外放/听筒
 
 @param useSpeaker YES 使用扬声器  NO 不使用
 @discussion
 切换使用外放/听筒
 
 @remarks 音频配置
 @return 接入外设时, 如蓝牙音箱等 返回 NO
 */
- (void)useSpeaker:(BOOL)useSpeaker;


@end



#pragma mark - local user 相关接口
@protocol RCFlutterLocalUserProtocol <NSObject>

/*!
 发布默认音视频流
 
 @param completion 发布完成回调
 @discussion
 发布默认音视频流
 
 @remarks 资源管理
 */
- (void)publishRTCDefaultAVStream:(RongFlutterOperationCallback)completion;

/*!
 取消发布默认音视频流
 
 @param completion 取消发布完成回调
 @discussion
 取消发布默认音视频流
 
 @remarks 资源管理
 */
- (void)unpublishDefaultStream:(RongFlutterOperationCallback)completion;

/*!
 发布音视频流
 
 @param stream 发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 发布音视频流
 
 @remarks 资源管理
 */
- (void)publishStream:(RCRTCOutputStream *)stream
           completion:(nonnull RongFlutterOperationCallback)completion;

/*!
 取消发布音视频流
 
 @param stream 取消发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 取消发布音视频流1
 
 @remarks 资源管理
 */
- (void)unpublishStream:(RCRTCOutputStream *)stream
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
- (void)unsubscribeStream:(NSArray <RCRTCInputStream *> *)streams
               completion:(nonnull RCRTCOperationCallback)completion;
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

/// 切换前后摄像头
- (void)switchCamera;

/// 关闭摄像头
- (void)stopCamera;

/// 是否禁用
/// @param mute 是否禁用
- (void)setIsMute:(BOOL)mute;

/// 渲染本地试图
/// @param localView 本地试图
- (void)renderView:(RCRTCLocalVideoView *)localView;

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
@end

@protocol RCFlutterRTCProtocol <RCFlutterRoomProtocol, RCFlutterLocalUserProtocol, RCFlutterVideoCaptureProtocol, RCFlutterAudioCaptureProtocol, RCFlutterRemoteUserProtocol>

@end

NS_ASSUME_NONNULL_END
