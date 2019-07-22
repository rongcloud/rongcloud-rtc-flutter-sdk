//
//  RCRTCFlutterLog.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define RCRTCLog RCRTCFlutterLog

@interface RCRTCFlutterLog : NSObject
+ (void)i:(NSString *)content;
+ (void)e:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
