#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <RongRTCLib/RongRTCLib.h>

typedef NS_ENUM(NSUInteger, RongFlutterRenderViewType) {
    // local view
    RongFlutterRenderViewTypeLocalView,
    // remoteView
    RongFlutterRenderViewTypeRemoteView,
};

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRenderView: NSObject<FlutterPlatformView>

/**
 preview
 */
@property(nonatomic, strong, readonly) RCRTCVideoPreviewView *previewView;

- (NSObject <FlutterPlatformView> *)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject <FlutterBinaryMessenger> *)messager viewType:(RongFlutterRenderViewType)viewType;

@end

NS_ASSUME_NONNULL_END
