#import "RCFlutterOutputStream.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCFlutterAVStream+Private.h"

@interface RCFlutterOutputStream ()

@property(nonatomic, strong) RCRTCOutputStream *rtcOutputStream;

@property(nonatomic, copy) NSString *streamId;

@property(nonatomic, copy) NSString *userId;

@property(nonatomic, copy) NSString *tag;

@property(nonatomic, assign) RongFlutterMediaType streamType;

@property(nonatomic, assign) RongFlutterStreamState state;
@end

@implementation RCFlutterOutputStream

@synthesize streamId = _streamId;
@synthesize userId = _userId;
@synthesize tag = _tag;
@synthesize streamType = _streamType;
@synthesize state = _state;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@", call.method);
    if ([call.method isEqualToString:KMute]){
        [super handleMethodCall:call result:result];
    }
}

- (void)rtcOutputStream:(RCRTCOutputStream *)rtcOutputStream {
    _rtcOutputStream = rtcOutputStream;
    [self registerStream:self.rtcOutputStream];
}

- (void)dealloc {
    RCLogI(@"RCFlutterOutputStream dealloc");
    self.rtcOutputStream = nil;
}

@end
