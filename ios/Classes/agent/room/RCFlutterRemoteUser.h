#import <Foundation/Foundation.h>
#import "RCFlutterUser.h"
#import "RCFlutterInputStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRemoteUser: RCFlutterUser

/*!
 用户发布的音视频流
 */
@property(nonatomic, strong, readonly) NSMutableArray<RCFlutterInputStream *> *remoteAVStreams;

@end

NS_ASSUME_NONNULL_END
