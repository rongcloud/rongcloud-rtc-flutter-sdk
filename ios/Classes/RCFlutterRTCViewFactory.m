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
    
    [self.viewDic setObject:view forKey:view.userId];
    
    return view;
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    if([RCFlutterRTCMethodKeyChangeViewColorTest isEqualToString:call.method]) {
//        [self changeViewColor];
    }
}

- (UIView *)getRenderVideoView:(NSString *)userId {
    NSLog(@"%s",__func__);
    UIView *view = nil;
    if(!userId) {
        return view;
    }
    RCFlutterRTCView *flutterView = [self.viewDic objectForKey:userId];
    return flutterView.view;
}

@end
