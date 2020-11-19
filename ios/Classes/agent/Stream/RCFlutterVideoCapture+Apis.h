#import "RCFlutterVideoCapture.h"
#import "RCFlutterRTCBridgeProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/// 此类掌管 video capture 相关 api
@interface RCFlutterVideoCapture (Apis)<RCFlutterVideoCaptureProtocol>

- (NSDictionary *)toDesc;

@end

NS_ASSUME_NONNULL_END
