#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterUser.h"
#import "RCFlutterOutputStream.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^RongFlutterRTCOperationCallback)(BOOL isSuccess, RCRTCCode desc);

@interface RCFlutterLocalUser: RCFlutterUser

@end

NS_ASSUME_NONNULL_END
