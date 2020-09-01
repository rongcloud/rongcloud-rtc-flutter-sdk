#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <RongRTCLib/RongRTCLib.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
//    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Info];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
