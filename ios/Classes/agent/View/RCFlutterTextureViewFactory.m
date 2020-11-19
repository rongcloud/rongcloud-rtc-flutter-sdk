//
//  RCFlutterTextureViewFactory.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/21.
//

#import "RCFlutterTextureViewFactory.h"

@implementation RCFlutterTextureViewFactory {
    id<FlutterTextureRegistry> _registry;
    NSObject<FlutterBinaryMessenger> *_messenger;
    NSMutableDictionary *_views;
}

SingleInstanceM(ViewFactory);

- (instancetype)init {
    if (self = [super init]) {
        _views = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)withTextureRegistry:(id<FlutterTextureRegistry>)registry
                 messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    _registry = registry;
    _messenger = messenger;
}

-(RCFlutterTextureView *)createTextureView {
    RCFlutterTextureView *view = [[RCFlutterTextureView alloc] initWithTextureRegistry:_registry messenger:_messenger];
    NSString *textureId = [NSString stringWithFormat:@"%lld", view.textureId];
    [_views setValue:view forKey:textureId];
    return view;
}

-(RCFlutterTextureView *)get:(int64_t)textureId {
    NSString *key = [NSString stringWithFormat:@"%lld", textureId];
    return _views[key];
}

-(void)remove:(int64_t)textureId {
    NSString *key = [NSString stringWithFormat:@"%lld", textureId];
    RCFlutterTextureView *view = _views[key];
    if (view != nil) {
        [view dispose];
        [_views removeObjectForKey:key];
    }
}

-(void)destroy {
    [_views removeAllObjects];
}

@end
