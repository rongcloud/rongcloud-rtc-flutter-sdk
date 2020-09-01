//
//  RCFlutterOutputStream+Private.h
//  Pods-Runner
//
//  Created by 孙承秀 on 2020/5/27.
//

#import "RCFlutterOutputStream.h"
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterOutputStream (Private)

@property(nonatomic, strong) RCRTCOutputStream *rtcOutputStream;
@end

NS_ASSUME_NONNULL_END
