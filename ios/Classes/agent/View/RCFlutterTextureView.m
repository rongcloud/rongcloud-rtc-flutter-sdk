//
//  RCFlutterTextureView.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/21.
//

#import "RCFlutterTextureView.h"

#import <CoreGraphics/CGImage.h>

@implementation RCFlutterTextureView {
    int _rotation;
    bool _isFirstFrameRendered;
    RCRTCVideoTextureView* _nativeView;
    FlutterEventChannel* _eventChannel;
}

@synthesize textureId  = _textureId;
@synthesize registry = _registry;
@synthesize eventSink = _eventSink;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _rotation = 0;
        _isFirstFrameRendered = NO;
        _textureId  = [registry registerTexture:self];
        _nativeView = [[RCRTCVideoTextureView alloc] init];
        _nativeView.delegate = self;
        _registry = registry;
        _eventSink = nil;
        
        _eventChannel = [FlutterEventChannel eventChannelWithName:[NSString stringWithFormat:@"rong.flutter.rtclib/VideoTextureView:%lld", _textureId]
                                                  binaryMessenger:messenger];
        [_eventChannel setStreamHandler:self];
    }
    return self;
}

- (RCRTCVideoTextureView *)nativeView {
    return _nativeView;
}

- (void)dispose {
    _nativeView.delegate = nil;
    _nativeView = nil;
    _eventSink = nil;
    [_registry unregisterTexture:_textureId];
}

- (CVPixelBufferRef)copyPixelBuffer {
    CVPixelBufferRef pixelBufferRef = [_nativeView pixelBufferRef];
    if (pixelBufferRef != nil) {
        CVBufferRetain(pixelBufferRef);
    }
    return pixelBufferRef;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
    _eventSink = sink;
    return nil;
}

- (void)changeSize:(int)width height:(int)height {
    if (_eventSink)
        _eventSink(@{
            @"event" : @"didTextureChangeVideoSize",
            @"id": @(_textureId),
            @"rotation": @(_rotation),
            @"width": @(width),
            @"height": @(height),
                   });
}

- (void)changeRotation:(int)rotation {
    _rotation = rotation;
    if (_eventSink)
        _eventSink(@{
            @"event" : @"didTextureChangeVideoSize",
            @"id": @(_textureId),
            @"rotation": @(rotation),
                   });
}

- (void)firstFrameRendered {
    if (_eventSink)
        _eventSink(@{
            @"event" : @"didFirstFrameRendered",
            @"id": @(_textureId),
                   });
}

- (void)frameRendered {
    [_registry textureFrameAvailable:_textureId];
}

@end
