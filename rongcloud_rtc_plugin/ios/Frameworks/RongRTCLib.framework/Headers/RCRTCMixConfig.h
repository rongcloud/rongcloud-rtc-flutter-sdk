//
//  RCRTCMixConfig.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCRTCCustomLayout.h"
#import "RCRTCMediaConfig.h"
#import "RCRTCStream.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , RCRTCMixLayoutMode) {
    /*!
     自定义布局
     */
    RCRTCMixLayoutModeCustom = 1 ,
    /*!
     悬浮布局
    */
    RCRTCMixLayoutModeSuspension = 2 ,
    /*!
     自适应布局
    */
    RCRTCMixLayoutModeAdaptive = 3,
};


@interface RCRTCMixConfig : NSObject

/*!
 合流服务版本，不支持修改。
 */
@property (nonatomic, assign,readonly) int version;

/*!
 合流模式，1： 自定义布局    2：悬浮布局  3：自适应布局
 
 模式 2 和 3 时不需要设置 用户的 customLayoutList
 */
@property (nonatomic, assign) RCRTCMixLayoutMode layoutMode;

/**
 mode 为 2 或者 3 时可用，作用将此 stream 置顶，必须为视频流
 */
@property (nonatomic, strong) RCRTCStream *hostVideoStream;

/*!
 自定义流列表，SDK 根据输入流列表中的流进行混流，仅自定义布局的时候使用，效果为设置其他人的窗口排版
 */
@property (nonatomic, strong) NSMutableArray <RCRTCCustomLayout *> *customLayouts;

/*!
 合流音视频配置，包括音频和视频
 */
@property (nonatomic, strong) RCRTCMediaConfig *mediaConfig;

@end

NS_ASSUME_NONNULL_END
