//
//  RCRTCVideoStreamConfig.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/10.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 视频采集器参数
 */
@interface RCRTCVideoStreamConfig : NSObject

/*!
 摄像头输出的视频分辨率, 默认: RCRTCVideoSizePreset640x480
 */
@property (nonatomic, assign) RCRTCVideoSizePreset videoSizePreset;

/*!
 视频发送帧率. 默认: 15 FPS
 */
@property (nonatomic, assign) RCRTCVideoFPS videoFps;

/*!
 最大码率, 默认 640x480 分辨率时, 默认: 1000 kbps，如果外部修改过该值，使用修改的值
 */
@property (nonatomic, assign) NSUInteger maxBitrate;

/*!
 最小码率, 默认 640x480 分辨率时, 默认: 350 kbps，如果外部修改过该值，使用修改的值
 */
@property (nonatomic, assign) NSUInteger minBitrate;

@end

NS_ASSUME_NONNULL_END
