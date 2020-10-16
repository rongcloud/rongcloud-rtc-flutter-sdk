//
//  RCFlutterVideoCapture.h
//  Pods-Runner
//
//  Created by 孙承秀 on 2020/6/2.
//

#import "RCFlutterOutputStream.h"
#import <Flutter/Flutter.h>
#import "RCFlutterMacros.h"
#import "RCFlutterRTCManager.h"
#import "RCFlutterVideoOutputStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterVideoCapture: RCFlutterVideoOutputStream <FlutterPlugin>

/// 单例
SingleInstanceH(VideoCapture);

/// 销毁资源
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
