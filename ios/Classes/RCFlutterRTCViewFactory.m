//
//  RCFlutterRTCViewFactory.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import "RCFlutterRTCViewFactory.h"
#import "RCFlutterRTCView.h"
#import "RCFlutterRTCMethodKey.h"

@interface RCFlutterRTCViewFactory ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger>* messenger;
@property (nonatomic, strong) FlutterMethodChannel *channel;

@property (nonatomic, strong) NSMutableDictionary *viewDic;
@end

@implementation RCFlutterRTCViewFactory
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        self.viewDic = [[NSMutableDictionary alloc] init];
        
        self.messenger = messager;
        
        NSString* channelName = @"plugins.rongcloud.im/rtc_view_plugin";
        self.channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messager];
        __weak __typeof__(self) weakSelf = self;
        [self.channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
    }
    return self;
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
    if([RCFlutterRTCMethodKeyChangeViewColorTest isEqualToString:call.method]) {
//        [self changeViewColor];
    }
}

- (RCFlutterRTCView *)getView:(int64_t)viewId {
    return [self.viewDic objectForKey:@(viewId)];
}
@end
