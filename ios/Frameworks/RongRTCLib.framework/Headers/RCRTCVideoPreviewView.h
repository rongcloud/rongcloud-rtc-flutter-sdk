//
//  RCVideoPreview.h
//  RongRTCLib
//
//  Created by RongCloud on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 预览视频 view 的基类
 */
@interface RCRTCVideoPreviewView : UIView

/*!
 视频填充方式
 */
@property (nonatomic, assign) RCRTCVideoFillMode fillMode;

/*!
 修改 Frame 时, 是否使用动画, 默认: YES
 */
@property (nonatomic, assign) BOOL frameAnimated;

@end

NS_ASSUME_NONNULL_END
