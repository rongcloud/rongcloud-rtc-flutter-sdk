#import "RCFlutterAudioCapture.h"
#import "RCFlutterRtCBridgeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterAudioCapture (Apis) <RCFlutterAudioCaptureProtocol>

@property(nonatomic, strong) RCRTCMicOutputStream *rtcAudioCapture;
- (NSDictionary *)toDesc;
@end

NS_ASSUME_NONNULL_END
