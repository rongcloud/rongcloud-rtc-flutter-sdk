//
//  RCFlutterRTCView.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import "RCFlutterRTCView.h"

@interface RCFlutterRTCView ()
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, assign) int64_t viewId;
@end

@implementation RCFlutterRTCView
- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        
        NSDictionary *dic = args;
        int width = [dic[@"width"] intValue];
        int height = [dic[@"height"] intValue];
        self.viewId = viewId;
        self.videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        self.videoView.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

-(UIView *)view{
    return self.videoView;
}
@end
