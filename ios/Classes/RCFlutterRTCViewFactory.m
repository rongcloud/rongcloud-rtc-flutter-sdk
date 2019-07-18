//
//  RCFlutterRTCViewFactory.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import "RCFlutterRTCViewFactory.h"
#import "RCFlutterRTCView.h"
#import "RCFlutterRTCMethodKey.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterRTCView.h"

@interface RCFlutterRTCViewFactory ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger>* messenger;
@property (nonatomic, strong) FlutterMethodChannel *channel;

@property (nonatomic, strong) NSMutableDictionary *viewDic;
@end

@implementation RCFlutterRTCViewFactory
+ (instancetype)sharedInstance {
    static RCFlutterRTCViewFactory *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (void)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self.viewDic = [[NSMutableDictionary alloc] init];
    
    self.messenger = messager;
    
    NSString* channelName = @"plugins.rongcloud.im/rtc_view_plugin";
    self.channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messager];
    __weak __typeof__(self) weakSelf = self;
    [self.channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
        [weakSelf onMethodCall:call result:result];
    }];
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    NSLog(@"%s",__func__);
    NSLog(@"ios 获取原生view 参数为 %@",args);
    RCFlutterRTCView *view = [[RCFlutterRTCView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:self.messenger];
    
    [self.viewDic setObject:view forKey:@(viewId)];
    
    return view;
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    
}

- (UIView *)getRenderVideoView:(int)viewId {
    NSLog(@"%s",__func__);
    RCFlutterRTCView *flutterView = [self.viewDic objectForKey:@(viewId)];
    return flutterView.view;
}

- (void)removeRenderVideoView:(int)viewId {
    NSLog(@"%s",__func__);
    RCFlutterRTCView *flutterView = [self.viewDic objectForKey:@(viewId)];
    if(flutterView) {
        [self.viewDic removeObjectForKey:@(viewId)];
        [flutterView.view removeFromSuperview];
    }
}

- (void)updateVideoView:(int)viewId size:(CGSize)size {
    NSLog(@"%s",__func__);
    RCFlutterRTCView *flutterView = [self.viewDic objectForKey:@(viewId)];
    if(flutterView && flutterView.view) {
        CGRect bounds = flutterView.view.bounds;
        bounds.size = size;
        flutterView.view.frame = bounds;
        for (UIView *subv in flutterView.view.subviews) {
            if([subv isKindOfClass:RongRTCLocalVideoView.class] ||
               [subv isKindOfClass:RongRTCRemoteVideoView.class]) {
                subv.frame = bounds;
            }
        }
    }
}
@end
