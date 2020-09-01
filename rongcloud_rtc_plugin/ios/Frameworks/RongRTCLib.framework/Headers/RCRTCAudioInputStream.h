//
//  RCRTCAudioInputStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/6/1.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCRTCInputStream.h"

/*!
 接收到的的音频流
 */
@interface RCRTCAudioInputStream : RCRTCInputStream

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用
 
 @remarks 资源管理
 @return RCRTCAudioInputStream 实例对象
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 初始化
 
 @discussion
 初始化
 
 @warning
 请勿调用, 仅供 SDK 内部调用
 
 @remarks 资源管理
 @return RCRTCAudioInputStream 实例对象
 */
- (instancetype)new NS_UNAVAILABLE;

@end
