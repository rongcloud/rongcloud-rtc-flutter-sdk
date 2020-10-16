//
//  RCLocalPreviewView.h
//  RongRTCLib
//
//  Created by RongCloud on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCRTCVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

/*!
 视频渲染的 view
 
 @discussion
 请不要直接在 localView 上添加视图, 内部会有翻转的逻辑, 仅供手机摄像头视频显示使用
 */
@interface RCRTCLocalVideoView : RCRTCVideoPreviewView


/**
 本地 view 是否做镜像翻转，只做视图翻转，默认为 yes
 */
@property (nonatomic, assign) BOOL isPreviewMirror;


/*!
 刷新渲染视图 View
 
 @discussion
 刷新渲染视图 View
 
 @remarks 视频配置
 */
- (void)flushVideoView;

@end

NS_ASSUME_NONNULL_END
