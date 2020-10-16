//
//  RCFlutterLiveInfo.h
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/9/27.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterLiveInfo : NSObject<FlutterPlugin>

@property(nonatomic, copy, readonly) NSString *roomId;

@property(nonatomic, copy, readonly) NSString *liveUrl;

@property(nonatomic, copy, readonly) NSString *userId;

+ (RCFlutterLiveInfo *)flutterLiveInfoWithLiveInfo:(RCRTCLiveInfo *)liveInfo roomId:(NSString *)roomId userId:(NSString *)userId;

- (NSDictionary *)toDesc;

@end

NS_ASSUME_NONNULL_END
