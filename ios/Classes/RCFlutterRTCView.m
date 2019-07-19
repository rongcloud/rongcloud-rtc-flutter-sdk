//
//  RCFlutterRTCView.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import "RCFlutterRTCView.h"

@interface RCFlutterRTCView ()
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) int64_t viewId;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, strong) RongRTCVideoPreviewView *renderView;
@end

@implementation RCFlutterRTCView
- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        
        NSDictionary *dic = args;
        self.width = [dic[@"width"] intValue];
        self.height = [dic[@"height"] intValue];
        self.userId = dic[@"userId"];
        self.viewId = viewId;
        self.videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.videoView.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

-(UIView *)view{
    return self.videoView;
}

- (void)bindRenderView:(RongRTCVideoPreviewView *)renderView {
    self.renderView = renderView;
    [self.videoView addSubview:renderView];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.renderView.frame = CGRectMake(0, 0, self.width, self.height);
    [CATransaction commit];
}
- (void)unbindRenderView {
    for(UIView *subv in self.videoView.subviews) {
        if([subv isKindOfClass:RongRTCRemoteVideoView.class] ||
           [subv isKindOfClass:RongRTCLocalVideoView.class]) {
            [subv removeFromSuperview];
        }
    }
}
- (void)updateUserId:(NSString *)userId {
    self.userId = userId;
}

- (RongRTCVideoPreviewView *)renderView {
    if(!_renderView) {
        if([self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
            _renderView = [[RongRTCLocalVideoView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        }else {
            _renderView = [[RongRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        }
        [self.videoView addSubview:_renderView];
    }
    return _renderView;
}
@end
