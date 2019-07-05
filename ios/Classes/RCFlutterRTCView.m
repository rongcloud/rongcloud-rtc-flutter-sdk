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
        NSString *userId = dic[@"userId"];
        
        self.videoView = [[UIView alloc] initWithFrame:frame];
        self.videoView.backgroundColor = [UIColor redColor];
        
        self.viewId = viewId;
        
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
