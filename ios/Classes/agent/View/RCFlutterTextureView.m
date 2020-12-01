//
//  RCFlutterTextureView.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/21.
//

#import "RCFlutterTextureView.h"

#import <CoreGraphics/CGImage.h>

#include "libyuv.h"

@implementation RCFlutterTextureView {
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
    CVPixelBufferRef pixelBufferRef = [_nativeView pixelBufferRef];
    if (pixelBufferRef != nil) {
        CFIndex count = CFGetRetainCount(pixelBufferRef);
        if (count < 3) CVBufferRetain(pixelBufferRef);
    }
    _nativeView.delegate = nil;
    _nativeView = nil;
    [_registry unregisterTexture:_textureId];
}

- (CVPixelBufferRef)copyPixelBuffer {
    return [_nativeView pixelBufferRef];
//    CVPixelBufferRef pixelBufferRef = [_nativeView pixelBufferRef];
//    if (pixelBufferRef != nil) {
//        CVBufferRetain(pixelBufferRef);
//    }
//    return pixelBufferRef;
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

- (int)I420Rotate:(const uint8_t*)src_y
     src_stride_y:(int)src_stride_y
            src_u:(const uint8_t*)src_u
     src_stride_u:(int)src_stride_u
            src_v:(const uint8_t*)src_v
     src_stride_v:(int)src_stride_v
            dst_y:(uint8_t*)dst_y
     dst_stride_y:(int)dst_stride_y
            dst_u:(uint8_t*)dst_u
     dst_stride_u:(int)dst_stride_u
            dst_v:(uint8_t*)dst_v
     dst_stride_v:(int)dst_stride_v
            width:(int)width
           height:(int)height
             mode:(int)mode {
    return I420Rotate(src_y, src_stride_y,
                      src_u, src_stride_u,
                      src_v, src_stride_v,
                      dst_y, dst_stride_y,
                      dst_u, dst_stride_u,
                      dst_v, dst_stride_v,
                      width, height,
                      mode);
}

- (int)I420ToARGB:(const uint8_t*)src_y
     src_stride_y:(int)src_stride_y
            src_u:(const uint8_t*)src_u
     src_stride_u:(int)src_stride_u
            src_v:(const uint8_t*)src_v
     src_stride_v:(int)src_stride_v
         dst_argb:(uint8_t*)dst_argb
  dst_stride_argb:(int)dst_stride_argb
            width:(int)width
           height:(int)height {
    return I420ToARGB(src_y, src_stride_y,
                      src_u, src_stride_u,
                      src_v, src_stride_v,
                      dst_argb, dst_stride_argb,
                      width, height);
}

- (void)changeSize:(int)width height:(int)height {
    if (_eventSink)
        _eventSink(@{
            @"event" : @"didTextureChangeVideoSize",
            @"id": @(_textureId),
            @"width": @(width),
            @"height": @(height),
                   });
}

- (void)changeRotation:(int)rotation {
    if (_eventSink)
        _eventSink(@{
            @"event" : @"didTextureChangeVideoSize",
            @"id": @(_textureId),
            @"rotation": @(rotation),
                   });
}

- (void)firstFrameRendered {
    _eventSink(@{
        @"event" : @"didFirstFrameRendered",
        @"id": @(_textureId),
               });
}

- (void)frameRendered {
    [_registry textureFrameAvailable:_textureId];
}

@end
