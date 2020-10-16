#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterUser.h"
#import "RCFlutterOutputStream.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^RongFlutterRTCOperationCallback)(BOOL isSuccess, RCRTCCode desc);

@interface RCFlutterLocalUser: RCFlutterUser

/*!
 用户发布的音视频流
 */
@property(nonatomic, copy, readonly) NSArray<RCFlutterOutputStream *> *localAVStreams;

@end

NS_ASSUME_NONNULL_END
