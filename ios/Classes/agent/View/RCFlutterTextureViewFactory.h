//
//  RCFlutterTextureViewFactory.h
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/21.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "RCFlutterTextureView.h"
#import "RCFlutterMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterTextureViewFactory : NSObject

SingleInstanceH(ViewFactory);

-(void)withTextureRegistry:(id<FlutterTextureRegistry>)registry
                 messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(RCFlutterTextureView *)createTextureView;

-(RCFlutterTextureView *)get:(int64_t)textureId;

-(void)remove:(int64_t)textureId;

-(void)destroy;

@end

NS_ASSUME_NONNULL_END
