//
//  RCRTCEngine.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTCLibDefine.h"
#import "RCRTCRoomConfig.h"
#import "RCRTCCodeDefine.h"
#import "RCRTCCryptoDelegate.h"
#import "RCRTCEffectManager.h"
NS_ASSUME_NONNULL_BEGIN

@class RCRTCRoom;
@class RCRTCVideoPreviewView;
@class RCRTCVideoStreamConfig;
@class RCRTCOutputStream;
@class RCRTCLiveInputStream;
@class RCRTCMicOutputStream;
@class RCRTCCameraOutputStream;
@protocol RCRTCActivityMonitorDelegate;


/*!
 音视频 SDK 对应版本
 
 RongRTCLib version: RongRTCLib_Version=>version
 RongRTCLib commit: RongRTCLib_Commit=>commit
 RongRTCLib time: RongRTCLib_Time=>time
 */


/*!
 音视频引擎入口
 */
@interface RCRTCEngine : NSObject

/*!
 音视频引擎单例
 */
+ (RCRTCEngine *)sharedInstance;

/**
 音效管理器，通过调用 `RCRTCEffectManager.h` 中的 API 实现所有音效功能。
 */
@property (nonatomic , strong , readonly) RCRTCEffectManager *effectManager;

/*!
 当前已加入的房间
 */
@property (nonatomic, strong, readonly) RCRTCRoom *currentRoom;

/*!
 默认音频流
 */
@property (atomic, strong, readonly) RCRTCMicOutputStream *defaultAudioStream;

/*!
 默认视频流
 */
@property (atomic, strong, readonly) RCRTCCameraOutputStream *defaultVideoStream;

/*!
 sdk 状态监视器代理
 */
@property (nonatomic, weak) id <RCRTCActivityMonitorDelegate> monitorDelegate;

/*!
 设置媒体服务服务地址
 
 @param url 媒体服务服务地址
 @discussion
 设置媒体服务服务地址，特别注意如果设置了会覆盖导航下载下来的 media server url
 
 @remarks 资源管理
 @return 设置是否成功
 */
- (BOOL)setMediaServerUrl:(NSString *)url;

/*!
 是否允许断线重连
 
 @param enable 断线重连开关
 @discussion
 是否允许断线重连, 默认 YES, SDK 在断线或者自己被踢出房间会尝试重连,
 如果设置为 NO, 自己被踢出房间将不再做重连, 会抛出 `- (void)didKickedOutOfTheRoom:(RCRTCRoom *)room;` 代理
 
 @remarks 资源管理
 */
- (void)setReconnectEnable:(BOOL)enable;

/*!
 切换使用外放/听筒
 
 @param useSpeaker YES 使用扬声器  NO 不使用
 @discussion
 切换使用外放/听筒
 
 @remarks 音频配置
 @return 接入外设时, 如蓝牙音箱等 返回 NO
 */
- (BOOL)useSpeaker:(BOOL)useSpeaker;

/*!
切换音频输出流是否进行自定义加密

@param audioEncryptorDelegate 加密代理，接口传入 RCRTCCustomizedEncryptorDelegate 的非空实现对象表示开启自定义加密；
如果传入 nil 代表关闭自定义加密。
 
@discussion
该接口设置为全局设置，对所有发送音频进行加密，开启时机为加入房间前或者观众订阅流前，关闭时机为离开房间或者观众取消订阅流后，
其它时机调用可能会不生效或者其它负面效果。

@remarks 加解密配置

*/
- (void) setAudioCustomizedEncryptorDelegate:(id <RCRTCCustomizedEncryptorDelegate>) audioEncryptorDelegate;

/*!
切换音频输入流是否进行自定义解密

@param audioDecryptorDelegate 加密代理，接口传入 RCRTCDecryptorDelegate 的非空实现对象表示开启自定义解密；
如果传入 nil 代表关闭自定义解密。
 
@discussion
该接口设置为全局设置，对所有接收音频进行解密，开启时机为加入房间前或者观众订阅流前，关闭时机为离开房间或者观众取消订阅流后，
其它时机调用可能会不生效或者其它负面效果。

@remarks 加解密配置

*/
- (void) setAudioCustomizedDecryptorDelegate:(id <RCRTCCustomizedDecryptorDelegate>) audioDecryptorDelegate;

/*!
切换视频输出流是否进行自定义加密

@param videoEncryptorDelegate 加密代理，接口传入 RCRTCCustomizedEncryptorDelegate 的非空实现对象表示开启自定义加密；
如果传入 nil 代表关闭自定义加密。
 
@discussion
该接口设置为全局设置，对所有发送视频进行加密，开启时机为加入房间前或者观众订阅流前，关闭时机为离开房间或者观众取消订阅流后，
其它时机调用可能会不生效或者其它负面效果。

@remarks 加解密配置

*/
- (void) setVideoCustomizedEncryptorDelegate:(id <RCRTCCustomizedEncryptorDelegate>) videoEncryptorDelegate;

/*!
切换视频输入流是否进行自定义解密

@param videoDecryptorDelegate 加密代理，接口传入 RCRTCDecryptorDelegate 的非空实现对象表示开启自定义解密；
如果传入 nil 代表关闭自定义解密。
 
@discussion
该接口设置为全局设置，对所有接收视频进行解密，开启时机为加入房间前或者观众订阅流前，关闭时机为离开房间或者观众取消订阅流后，
其它时机调用可能会不生效或者其它负面效果。

@remarks 加解密配置

*/
- (void) setVideoCustomizedDecryptorDelegate:(id <RCRTCCustomizedDecryptorDelegate>) videoDecryptorDelegate;

/*!
 加入房间
 
 @param roomId 房间 Id, 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符
 @param completion 加入房间回调,其中, room 对象中的 remoteUsers, 存储当前房间中的所有人, 包括发布资源和没有发布资源的人
 @discussion
 加入房间
 
 @remarks 房间管理
 */
- (void)joinRoom:(NSString *)roomId
      completion:(void (^)( RCRTCRoom  * _Nullable room, RCRTCCode code))completion;

/*!
 加入房间, 可配置加入房间场景。
 
 @param roomId 房间 Id, 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符
 @param config 加入房间的配置, 主要用于配置直播场景。
 @param completion 加入房间回调, 其中 room 对象中的 remoteUsers, 存储当前房间中的所有人, 包括发布资源和没有发布资源的人
 @discussion
 加入房间
 
 @remarks 房间管理
 */
- (void)joinRoom:(NSString *)roomId
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
- (void)leaveRoom:(NSString*)roomId
       completion:(void (^) (BOOL isSuccess, RCRTCCode code))completion;

/*!
 仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用
 
 @param url 主播直播的 url
 @param liveType 当前直播类型
 @param completion  动作的回调, 会依次回调主播的 RCRTCInputStream, 根据 streamType 区分是音频流还是视频流, 如主播发布了音视频流, 此回调会回调两次, 分别为音频的 RCRTCInputStream,  和视频的 RCRTCInputStream 。
 @discussion
 仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用
 
 @remarks 资源管理
 */
- (void)subscribeLiveStream:(NSString *)url
                   liveType:(RCRTCLiveType)liveType
                 completion:(nullable RCRTCLiveCallback)completion DEPRECATED_MSG_ATTRIBUTE("已废弃, 请使用 subscribeLiveStream:streamType:completion: 替换, 当前方法会在后续版本中删除");

/*!
仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用，此接口可具体订阅音频流或视频流或大小流

@param url 主播直播的 url
@param streamType 需要具体订阅的媒体类型
@param completion  动作的回调, 会依次回调主播的 RCRTCInputStream, 根据 streamType 区分是音频流还是视频流, 如主播发布了音视频流, 此回调会回调两次, 分别为音频的 RCRTCInputStream,  和视频的 RCRTCInputStream 。
@discussion
仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用

@remarks 资源管理
*/
- (void)subscribeLiveStream:(NSString *)url
                 streamType:(RCRTCAVStreamType)streamType
                 completion:(nullable RCRTCLiveCallback)completion;

/*!
 仅直播模式可用, 作为观众, 退出观看主播的直播, 仅观众端使用
 @param url 主播直播的 url
 @param completion 动作的回调
 @discussion
 仅直播模式可用, 作为观众, 退出观看主播的直播, 仅观众端使用
 
 @remarks 资源管理
 */
- (void)unsubscribeLiveStream:(NSString *)url
                   completion:(void (^)(BOOL isSuccess, RCRTCCode code))completion;

/*!
 获取 RongRTCLib 版本号
 
 @discussion
 获取 RongRTCLib 版本号
 
 @remarks 资源管理
 @return 版本号
 */
- (NSString *)getRTCLibVersion;

@end

NS_ASSUME_NONNULL_END
