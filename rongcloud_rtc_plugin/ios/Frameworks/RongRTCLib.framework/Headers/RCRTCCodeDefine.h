//
//  RongRTCError.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 音视频错误码定义
 
 服务器返回错误以 4 开头，后两位是业务代码，最后两位是错误码 4XXXX，如 400XX 基础连接部分
 本地返回错误以 5 开头，后两位是业务代码，最后两位是错误码 5XXXX，如 500XX 初始化基础连接部分
 */
typedef NS_ENUM (NSInteger, RCRTCCode) {
    /*!
     成功
     */
    RCRTCCodeSuccess                          = 0,
    /*!
     初始化失败, 信令服务（IM Server）未连接
     */
    RCRTCCodeSignalServerNotConnect           = 50000,
    /*!
     参数错误
     */
    RCRTCCodeParameterError                   = 50001,
    /*!
     加入相同房间错误，表示用户在客户端重复加入相同的房间
     */
    RCRTCCodeJoinToSameRoom                   = 50002,
    /*!
     不在房间中
     */
    RCRTCCodeNotInRTCRoom                     = 50003,
    /*!
     请检查是否开通音视频服务
     */
    RCRTCCodeEngineError                      = 50004,
    /*!
     RTC token为空，请查看是否还在房间内或者房间是否销毁
     */
    RCRTCCodeRTCTokenIsNull                   = 50006,
    /*!
     HTTP 请求超时
     */
    RCRTCCodeHttpTimeoutError                 = 50010,
    /*!
     HTTP 响应错误（含 500，404，405 等错误）
     */
    RCRTCCodeHttpResponseError                = 50011,
    /*!
     HTTP 请求错误（含网络不可达，请求未能为能正常发出）
     */
    RCRTCCodeHttpRequestError                 = 50012,
    /*!
     发布重复资源
     */
    RCRTCCodePublishDuplicateResources        = 50020,
    /*!
     初步会话协商错误，没有消息的音视频参数
     */
    RCRTCCodeSessionDegotiateOfferError       = 50021,
    /*!
     会话协商错误，协商数据不匹配或者其他问题
     */
    RCRTCCodeSessionDegotiateSetRemoteError   = 50022,
    /*!
     发布的流的个数已经到达上限
     */
    RCRTCCodePublishStreamsHasReachedMaxCount = 50023,
    /*!
     取消发布不存在的资源
     */
    RCRTCCodeUnpublishUnexistStream           = 50024,
    /*!
     订阅不存在的音视频资源
     */
    RCRTCCodeSubscribeNotExistResources       = 50030,
    /*!
     资源重复订阅
     */
    RCRTCCodeSubscribeDuplicateResources      = 50031,
    /*!
     取消订阅不存在的音视频资源
     */
    RCRTCCodeUnsubscribeNotExistResouce       = 50032,
    /*!
     SDK 内部业务逻辑错误码
     */
    RCRTCCodeSDKInternalError                 = 50071,
    /*!
     cdn 地址配置数量到达上限（最大为10个）
     */
    RCRTCCodeCDNCountReachToLimit             = 50080,
    /*!
     帧时间戳非法
     */
    RCRTCCodeIllegalFrameTimestamp            = 50081,
    /*!
     解码视频帧失败
     */
    RCRTCCodeDecodeVideoFrameError            = 50082,
    /*
     音效文件数量已经到达最大数量
     */
    RCRTCCodeEffectFileCountHasBeenReached    = 50090,
    /*
     处理非法的 soundId，如停止播放没有播放过的音效文件 id，
     此音效 ID 没有预设或者播放过。
     */
    RCRTCCodeHandlingIllegalEffectSoundId     = 50091,
};


@interface RCRTCCodeDefine : NSObject

+ (NSString *)codeDesc:(RCRTCCode)code;

@end
