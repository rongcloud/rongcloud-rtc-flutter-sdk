#import "RCFlutterVideoCapture.h"
#import "RCFlutterRtCBridgeProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/// 此类掌管 video capture 相关 api
@interface RCFlutterVideoCapture (Apis)<RCFlutterVideoCaptureProtocol>
/**
 私有属性，关联 RTCLib 的 videoCapture
 */
@property(nonatomic, strong) RCRTCCameraOutputStream *rtcVideoCapture;

- (NSDictionary *)toDesc;
@end

NS_ASSUME_NONNULL_END
