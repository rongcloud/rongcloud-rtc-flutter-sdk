#import "RCFlutterLocalUser+Apis.h"
#import "RCFlutterRTCManager.h"
#import "RCFlutterUser+Private.h"

@implementation RCFlutterLocalUser (Apis)

#pragma mark - api

- (void)publishRTCDefaultLiveStream:(RCFlutterLiveOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
            completion(isSuccess, desc, liveInfo);
        }];
    } else {
        RCLogE(@"publishRTCDefaultLiveStream ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1, NULL);
        }
    }
}

- (void)publishRTCDefaultAVStream:(RongFlutterOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] publishRTCDefaultAVStream:^(BOOL isSuccess, RCRTCCode desc) {
            self.rtcUser = [RCRTCEngine sharedInstance].currentRoom.localUser;
            completion(isSuccess,desc);
        }];
    } else {
        RCLogE(@"publishRTCDefaultAVStream ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}
- (void)unpublishDefaultStream:(RongFlutterOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] unpublishDefaultStream:^(BOOL isSuccess, RCRTCCode desc) {
            self.rtcUser = [RCRTCEngine sharedInstance].currentRoom.localUser;
            completion(isSuccess,desc);
        }];
    } else {
        RCLogE(@"unpublishDefaultStream ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}
- (void)publishStream:(RCRTCOutputStream *)stream completion:(RongFlutterOperationCallback)completion {
    [[RCFlutterRTCManager sharedRTCManager] publishStream:stream completion:^(BOOL isSuccess, RCRTCCode desc) {
        self.rtcUser = [RCRTCEngine sharedInstance].currentRoom.localUser;
        completion(isSuccess,desc);
    }];
}
- (void)unpublishStream:(RCRTCOutputStream *)stream completion:(RongFlutterOperationCallback)completion {
    [[RCFlutterRTCManager sharedRTCManager] unpublishStream:stream completion:^(BOOL isSuccess, RCRTCCode desc) {
        self.rtcUser = [RCRTCEngine sharedInstance].currentRoom.localUser;
        completion(isSuccess,desc);
    }];
}

- (void)subscribeStreams:(NSArray<RCRTCInputStream *> *)avStreams tinyStreams:(NSArray<RCRTCInputStream *> *)tinyStreams completion:(RCRTCOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] subscribeStreams:avStreams tinyStreams:tinyStreams completion:completion];
    } else {
        RCLogE(@"subscribeStreams ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}

- (void)unsubscribeStream:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] unsubscribeStream:streams completion:completion];
    } else {
        RCLogE(@"unsubscribeStream ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}
@end
