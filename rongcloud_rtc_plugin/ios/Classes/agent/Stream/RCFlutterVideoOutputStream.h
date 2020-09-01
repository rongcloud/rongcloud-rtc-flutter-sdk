#import "RCFlutterOutputStream.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterRenderView.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterVideoOutputStream : RCFlutterOutputStream

/// 渲染本地试图
/// @param localView 本地试图
- (void)renderLocalView:(RCFlutterRenderView *)localView;
@end

NS_ASSUME_NONNULL_END
