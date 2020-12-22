#import "RCFlutterEngine.h"
@class RCFlutterRoom;
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterEngine (Private)

@property (nonatomic, strong) RCFlutterRoom *room;

@property (nonatomic, strong) NSMutableDictionary *createdOutputStreams;

@end

NS_ASSUME_NONNULL_END
