//
//  RCRTCVideoInputStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/6/1.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCRTCInputStream.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 接收到视频流的代理
 */
@protocol RCRTCVideoInputStreamDelegate <NSObject>

/*!
 即将渲染视频帧数据回调
 
 @param ref 即将渲染的视频帧数据
 @param stream 即将渲染的视频帧数据所属接收到的流
 @discussion
 即将渲染视频帧数据, 如果需要自定义视频显示的话需要修改该视频帧
 
 @remarks 代理
 */
- (void)willRenderCVPixelBufferRef:(CVPixelBufferRef)ref stream:(RCRTCInputStream *)stream;

@end

/*!
 接收到的视频流
 */
@interface RCRTCVideoInputStream : RCRTCInputStream

/*!
 接收到视频流的代理
 */
@property (nonatomic, weak) id<RCRTCVideoInputStreamDelegate> delegate;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用
 
 @remarks 资源管理
 @return RCRTCVideoInputStream 实例对象
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用
 
 @remarks 资源管理
 @return RCRTCVideoInputStream 实例对象
 */
- (instancetype)new NS_UNAVAILABLE;

/*!
 设置视频流的渲染视图
 
 @param render 渲染视图
 @discussion
 接受到远端用户的视频流，然后设置视频流的渲染视图，就可以渲染出远端视频
 
 @remarks 视频配置
 */
- (void)setVideoView:(RCRTCRemoteVideoView *)render;

@end

NS_ASSUME_NONNULL_END
