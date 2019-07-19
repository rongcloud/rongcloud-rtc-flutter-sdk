//
//  RCFlutterRTCConfig.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/19.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRTCConfig : NSObject

+ (instancetype)sharedConfig;

- (void)updateParam:(NSDictionary *)dic;

@property(nonatomic, strong, readonly) RongRTCVideoCaptureParam *captureParam;
@end

NS_ASSUME_NONNULL_END
