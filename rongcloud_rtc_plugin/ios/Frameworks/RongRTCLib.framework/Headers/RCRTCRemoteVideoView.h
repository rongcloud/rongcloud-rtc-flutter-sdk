//
//  RCRemoteVideoView.h
//  RongRTCLib
//
//  Created by RongCloud on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCRTCVideoPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 渲染远端视频的 view
 */
@interface RCRTCRemoteVideoView : RCRTCVideoPreviewView

/*!
 是否隐藏视图
 
 @param isHidden 是否隐藏, YES 隐藏  NO 不隐藏
 @discussion
 隐藏视图后, 显示为纯黑底色
 
 @remarks 视频配置
 */
- (void)hiddenVideoView:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
