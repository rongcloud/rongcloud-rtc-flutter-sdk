//
//  RCFlutterRTCView.h
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/5.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterRTCView : NSObject<FlutterPlatformView>
- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@property (nonatomic, copy) NSString *userId;
- (void)changeViewColor;
@end

NS_ASSUME_NONNULL_END
