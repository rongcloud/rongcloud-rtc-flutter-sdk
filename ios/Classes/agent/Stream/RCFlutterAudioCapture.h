#import "RCFlutterOutputStream.h"
#import "RCFlutterMacros.h"
#import "RCFlutterRTCManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterAudioCapture: RCFlutterOutputStream

/// 单例
SingleInstanceH(AudioCapture);

/// 销毁资源
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
