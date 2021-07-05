#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>

#import "RCFlutterLocalUser.h"
#import "RCFlutterRemoteUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRoom: NSObject <FlutterPlugin, RCRTCRoomEventDelegate>

///*!
// 房间ID
// */
//@property(nonatomic, copy) NSString *roomId;
//
///*!
// 当前用户
// */
//@property(nonatomic, strong) RCFlutterLocalUser *localUser;
//
///*!
// 参与用户
// */
//@property(nonatomic, strong) NSMutableArray<RCFlutterRemoteUser *> *remoteUsers;

- (void) addRemoteUser:(RCFlutterRemoteUser *) user;

@end

NS_ASSUME_NONNULL_END
