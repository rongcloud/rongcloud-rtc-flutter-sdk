#import "RCFlutterRemoteUser.h"
#import <RongRTCLib/RongRTCLib.h>
@class RCFlutterInputStream;
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRemoteUser (Private)

- (NSDictionary *)toDesc;

/// 从当前 remoteUser 中取出指定 id 的 streams
/// @param streamDics 传进来的数据结构
- (NSArray<RCFlutterInputStream *> *)getFlutterRemoteInputStreamsFromRemoteUser:(NSArray<NSDictionary *> *)streamDics;

/// 根据数据结构，从 remoteUser 获取RTC层Streams
/// @param streamDics 数据结构
- (NSArray<RCRTCInputStream *> *)getRTCRemoteInputStreamsFromRemoteUser:(NSArray<NSDictionary *> *)streamDics;

- (void)addStream:(RCFlutterInputStream *)stream;
- (void)removeStream:(RCFlutterInputStream *)stream;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
