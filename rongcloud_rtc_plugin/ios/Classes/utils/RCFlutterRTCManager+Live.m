
#import "RCFlutterRTCManager+Live.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@interface RCFlutterRTCManager()

/**
 liveinfo
 */
@property (nonatomic , strong) RCRTCLiveInfo *liveInfo;
@end
@implementation RCFlutterRTCManager (Live)

- (void)subscribeLiveStream:(NSString *)url streamType:(RCRTCAVStreamType)streamType completion:(RCFlutterLiveCallback)completion {
    [[RCRTCEngine sharedInstance] subscribeLiveStream:url streamType:streamType completion:completion];
}
- (void)unsubscribeLiveStream:(NSString *)url completion:(void (^)(BOOL, RCRTCCode))completion {
    [[RCRTCEngine sharedInstance] unsubscribeLiveStream:url completion:completion];
}

- (void)publishDefaultLiveStreams:(RCFlutterLiveOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser publishDefaultLiveStream:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        self.liveInfo = liveInfo;
    }];
}
- (void)publishLiveStream:(RCRTCOutputStream *)stream completion:(RCFlutterLiveOperationCallback)completion {
    [[RCRTCEngine sharedInstance].currentRoom.localUser publishLiveStream:stream completion:completion];
}
- (void)setMixStreamConfig:(RCRTCMixConfig *)config completion:(void (^)(BOOL, RCRTCCode))completion {
    [self.liveInfo setMixStreamConfig:config completion:completion];
}
- (void)addPublishStreamUrl:(NSString *)url completion:(void (^)(BOOL, RCRTCCode, NSArray * _Nonnull))completion {
    [self.liveInfo addPublishStreamUrl:url completion:completion];
}
- (void)removePublishStreamUrl:(NSString *)url completion:(void (^)(BOOL, RCRTCCode, NSArray * _Nonnull))completion {
    [self.liveInfo removePublishStreamUrl:url completion:completion];
}
@end

#pragma clang diagnostic pop
