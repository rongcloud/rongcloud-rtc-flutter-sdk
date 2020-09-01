#import <Foundation/Foundation.h>
#import "RCFlutterCustomLayout.h"
typedef NS_ENUM(NSInteger , RCFlutterMixLayoutMode) {
    /*!
     自定义布局
     */
    RCFlutterMixLayoutModeCustom = 1 ,
    /*!
     悬浮布局
    */
    RCFlutterMixLayoutModeSuspension = 2 ,
    /*!
     自适应布局
    */
    RCFlutterMixLayoutModeAdaptive = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterMixConfig : NSObject
/*!
 合流服务版本，不支持修改。
 */
@property (nonatomic, assign,readonly) int version;

/*!
 合流模式，1： 自定义布局    2：悬浮布局  3：自适应布局

 */
@property (nonatomic, assign) RCFlutterMixLayoutMode layoutMode;

/*!
 自定义布局列表
 */
@property (nonatomic, strong) NSMutableArray <RCFlutterCustomLayout *> *customLayouts;
@end

NS_ASSUME_NONNULL_END
