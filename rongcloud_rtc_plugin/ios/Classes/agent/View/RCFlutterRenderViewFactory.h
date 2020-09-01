//
//  RCFlutterRenderViewFactory.h
//  Pods-Runner
//
//  Created by 孙承秀 on 2020/6/1.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterRenderView.h"
#import "RCFlutterMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRenderViewFactory: NSObject <FlutterPlatformViewFactory>

/// 单例
SingleInstanceH(ViewFactory);

/// 销毁资源
- (void)destroy;

/// 挂载 flutter 资源
/// @param messenger FlutterBinaryMessenger
- (void)withMessenger:(NSObject <FlutterBinaryMessenger> *)messenger;

/// 获取本地或者远端的渲染试图
/// @param viewId 试图 ID
/// @param type 本地或者远端标记
- (RCFlutterRenderView *)getViewWithId:(int)viewId andType:(RongFlutterRenderViewType)type;

/// 释放 view
/// @param viewId viewId
- (void)releaseVideoView:(int )viewId;
@end

NS_ASSUME_NONNULL_END
