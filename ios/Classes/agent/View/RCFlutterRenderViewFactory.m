#import "RCFlutterRenderViewFactory.h"

@interface RCFlutterRenderViewFactory () {
    NSObject <FlutterBinaryMessenger> *_messager;
    NSMutableDictionary *_localViewMap;
    NSMutableDictionary *_remoteViewMap;
}

@end

@implementation RCFlutterRenderViewFactory

#pragma mark - instance
SingleInstanceM(ViewFactory);
- (instancetype)init {
    if (self = [super init]) {
        _localViewMap = [NSMutableDictionary dictionary];
        _remoteViewMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)withMessenger:(NSObject <FlutterBinaryMessenger> *)messenger {
    _messager = messenger;
}

- (NSObject <FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    NSNumber *viewNum = @(0);
    if (args != nil) {
        viewNum = ((NSDictionary *)args)[@"tag"];
    }
    RongFlutterRenderViewType viewType = (RongFlutterRenderViewType) viewNum.intValue;
    RCFlutterRenderView *iosView = [[RCFlutterRenderView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args messenger:_messager viewType:viewType];
    switch (viewType) {
        case RongFlutterRenderViewTypeLocalView: {
            NSString *localViewId = [NSString stringWithFormat:@"%lld", viewId];
            [_localViewMap setValue:iosView forKey:localViewId];
        }
            break;
        case RongFlutterRenderViewTypeRemoteView: {
            NSString *remoteViewId = [NSString stringWithFormat:@"%lld", viewId];
            [_remoteViewMap setValue:iosView forKey:remoteViewId];
        }
            break;
        default:
            break;
    }
    return iosView;
}

- (RCFlutterRenderView *)getViewWithId:(int)viewId andType:(RongFlutterRenderViewType)type {
    NSString *key = [NSString stringWithFormat:@"%d", viewId];
    if (type == RongFlutterRenderViewTypeLocalView) {
        return _localViewMap[key];;
    } else if (type == RongFlutterRenderViewTypeRemoteView) {
        return _remoteViewMap[key];;
    }
    return nil;
}

- (void)releaseVideoView:(int)viewId {
    NSString *key = [NSString stringWithFormat:@"%d", viewId];
    for (NSString *_key in _localViewMap.allKeys) {
        if ([_key isEqualToString:key]) {
            [_localViewMap removeObjectForKey:_key];
            break;
        }
    }
    for (NSString *_key in _remoteViewMap.allKeys) {
        if ([_key isEqualToString:key]) {
            [_remoteViewMap removeObjectForKey:_key];
            break;
        }
    }
}

- (void)destroy {
    [self->_localViewMap removeAllObjects];
    
    [self->_remoteViewMap removeAllObjects];
}

@end
