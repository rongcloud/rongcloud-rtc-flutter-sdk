#import "RCFlutterRTCManager+LocalUser.h"

@implementation RCFlutterRTCManager (LocalUser)

- (void)publishRTCDefaultAVStream:(RongFlutterOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser publishDefaultStream:completion];
}
- (void)unpublishDefaultStream:(RongFlutterOperationCallback)completion{
    [[RCRTCEngine sharedInstance].currentRoom.localUser unpublishDefaultStream:completion];
}
- (void)publishStream:(RCRTCOutputStream *)stream completion:(RongFlutterOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser publishStream:stream completion:completion];
}
- (void)unpublishStream:(RCRTCOutputStream *)stream completion:(RongFlutterOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser unpublishStream:stream completion:completion];
}
- (void)subscribeStreams:(nullable NSArray<RCRTCInputStream *> *)avStreams
             tinyStreams:(nullable NSArray<RCRTCInputStream *> *)tinyStreams
              completion:(nullable RCRTCOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser subscribeStream:avStreams tinyStreams:tinyStreams completion:completion];
}
- (void)unsubscribeStream:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser unsubscribeStream:streams completion:completion];
}

@end
