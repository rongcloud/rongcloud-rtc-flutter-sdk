//
//  RCRTCActivityMonitorDelegate.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/6/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RCRTCStatisticalForm;

@protocol RCRTCActivityMonitorDelegate <NSObject>

@optional

/*!
 汇报 sdk 统计数据

 @param form 统计表单对象
 @discussion
 汇报 sdk 统计数据
 
 @remarks 代理
 */
- (void)didReportStatForm:(RCRTCStatisticalForm*)form;

@end

NS_ASSUME_NONNULL_END
