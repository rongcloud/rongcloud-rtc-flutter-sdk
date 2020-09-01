#import "RCFlutterRemoteUser+Apis.h"
#import "RCFlutterRTCManager.h"
@implementation RCFlutterRemoteUser (Apis)
-(void)remoteUser:(RCRTCRemoteUser *)remoteUser switchToNormalStream:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion{
    [[RCFlutterRTCManager sharedRTCManager] remoteUser:remoteUser switchToNormalStream:streams completion:completion];
}
- (void)remoteUser:(RCRTCRemoteUser *)remoteUser switchToTinyStream:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion {
    [[RCFlutterRTCManager sharedRTCManager] remoteUser:remoteUser switchToTinyStream:streams completion:completion];
}


@end
