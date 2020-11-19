//
//  RCFlutterAudioEffectManager.h
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/27.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterMacros.h"
#import "RCFlutterRTCManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterAudioEffectManager : NSObject<FlutterPlugin, RCRTCSoundEffectProtocol>

SingleInstanceH(AudioEffectManager);

@end

NS_ASSUME_NONNULL_END
