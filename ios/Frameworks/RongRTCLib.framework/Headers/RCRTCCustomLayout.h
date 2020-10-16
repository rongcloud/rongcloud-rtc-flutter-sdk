//
//  RCRTCCustomLayout.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCRTCStream.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCRTCCustomLayout : NSObject

/*!
 要混流的流，必须为视频流
 */
@property (nonatomic, strong) RCRTCStream *videoStream;

/*!
 混流图层坐标的 y 值
 */
@property (nonatomic, assign) int y;

/*!
 混流图层坐标的 x 值
 */
@property (nonatomic, assign) int x;

/*!
 视频流的宽
 */
@property (nonatomic, assign) int width;

/*!
 视频流的高
 */
@property (nonatomic, assign) int height;

@end

NS_ASSUME_NONNULL_END
