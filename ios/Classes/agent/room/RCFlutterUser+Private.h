#import "RCFlutterUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterUser (Private)

@property(nonatomic, strong) RCRTCUser *rtcUser;
- (void)configUserWithID:(NSString *)userId;
- (void)registerChannel;
@end

NS_ASSUME_NONNULL_END
