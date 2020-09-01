//
//  RCRTCConfig.h
//  RongRTCLib
//
//  Created by jiangchunyu on 2020/8/12.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCConfig : NSObject

/*!
  默认 true：断网后一直保持重连； false：断网后 ping 4 次(约 40s)失败后退出音视频房间
 */
@property (nonatomic, assign) BOOL isEnableAutoReconnect;

/*!
  单位毫秒, 默认1000ms(1s)。 注意 interval 值太小会影响 SDK 性能，如果小于 100 配置无法生效
 */
@property (nonatomic, assign) NSUInteger statusReportInterval;

@end

NS_ASSUME_NONNULL_END
