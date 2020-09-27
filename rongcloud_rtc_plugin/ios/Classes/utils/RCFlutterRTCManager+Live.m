
#import "RCFlutterRTCManager+Live.h"

@implementation RCFlutterRTCManager (Live)

- (void)subscribeLiveStream:(NSString *)url streamType:(RCRTCAVStreamType)streamType completion:(RCFlutterLiveCallback)completion {
    [[RCRTCEngine sharedInstance] subscribeLiveStream:url streamType:streamType completion:completion];
}

- (void)unsubscribeLiveStream:(NSString *)url completion:(void (^)(BOOL, RCRTCCode))completion {
    [[RCRTCEngine sharedInstance] unsubscribeLiveStream:url completion:completion];
}

- (void)publishDefaultLiveStreams:(RCFlutterLiveOperationCallback)completion {
    [[[[RCRTCEngine sharedInstance] currentRoom] localUser] publishDefaultLiveStream:completion];
}

- (void)publishLiveStream:(RCRTCOutputStream *)stream completion:(RCFlutterLiveOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser publishLiveStream:stream completion:completion];
}
@end

#pragma clang diagnostic pop
