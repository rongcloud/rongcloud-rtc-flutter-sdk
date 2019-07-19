//
//  RCFlutterRTCViewFactory.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import "RCFlutterRTCViewFactory.h"
#import "RCFlutterRTCWrapper.h"
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
    
//    NSString* channelName = @"plugins.rongcloud.im/rtc_view_plugin";
//    self.channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messager];
//    __weak __typeof__(self) weakSelf = self;
//    [self.channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
//        [weakSelf onMethodCall:call result:result];
//    }];
}

//-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
//    
//}


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

- (RCFlutterRTCView *)getRenderFlutterView:(int)viewId {
    NSLog(@"%s",__func__);
    RCFlutterRTCView *view = [self.viewDic objectForKey:@(viewId)];
    return view;
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

- (void)exchangeVideo:(int)viewId1 with:(int)viewId2 {
    //切换渲染的时候，将 两个 flutter view 的 userId 和 renderView 交换，renderView 需要更改 size
    RCFlutterRTCView *flutterView1 = [self.viewDic objectForKey:@(viewId1)];
    RCFlutterRTCView *flutterView2 = [self.viewDic objectForKey:@(viewId2)];
    
    //交换 userid
    NSString *tmpUserId= flutterView1.userId;
    [flutterView1 updateUserId:flutterView2.userId];
    [flutterView2 updateUserId:tmpUserId];
    
    //交换 renderView
    RongRTCVideoPreviewView *renderView1 = flutterView1.renderView;
    RongRTCVideoPreviewView *renderView2 = flutterView2.renderView;
    
    [flutterView1 unbindRenderView];
    [flutterView2 unbindRenderView];
    
    [flutterView1 bindRenderView:renderView2];
    [flutterView2 bindRenderView:renderView1];
    
}

- (void)removeRenderView:(UIView *)videoHolderView {
    for(UIView *subv in videoHolderView.subviews) {
        if([subv isKindOfClass:RongRTCRemoteVideoView.class] ||
           [subv isKindOfClass:RongRTCLocalVideoView.class]) {
            [subv removeFromSuperview];
        }
    }
}

- (BOOL)isCurrentUser:(NSString *)userId {
    return [userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
}
@end
