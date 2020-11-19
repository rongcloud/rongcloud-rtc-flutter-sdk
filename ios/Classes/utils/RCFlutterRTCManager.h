#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterMacros.h"
#import "RCFlutterRTCProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRTCManager: NSObject <RCFlutterRTCProtocol>

SingleInstanceH(RTCManager);

@end

NS_ASSUME_NONNULL_END
