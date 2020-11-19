//
//  RCFlutterAudioMixer.h
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterMacros.h"
#import "RCFlutterRTCManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterAudioMixer : NSObject<FlutterPlugin, RCRTCAudioMixerAudioPlayDelegate>

SingleInstanceH(AudioMixer);

@end

NS_ASSUME_NONNULL_END
