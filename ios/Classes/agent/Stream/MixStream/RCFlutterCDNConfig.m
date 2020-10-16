#import "RCFlutterCDNConfig.h"
@interface RCFlutterCDNConfig()

/**
 version
 */
@property (nonatomic, assign) int version;

@end

@implementation RCFlutterCDNConfig
- (instancetype)init {
    if (self = [super init]) {
        self.version = 1;
        self.cdnList = [NSMutableSet new];
    }
    return self;
}

@end
