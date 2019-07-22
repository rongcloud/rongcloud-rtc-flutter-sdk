//
//  RCFlutterRTCWrapper.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/4.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
@class RCFlutterRTCView;

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRTCWrapper : NSObject
+ (instancetype)sharedInstance;
- (void)saveMethodChannel:(FlutterMethodChannel *)channel;
- (void)rtcHandleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
