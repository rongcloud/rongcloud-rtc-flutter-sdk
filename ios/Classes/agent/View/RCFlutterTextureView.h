//
//  RCFlutterTextureView.h
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/21.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterTextureView : NSObject <FlutterTexture, FlutterStreamHandler, RCRTCVideoTextureViewDelegate>

@property (nonatomic) int64_t textureId;
@property (nonatomic, weak) id<FlutterTextureRegistry> registry;
@property (nonatomic, strong) FlutterEventSink eventSink;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (RCRTCVideoTextureView *)nativeView;

- (void)dispose;

@end

NS_ASSUME_NONNULL_END
