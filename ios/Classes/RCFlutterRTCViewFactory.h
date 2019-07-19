//
//  RCFlutterRTCViewFactory.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "RCFlutterRTCView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRTCViewFactory : NSObject<FlutterPlatformViewFactory>

+ (instancetype)sharedInstance;

- (void)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messager;


- (RCFlutterRTCView *)getRenderFlutterView:(int)viewId;

- (void)removeRenderVideoView:(int)viewId;

- (void)updateVideoView:(int)viewId size:(CGSize)size;

- (void)exchangeVideo:(int)viewId1 with:(int)viewId2;
@end

NS_ASSUME_NONNULL_END
