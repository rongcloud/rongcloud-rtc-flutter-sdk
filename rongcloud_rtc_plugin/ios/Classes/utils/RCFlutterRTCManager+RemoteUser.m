#import "RCFlutterRTCManager+RemoteUser.h"

@implementation RCFlutterRTCManager (RemoteUser)
- (void)remoteUser:(RCRTCRemoteUser *)remoteUser switchToTinyStream:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion {
    [remoteUser switchToTinyStream:streams completion:completion];
}

- (void)remoteUser:(RCRTCRemoteUser *)remoteUser switchToNormalStream:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion {
    [remoteUser switchToNormalStream:streams completion:completion];
}
@end
