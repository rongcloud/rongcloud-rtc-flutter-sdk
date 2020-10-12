#import "RCFlutterRenderView.h"

@interface RCFlutterRenderView () {
    RCRTCVideoPreviewView *_iOSView;
}

@end

@implementation RCFlutterRenderView

- (NSObject <FlutterPlatformView> *)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(nonnull NSObject <FlutterBinaryMessenger> *)messager viewType:(RongFlutterRenderViewType)viewType {
    if (self = [super init]) {
        switch (viewType) {
            case RongFlutterRenderViewTypeLocalView:
                [self createLocalView:frame viewIdentifier:viewId arguments:args];
                break;
            case RongFlutterRenderViewTypeRemoteView:
                [self createRemoteView:frame viewIdentifier:viewId arguments:args];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)createLocalView:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    RCRTCLocalVideoView *localView = [[RCRTCLocalVideoView alloc] initWithFrame:frame];
    [localView setFillMode: RCRTCVideoFillModeAspectFill];
    _iOSView = localView;
}

- (void)createRemoteView:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    RCRTCRemoteVideoView *remoteView = [[RCRTCRemoteVideoView alloc] initWithFrame:frame];
    [remoteView setFillMode:RCRTCVideoFillModeAspectFill];
    _iOSView = remoteView;
}

- (UIView *)view {
    return _iOSView;
}

- (RCRTCVideoPreviewView *)previewView {
    return _iOSView;
}

@end
