#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterMacros.h"
@class RCFlutterAudioCapture;
@class RCFlutterVideoCapture;
@class RCFlutterAudioEffectManager;
NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterEngine: NSObject <FlutterPlugin>

/// 单例
SingleInstanceH(Engine);

@property(nonatomic, strong) NSObject <FlutterPluginRegistrar> *pluginRegister;

@property(nonatomic, strong) FlutterMethodChannel *channel;

@property(nonatomic , strong , readonly) RCFlutterVideoCapture *defaultVideoStream;

@property(nonatomic , strong , readonly) RCFlutterAudioCapture *defaultAudioStream;

@property(nonatomic , strong , readonly) RCFlutterAudioEffectManager *audioEffectManager;

+ (NSString *) getVersion;

@end

NS_ASSUME_NONNULL_END
