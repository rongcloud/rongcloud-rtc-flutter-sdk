#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterCDNConfig : NSObject

/**
 version
 */
@property (nonatomic, assign , readonly)int version;

/**
 cdn list
 */
@property (nonatomic, strong) NSMutableSet *cdnList;
@end

NS_ASSUME_NONNULL_END
