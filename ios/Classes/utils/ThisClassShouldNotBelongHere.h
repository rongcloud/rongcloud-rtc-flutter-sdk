//
//  ThisClassShouldNotBelongHere.h
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/28.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThisClassShouldNotBelongHere : NSObject

+ (RCMessageContent *)string2MessageContent:(NSString *)object content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
