//
//  RCRTCVideoOutputStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/6/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCRTCOutputStream.h"
#import "RCRTCVideoSourceInterface.h"

@class RCRTCLocalVideoView;

NS_ASSUME_NONNULL_BEGIN

@class RCRTCVideoStreamConfig;

/**
 视频数据写入接口
 */
@protocol RCRTCVideoObserverInterface <NSObject>

/*!
 写入媒体流
 
 @param sample 媒体数据
 @param error 失败时返回的相关描述
 @discussion 写入媒体流, 该方法会直接将视频数据进行视频编码并发送只远端
 
 @remarks 资源管理
 */
- (void)write:(CMSampleBufferRef)sample error:(NSError **)error;

@end


@interface RCRTCVideoOutputStream : RCRTCOutputStream <RCRTCVideoObserverInterface>

/**
 是否启用视频小流。摄像头视频流，默认开启。自定义视频流，默认关闭
 */
@property (nonatomic, assign, readwrite) BOOL enableTinyStream;

/**
 可动态调整的视频配置
 */
@property (nonatomic, copy) RCRTCVideoStreamConfig *videoConfig;

/**
 视频流数据源
 */
@property (nonatomic, weak) id<RCRTCVideoSourceInterface> videoSource;

/*!
 初始化流数据的参数
 
 @param tag 用户自定标签，注：用户不能传特殊字符，只支持 ASCII
 @discussion
 初始化流数据的参数
 
 @remarks 资源管理
 @return 流对象
 */
- (instancetype)initVideoOutputStreamWithTag:(NSString *)tag;

/*!
 设置视频媒体数据的渲染界面
 
 @param render 渲染界面，传空则将原视图删除
 @discussion
 设置视频媒体数据的渲染界面
 
 @remarks 资源管理
 */
- (void)setVideoView:(nullable RCRTCLocalVideoView *)render;

/*!
 设置视频源
 
 @param source 视频源
 @discussion
 设置视频源，如果使用者需要自定义视频流的话，需要实现 RCRTCVideoSourceInterface 协议，视频源中通过调用 RCRTCVideoOutputStream 的 write 方法写入视频数据
 
 @remarks 资源管理
 */
- (void)setVideoSource:(id<RCRTCVideoSourceInterface>)source;

@end

NS_ASSUME_NONNULL_END
