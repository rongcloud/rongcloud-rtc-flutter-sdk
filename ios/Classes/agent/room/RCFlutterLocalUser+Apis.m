#import "RCFlutterLocalUser+Apis.h"
#import "RCFlutterRTCManager.h"
#import "RCFlutterUser+Private.h"

@implementation RCFlutterLocalUser (Apis)

#pragma mark - api

- (void)publishRTCDefaultLiveStreams:(RCFlutterLiveOperationCallback)completion {
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

- (void)publishRTCLiveStream:(RCRTCOutputStream *)stream
                  completion:(RCFlutterLiveOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] publishLiveStream:stream
                                                       completion:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
            completion(isSuccess, desc, liveInfo);
        }];
    } else {
        RCLogE(@"publishRTCDefaultLiveStream ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1, NULL);
        }
    }
}

- (void)publishRTCDefaultAVStreams:(RongFlutterOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] publishRTCDefaultAVStreams:^(BOOL isSuccess, RCRTCCode desc) {
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

- (void)unpublishDefaultStreams:(RongFlutterOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] unpublishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
            self.rtcUser = [RCRTCEngine sharedInstance].currentRoom.localUser;
            completion(isSuccess,desc);
        }];
    } else {
        RCLogE(@"unpublishDefaultStreams ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}

- (void)publishStreams:(NSArray<RCRTCOutputStream *> *)streams completion:(RongFlutterOperationCallback)completion {
    [[RCFlutterRTCManager sharedRTCManager] publishStreams:streams completion:^(BOOL isSuccess, RCRTCCode desc) {
        self.rtcUser = [RCRTCEngine sharedInstance].room.localUser;
        completion(isSuccess,desc);
    }];
}

- (void)unpublishStreams:(NSArray<RCRTCOutputStream *> *)streams completion:(RongFlutterOperationCallback)completion {
    [[RCFlutterRTCManager sharedRTCManager] unpublishStreams:streams completion:^(BOOL isSuccess, RCRTCCode desc) {
        self.rtcUser = [RCRTCEngine sharedInstance].room.localUser;
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

- (void)unsubscribeStreams:(NSArray<RCRTCInputStream *> *)streams completion:(RCRTCOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] unsubscribeStreams:streams completion:completion];
    } else {
        RCLogE(@"unsubscribeStreams ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}

- (void)setAttributeValue:(NSString *)attributeValue
                   forKey:(NSString *)key
                  message:(RCMessageContent *)message
               completion:(RCRTCOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] setAttributeValue:attributeValue
                                                           forKey:key
                                                          message:message
                                                       completion:completion];
    } else {
        RCLogE(@"setAttributeValue ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}

- (void)deleteAttributes:(NSArray<NSString *> *)attributeKeys
                 message:(RCMessageContent *)message
              completion:(RCRTCOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] deleteAttributes:attributeKeys
                                                         message:message
                                                      completion:completion];
    } else {
        RCLogE(@"deleteAttributes ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1);
        }
    }
}

- (void)getAttributes:(NSArray<NSString *> *)attributeKeys
           completion:(RCRTCAttributeOperationCallback)completion {
    if (self.rtcUser) {
        [[RCFlutterRTCManager sharedRTCManager] getAttributes:attributeKeys
                                                   completion:completion];
    } else {
        RCLogE(@"getAttributes ios RCFlutterLocalUser dont has rtclocaluser");
        if (completion) {
            completion(NO, -1, nil);
        }
    }
}

@end
