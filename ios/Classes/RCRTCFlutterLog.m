//
//  RCRTCFlutterLog.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/22.
//

#import "RCRTCFlutterLog.h"

@implementation RCRTCFlutterLog
+ (void)i:(NSString *)content {
    NSLog(@"[RC-Flutter-RTC] iOS %@",content);
}
+ (void)e:(NSString *)content {
    NSLog(@"[RC-Flutter-RTC] iOS error %@",content);
}
@end
