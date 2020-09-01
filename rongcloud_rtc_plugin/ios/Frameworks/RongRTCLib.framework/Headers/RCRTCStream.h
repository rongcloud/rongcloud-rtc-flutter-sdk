//
//  RCRTCStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/5/18.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 音视频流
 */
@interface RCRTCStream : NSObject

/*!
 流ID，或者媒体ID
 */
@property (nonatomic, copy, readonly) NSString *streamId;

/*!
 流类型
 */
@property (nonatomic, assign, readonly) RTCMediaType mediaType;

/*!
 流唯一扩展标识符
 */
@property (nonatomic, copy, readonly) NSString *tag;

/*!
 发布人用户ID
 */
@property (nonatomic, copy, readonly) NSString *userId;

/*!
 设备是否已打开的状态标志
 */
@property (nonatomic, assign, readonly) RCRTCResourceState resourceState;

/*!
 将该流禁用
 注：
 1. 对于远端流（输入流），只是不解码视频与音频，但是音视频数据是正常接收的，如果不想接收数据可以进行取消订阅远端流
 2. 对于本地流（输出流），不编码和发送音视频数据，不影响采集。
 */
@property (nonatomic, assign, readwrite) BOOL isMute;

@end

NS_ASSUME_NONNULL_END
