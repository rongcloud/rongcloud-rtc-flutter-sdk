#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterMacros.h"
@class RCFlutterAudioCapture;
@class RCFlutterVideoCapture;
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterEngine: NSObject <FlutterPlugin>

/// 单例
SingleInstanceH(Engine);

@property(nonatomic, strong) NSObject <FlutterPluginRegistrar> *pluginRegister;

@property (nonatomic , strong , readonly) RCFlutterVideoCapture *defaultVideoStream;

@property (nonatomic , strong , readonly) RCFlutterAudioCapture *defaultAudioStream;

@end

NS_ASSUME_NONNULL_END
