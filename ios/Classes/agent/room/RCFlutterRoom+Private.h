#import "RCFlutterRoom.h"
#import "RCFlutterInputStream.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRoom (Private)

/**
 rtc room
 */
@property(nonatomic, strong) RCRTCRoom *rtcRoom;

/// 将 rtcRoom 序列化
- (NSMutableDictionary *)toDesc;

/// ios -> flutter channel
@property(nonatomic, strong) FlutterMethodChannel *methodChannel;

/// 根据userId获取user
/// @param userId 获取到的user
- (RCFlutterRemoteUser *)getRemoteUserFromUserId:(NSString *)userId;

/// 从当前 remoteUser 中取出指定 id 的 streams
/// @param streamIdDics 传进来的数据结构
- (NSArray<RCFlutterInputStream *> *)getFlutterRemoteInputStreamsFromRoom:(NSArray<NSDictionary *> *)streamDics;

/// 根据数据结构，获取RTC层Streams
/// @param streamIdDics 数据结构
- (NSArray<RCRTCInputStream *> *)getRTCRemoteInputStreamsFromRoom:(NSArray<NSDictionary *> *)streamics;

@end

NS_ASSUME_NONNULL_END
