//
//  RCFlutterRTCView.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import "RCFlutterRTCView.h"

@interface RCFlutterRTCView ()
@property (nonatomic, strong) UIView *videoView;
@end

@implementation RCFlutterRTCView
- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        
//        NSDictionary *dic = args;
//        int viewId = [dic[@"viewId"] intValue];
        self.viewId = viewId;
        
        CGFloat width = 100;
        CGFloat height = 150;
        self.videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        self.videoView.backgroundColor = [UIColor redColor];
        
    }
    
    return self;
}

-(UIView *)view{
    return self.videoView;
}

- (void)changeViewColor{
    NSLog(@"iOS changeColor");
    NSArray *colors = @[[UIColor redColor],[UIColor greenColor],[UIColor yellowColor],[UIColor brownColor]];
    int index = arc4random()%colors.count;
    self.videoView.backgroundColor = colors[index];
}
@end
