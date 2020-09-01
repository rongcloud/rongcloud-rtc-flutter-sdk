#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterCustomLayout : NSObject
/*!
 要混流的流，必须为视频流
 */
@property (nonatomic, strong) RCRTCStream *videoStream;

/*!
 混流图层坐标的 y 值
 */
@property (nonatomic, assign) int y;

/*!
 混流图层坐标的 x 值
 */
@property (nonatomic, assign) int x;

/*!
 视频流的宽
 */
@property (nonatomic, assign) int width;

/*!
 视频流的高
 */
@property (nonatomic, assign) int height;
@end

NS_ASSUME_NONNULL_END
