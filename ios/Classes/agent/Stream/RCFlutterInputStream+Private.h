#import "RCFlutterInputStream.h"
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterInputStream (Private)

@property(nonatomic, strong) RCRTCInputStream *rtcInputStream;

@end

NS_ASSUME_NONNULL_END
