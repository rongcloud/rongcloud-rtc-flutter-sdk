#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "RCFlutterChannelKey.h"
#import "RCFlutterDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterAVStream: NSObject <FlutterPlugin>


/*!
 流ID，或者媒体ID
 */
@property(nonatomic, copy, readonly) NSString *streamId;

/*!
 发布人
 */
@property(nonatomic, copy, readonly) NSString *userId;

/*!
 唯一流扩展标识符
 */
@property(nonatomic, copy, readonly) NSString *tag;

/*!
 当前的流类型
 */
@property(nonatomic, assign, readonly) RongFlutterMediaType streamType;

/*!
 该资源开关
 */
@property(nonatomic, assign, readonly) RongFlutterStreamState state;


/*!
 是否被禁用
 */
@property(nonatomic, assign, readonly) BOOL isStreamMute;

/// 是否禁用
/// @param mute 是否禁用
- (void)setIsMute:(BOOL)mute;
- (NSDictionary *)toDesc;
@end

NS_ASSUME_NONNULL_END
