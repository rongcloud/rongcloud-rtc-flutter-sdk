//
//  RCRTCVideoLayout.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCVideoLayout : NSObject

/*!
 自己输出视频流的宽
 */
@property (nonatomic, assign) int width;

/*!
 自己输出视频流的高
 */
@property (nonatomic, assign) int height;

/*!
 自己输出视频流的帧率
 */
@property (nonatomic, assign) int fps;

/*!
 自己输出视频流的码率
 */
@property (nonatomic, assign) int bitrate;

@end

NS_ASSUME_NONNULL_END
