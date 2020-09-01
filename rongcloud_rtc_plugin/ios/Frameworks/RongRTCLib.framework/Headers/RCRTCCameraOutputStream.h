//
//  RCRTCCameraOutputStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/8.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

#import "RCRTCVideoOutputStream.h"
#import "RCRTCLocalVideoView.h"
#import "RCRTCVideoStreamConfig.h"
#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 摄像头输出流，以摄像头为视频源的视频输出流
 */
@interface RCRTCCameraOutputStream : RCRTCVideoOutputStream

/*!
 摄像头的位置，前置/后置
 */
@property (nonatomic, assign, readwrite) RCRTCDeviceCamera cameraPosition;

/*!
 设置摄像头采集方向，默认以 AVCaptureVideoOrientationPortrait 角度进行采集
 */
@property (nonatomic, assign, readwrite) AVCaptureVideoOrientation videoOrientation;

/**
 摄像头是否做镜像翻转
 */
@property (nonatomic, assign) BOOL isPreviewMirror;

/*!
 引擎底部开始视频编码并发送之前会往上层抛一个回调,用户可以修改和调整 CMSampleBufferRef 数据,
 然后同步返回一个 CMSampleBufferRef 数据, 如果返回空或者没有实现该回调, 则会使用默认视频数据传输
 
 注：如果用户传正常数据,则内部会自行 CFRelease CMSampleBufferRef 对象,上层不需要再考虑释放问题
 */
@property (atomic, copy, nullable) RCRTCVideoCMSampleBufferCallback videoSendBufferCallback;

/*!
 本地摄像头采集的视频在即将预览前会往上层抛一个视频帧回调,用户可以处理视频帧数据之后然后回传给 RTC,RTC 使用用户处理的视频帧进行预览
 
 注：如果用户传正常数据,则内部会自行 CFRelease CMSampleBufferRef 对象,上层不需要再考虑释放问题
 */
@property (atomic, copy, nullable) RCRTCVideoCMSampleBufferCallback videoDisplayBufferCallback;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用，如要获取实例对象，请使用 [RCRTCEngine sharedInstance].defaultVideoStream 获取实例。
 
 @remarks 资源管理
 @return RCRTCCameraOutputStream 实例对象
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用，如要获取实例对象，请使用 [RCRTCEngine sharedInstance].defaultVideoStream 获取实例。
 
 @remarks 资源管理
 @return RCRTCCameraOutputStream 实例对象
 */
- (instancetype)new NS_UNAVAILABLE;

/*!
 写入视频流数据
 
 @param sample 媒体数据
 @param error 失败时返回的相关描述
 @discussion
 写入视频流数据
 
 @warning
 请勿调用，摄像头输出流内部已经实现摄像头数据采集，调用者无需自己写入视频流数据
 
 @remarks 资源管理
 */
- (void)write:(CMSampleBufferRef)sample error:(NSError **)error NS_UNAVAILABLE;

/*!
 设置视频源
 
 @param videoSource 视频源
 @discussion
 请勿调用，摄像头输出流的视频源已经封装在 SDK 内，调用者无需设置视频源，如果要自定义视频流，请使用 RCRTCVideoOutputStream
 
 @remarks 资源管理
 */
- (void)setVideoSource:(id<RCRTCVideoSourceInterface>)videoSource NS_UNAVAILABLE;

/*!
 设置视频数的渲染视图
 
 @param render 渲染视图
 @discussion
 设置本地摄像头采集的视频流渲染视图
 
 @remarks 视频配置
 */
- (void)setVideoView:(nullable RCRTCLocalVideoView *)render;

/*!
 开启摄像头采集数据
 
 @discussion
 开启摄像头采集数据
 
 @remarks 资源管理
 */
- (void)startCapture;

/*!
 关闭摄像头采集数据
 
 @discussion
 关闭摄像头采集数据
 
 @remarks 资源管理
 */
- (void)stopCapture;

/*!
 切换前后摄像头
 
 @discussion
 切换前后摄像头
 
 @remarks 视频配置
 */
- (void)switchCamera;

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

@end

NS_ASSUME_NONNULL_END
