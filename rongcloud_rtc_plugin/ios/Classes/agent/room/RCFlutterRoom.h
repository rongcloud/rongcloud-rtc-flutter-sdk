#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>

#import "RCFlutterLocalUser.h"
#import "RCFlutterRemoteUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRoom: NSObject <FlutterPlugin, RCRTCRoomEventDelegate>

/*!
 房间ID
 */
@property(nonatomic, copy, readonly) NSString *roomId;

/*!
 当前用户
 */
@property(nonatomic, strong, readonly) RCFlutterLocalUser *localUser;

/*!
 参与用户
 */
@property(nonatomic, strong, readonly) NSArray<RCFlutterRemoteUser *> *remoteUsers;
@end

NS_ASSUME_NONNULL_END
