#import "RCFlutterAVStream.h"
#import "RCFlutterEngine.h"

@interface RCFlutterAVStream ()

@property(nonatomic, copy) NSString *streamId;

@property(nonatomic, copy) NSString *userId;

@property(nonatomic, copy) NSString *tag;

@property(nonatomic, assign) RongFlutterMediaType streamType;

@property(nonatomic, assign) RongFlutterStreamState state;

@property(nonatomic, assign) BOOL isStreamMute;

@property(nonatomic, strong) RCRTCStream *rtcStream;

@end

@implementation RCFlutterAVStream

@synthesize streamId = _streamId;
@synthesize userId = _userId;
@synthesize tag = _tag;
@synthesize streamType = _streamType;
@synthesize state = _state;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:KMute]) {
        NSNumber *mute = (NSNumber *) (call.arguments);
        [self setMute:mute.boolValue];
        result([NSNumber numberWithInt:0]);
    }
}

- (void)registerStream:(RCRTCStream *)stream {
    _rtcStream = stream;
    if (!stream) {
        return;
    }
    self.streamType = (RongFlutterMediaType) stream.mediaType;
    self.state = (RongFlutterStreamState) stream.resourceState;
    self.userId = stream.userId;
    self.streamId = stream.streamId;
    self.tag = stream.tag;
    self.isStreamMute = stream.isMute;
}

/// 构建 stream channel ：
- (void)registerStreamChannel {
    if (self.streamId && self.userId) {
        //rong.flutter.rtclib/RCRTCVideoOutputStream-$streamId
        NSString *channelId = [NSString stringWithFormat:@"%@%@_%@", KMediaStream, self.streamId, @(self.streamType)];
        FlutterMethodChannel *streamChannel = [FlutterMethodChannel methodChannelWithName:channelId binaryMessenger:[[RCFlutterEngine sharedEngine].pluginRegister messenger]];
        [[RCFlutterEngine sharedEngine].pluginRegister addMethodCallDelegate:self channel:streamChannel];
    }
}

- (void)setMute:(BOOL)mute {
    if (self.rtcStream) {
        [self.rtcStream setIsMute:mute];
    }
}

- (NSDictionary *)toDesc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.rtcStream) {
        dic[@"tag"] = self.rtcStream.tag;
        dic[@"type"] = @(self.rtcStream.mediaType);
        dic[@"userId"] = self.rtcStream.userId;
        dic[@"streamId"] = self.rtcStream.streamId;
        [dic setObject:[NSNumber numberWithBool:self.rtcStream.resourceState] forKey:@"state"];
        [dic setObject:[NSNumber numberWithBool:self.rtcStream.isMute] forKey:@"mute"];

    }
    return dic;
}

- (BOOL)isEqualToStreamDic:(NSDictionary *)dic {
    NSString *streamId = dic[@"streamId"];
    NSNumber *type = dic[@"type"];
    NSString *tag = dic[@"tag"];
    if ([self.streamId isEqualToString:streamId] && [self.tag isEqualToString:tag] && self.streamType == type.integerValue) {
        return YES;
    }
    return NO;
}

- (BOOL)outputStream:(RCRTCOutputStream *)output isEqualToStreamDic:(NSDictionary *)dic {
    NSString *streamId = dic[@"streamId"];
    NSNumber *type = dic[@"type"];
    NSString *tag = dic[@"tag"];
    if ([output.streamId isEqualToString:streamId] && [output.tag isEqualToString:tag] && output.mediaType == type.integerValue) {
        return YES;
    }
    return NO;
}
@end
