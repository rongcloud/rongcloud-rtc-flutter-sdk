//
//  RCRTCVideoConfig.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCRTCVideoExtend.h"
#import "RCRTCVideoLayout.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCRTCVideoConfig : NSObject

/*!
 大视频流配置
 */
@property (nonatomic, strong) RCRTCVideoLayout *videoLayout;
/*!
 小视频流配置
 */
@property (nonatomic, strong) RCRTCVideoLayout *tinyVideoLayout;
/*!
 视频扩展
 */
@property (nonatomic, strong) RCRTCVideoExtend *videoExtend;

@end

NS_ASSUME_NONNULL_END
