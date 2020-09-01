#import "RCFlutterAVStream.h"
#import <RongRTCLib/RongRTCLib.h>
#import <Flutter/Flutter.h>
#import "RCFlutterChannelKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterAVStream (Private)

- (void)registerStream:(RCRTCStream *)stream;
- (void)registerStreamChannel;
- (BOOL)isEqualToStreamDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
