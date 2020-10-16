#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterUser: NSObject <FlutterPlugin>

@property(nonatomic, copy, readonly) NSString *userId;

@end

NS_ASSUME_NONNULL_END
