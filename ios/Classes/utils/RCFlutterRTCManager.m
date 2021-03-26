#import "RCFlutterRTCManager.h"

@implementation RCFlutterRTCManager

#pragma mark - instance
SingleInstanceM(RTCManager);

- (void)joinRTCRoom:(NSString *)roomId completion:(void (^)(RCRTCRoom *_Nullable, RCRTCCode code))completion {
    [[RCRTCEngine sharedInstance] joinRoom:roomId completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        if (completion) {
            completion(room, code);
        }
    }];
}

- (void)joinRTCRoom:(NSString *)roomId config:(RCRTCRoomConfig *)config completion:(void (^)(RCRTCRoom * _Nullable, RCRTCCode))completion {
    [[RCRTCEngine sharedInstance] joinRoom:roomId config:config completion:completion];
}

- (void)leaveRTCRoom:(void (^)(BOOL, RCRTCCode code))completion {
    [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (completion) {
            completion(isSuccess, code);
        }
    }];
}

- (void)useSpeaker:(BOOL)speaker{
    [[RCRTCEngine sharedInstance] useSpeaker:speaker];
}

@end
