//
//  RCRTCLiveInfo.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/8/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTCMixConfig.h"
#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCLiveInfo : NSObject

/**
 当前的直播地址
 */
@property (nonatomic, copy, readonly) NSString *liveUrl;

/*!
 设置混流布局配置
 
 @param config 混流布局配置
 @param completion 动作的回调
 @discussion
 设置混流布局配置
 
 @remarks 资源管理
 */
- (void)setMixStreamConfig:(RCRTCMixConfig *)config
                completion:(void (^) (BOOL isSuccess, RCRTCCode code))completion;

/*
 添加一个推流地址
 
 @param url 推流地址
 @param completion 回调
 */
- (void)addPublishStreamUrl:(NSString *)url
                 completion:(void (^)(BOOL isSuccess, RCRTCCode code, NSArray *))completion;

/*
 移除一个推流地址
 
 @param url 要移除的推流地址
 @param completion 回调
 */
- (void)removePublishStreamUrl:(NSString *)url
                    completion:(void (^)(BOOL isSuccess, RCRTCCode code, NSArray *))completion;

@end

NS_ASSUME_NONNULL_END
