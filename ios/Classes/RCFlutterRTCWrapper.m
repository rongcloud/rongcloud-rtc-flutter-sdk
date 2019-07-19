//
//  RCFlutterRTCWrapper.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/4.
//

#import "RCFlutterRTCWrapper.h"
#import "RCFlutterRTCMethodKey.h"
#import "RCFlutterRTCViewFactory.h"
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>

@interface RCFlutterRTCWrapper ()<RongRTCRoomDelegate,RCConnectionStatusChangeDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) RongRTCRoom *rtcRoom;
@property (nonatomic, strong) RongRTCAVCapturer *capturer;
@property (nonatomic, strong) RongRTCVideoCaptureParam * captureParam;
@end

@implementation RCFlutterRTCWrapper
+ (instancetype)sharedInstance {
    static RCFlutterRTCWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)saveMethodChannel:(FlutterMethodChannel *)channel {
    self.channel = channel;
}
- (void)rtcHandleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([RCFlutterRTCMethodKeyInit isEqualToString:call.method]) {
        [self initWithAppKey:call.arguments];
    }else if([RCFlutterRTCMethodKeyConnect isEqualToString:call.method]) {
        [self connect:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyJoinRTCRoom isEqualToString:call.method]) {
        [self joinRTCRoom:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyLeaveRTCRoom isEqualToString:call.method]) {
        [self leaveRTCRoom:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyPublishAVStream isEqualToString:call.method]) {
        [self publishAVStream:result];
    }else if([RCFlutterRTCMethodKeyUnpublishAVStream isEqualToString:call.method]) {
        [self unpublishAVStream:result];
    }else if([RCFlutterRTCMethodKeyRenderLocalVideo isEqualToString:call.method]) {
        [self renderLocalVideoView:call.arguments];
    }else if([RCFlutterRTCMethodKeyRenderRemoteVideo isEqualToString:call.method]) {
        [self renderRemoteVideoView:call.arguments];
    }else if([RCFlutterRTCMethodKeyRemoveNativeView isEqualToString:call.method]) {
        [self removeNativeView:call.arguments];
    }else if([RCFlutterRTCMethodKeySubscribeAVStream isEqualToString:call.method]) {
        [self subscribeAVStream:call.arguments];
    }else if([RCFlutterRTCMethodKeyUnsubscribeAVStream isEqualToString:call.method]) {
        [self unsubscribeAVStream:call.arguments];
    }else if([RCFlutterRTCMethodKeyGetRemoteUsers isEqualToString:call.method]) {
        [self getRemoteUsers:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyMuteLocalAudio isEqualToString:call.method]) {
        [self muteLocalAudio:call.arguments];
    }else if([RCFlutterRTCMethodKeyMuteRemoteAudio isEqualToString:call.method]) {
        [self muteRemoteAudio:call.arguments];
    }else if([RCFlutterRTCMethodKeySwitchCamera isEqualToString:call.method]) {
        [self switchCamera:call.arguments];
    }else if([@"updateVideoViewSize" isEqualToString:call.method]) {
        [self updateVideoViewSize:call.arguments];
    }else if([@"exchangeVideo" isEqualToString:call.method]) {
        [self exchangeVideo:call.arguments];
    }
    else {
        NSLog(@"Error: iOS can't response methodname %@",call.method);
        result(FlutterMethodNotImplemented);
    }
}

- (void)initWithAppKey:(id)arg {
    if([arg isKindOfClass:[NSString class]]) {
        NSString *appkey = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] initWithAppKey:appkey];
        [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
         NSLog(@"iOS init appkey %@",appkey);
    }
}

- (void)connect:(id)arg result:(FlutterResult)result {
    NSLog(@"iOS connect start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *token = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
            result(@(0));
            NSLog(@"iOS connect end success");
        } error:^(RCConnectErrorCode status) {
            result(@(status));
            NSLog(@"iOS connect end error %@",@(status));
        } tokenIncorrect:^{
            result(@(RC_CONN_TOKEN_INCORRECT));
            NSLog(@"iOS connect end error %@",@(RC_CONN_TOKEN_INCORRECT));
        }];
    }
}

- (void)joinRTCRoom:(id)arg result:(FlutterResult)result {
    NSLog(@"iOS joinRTCRoom start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        __weak typeof(self) ws = self;
        [[RongRTCEngine sharedEngine] joinRoom:roomId completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
            if(room) {
                ws.rtcRoom = room;
                ws.rtcRoom.delegate = ws;
            }
            result(@(code));
            NSLog(@"iOS joinRTCRoom end %@",@(code));
        }];
    }
}

- (void)leaveRTCRoom:(id)arg result:(FlutterResult)result {
    NSLog(@"iOS leaveRTCRoom start");
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        [[RongRTCEngine sharedEngine] leaveRoom:roomId completion:^(BOOL isSuccess, RongRTCCode code) {
            result(@(code));
            NSLog(@"iOS leaveRTCRoom end %@",@(code));
        }];
    }
}

- (void)publishAVStream:(FlutterResult )result {
    NSLog(@"%s",__func__);
    if(!self.rtcRoom) {
        result(@(RongRTCCodeNotInRoom));
        return;
    }
    [self.rtcRoom publishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        result(@(desc));
    }];
}

- (void)unpublishAVStream:(FlutterResult )result {
    NSLog(@"%s",__func__);
    if(!self.rtcRoom) {
        result(@(RongRTCCodeNotInRoom));
        return;
    }
    [self.rtcRoom unpublishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        result(@(desc));
    }];
}

- (void)renderLocalVideoView:(id)arg {
    NSLog(@"%s",__func__);
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId = [dic[@"viewId"] intValue];
        RCFlutterRTCView *view = [[RCFlutterRTCViewFactory sharedInstance] getRenderFlutterView:viewId];
        [self renderLocalVideoViewAt:view];
    }
}

- (void)renderLocalVideoViewAt:(RCFlutterRTCView *)view {
    if(view) {
        RongRTCLocalVideoView *localView = (RongRTCLocalVideoView *)view.renderView;
        localView.fillMode = RCVideoFillModeAspectFill;
        [self.capturer setVideoRender:localView];
        
        [self.capturer setCaptureParam:self.captureParam];
        [self.capturer startCapture];
    }
}

- (void)renderRemoteVideoView:(id)arg  {
    NSLog(@"%s",__func__);
    if([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId = [dic[@"viewId"] intValue];
        NSString *userId = dic[@"userId"];
        
        RCFlutterRTCView *view = [[RCFlutterRTCViewFactory sharedInstance] getRenderFlutterView:viewId];
        [self renderRemoteVideoAt:view forUser:userId];
    }
}

- (void)renderRemoteVideoAt:(RCFlutterRTCView *)view forUser:(NSString *)userId{
    if(view) {
        for(RongRTCRemoteUser *remoteUser in self.rtcRoom.remoteUsers) {
            if([userId isEqualToString:remoteUser.userId]) {
                [self renderVideoOnView:view forRemoteUser:remoteUser];
                break;
            }
        }
    }
}

- (void)renderVideoOnView:(RCFlutterRTCView *)flutterView forRemoteUser:(RongRTCRemoteUser *)remoteUser {
    for(RongRTCAVInputStream *stream in remoteUser.remoteAVStreams) {
        if(RTCMediaTypeVideo == stream.streamType) {
            RongRTCRemoteVideoView *remoteView = (RongRTCRemoteVideoView *)flutterView.renderView;
            remoteView.fillMode = RCVideoFillModeAspectFill;
            [stream setVideoRender:remoteView];
            
            return;
        }
    }
}

- (void)updateVideoViewSize:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId = [dic[@"viewId"] intValue];
        int width = [dic[@"width"] intValue];
        int height = [dic[@"height"] intValue];
        [[RCFlutterRTCViewFactory sharedInstance] updateVideoView:viewId size:CGSizeMake(width, height)];
    }
}

- (void)exchangeVideo:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId1 = [dic[@"viewId1"] intValue];
        int viewId2 = [dic[@"viewId2"] intValue];
        [[RCFlutterRTCViewFactory sharedInstance] exchangeVideo:viewId1 with:viewId2];
    }
}

- (void)subscribeAVStream:(id)arg {
    if([arg isKindOfClass:[NSString class]]) {
        NSString *userId = (NSString *)arg;
        RongRTCRemoteUser *user = [self getRemoteUser:userId];
        if(user) {
            [self.rtcRoom subscribeAVStream:user.remoteAVStreams tinyStreams:nil completion:^(BOOL isSuccess, RongRTCCode desc) {
                
            }];
        }
    }
}

- (void)unsubscribeAVStream:(id)arg {
    if([arg isKindOfClass:[NSString class]]) {
        NSString *userId = (NSString *)arg;
        RongRTCRemoteUser *user = [self getRemoteUser:userId];
        if(user) {
            [self.rtcRoom unsubscribeAVStream:user.remoteAVStreams completion:^(BOOL isSuccess, RongRTCCode desc) {
                
            }];
        }
    }
}

- (void)getRemoteUsers:(id)arg result:(FlutterResult)result{
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        NSMutableArray<NSString *> *userIds = [NSMutableArray new];
        if(![self.rtcRoom.roomId isEqualToString:roomId]) {
            result(userIds);
            return;
        }
        for(RongRTCRemoteUser *u in self.rtcRoom.remoteUsers) {
            [userIds addObject:u.userId];
        }
        result(userIds);
    }
}

- (void)removeNativeView:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId = [dic[@"viewId"] intValue];
        [[RCFlutterRTCViewFactory sharedInstance] removeRenderVideoView:viewId];
    }
}


- (void)muteLocalAudio:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        BOOL muted = [dic[@"muted"] boolValue];
        [self.capturer setMicrophoneDisable:muted];
    }
}

- (void)muteRemoteAudio:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        BOOL muted = [dic[@"muted"] boolValue];
        NSString *userId = dic[@"userId"];
        for(RongRTCRemoteUser *user in self.rtcRoom.remoteUsers) {
            if([user.userId isEqualToString:userId]) {
                for(RongRTCAVInputStream *stream in user.remoteAVStreams) {
                    if(RTCMediaTypeAudio == stream.streamType) {
                        stream.disable = muted;
                    }
                }
            }
        }
    }
}

- (void)switchCamera:(id)arg {
    [self.capturer switchCamera];
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    NSDictionary *dic = @{@"status":@(status)};
    [self.channel invokeMethod:RCMethodCallBackKeyConnectionStatusChange arguments:dic];
}

#pragma mark - RongRTCRoomDelegate
-(void)didJoinUser:(RongRTCRemoteUser*)user {
    NSString *userId = user.userId;
    if(userId) {
        [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyUserJoined arguments:@{@"userId":userId}];
    }
}

-(void)didLeaveUser:(RongRTCRemoteUser*)user {
    NSString *userId = user.userId;
    if(userId) {
        [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyUserLeaved arguments:@{@"userId":userId}];
    }
}

- (void)didPublishStreams:(NSArray <RongRTCAVInputStream *>*)streams {
    if(streams.count > 0) {
        RongRTCAVInputStream *stream = streams[0];
        NSString *userId = stream.userId;
        if(userId) {
            [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyOthersPublishStreams arguments:@{@"userId":userId}];
        }
    }
}


#pragma mark - util method
- (RongRTCRemoteUser *)getRemoteUser:(NSString *)userId {
    for(RongRTCRemoteUser *user in self.rtcRoom.remoteUsers) {
        if([userId isEqualToString:user.userId]) {
            return user;
        }
    }
    return nil;
}

- (BOOL)cancelRenderVideoInView:(UIView *)view {
    BOOL canceled = NO;
    UIView *renderedView = nil;
    for(UIView * v in view.subviews) {
        if([v isKindOfClass:[RongRTCLocalVideoView class]] || [v isKindOfClass:[RongRTCRemoteVideoView class]]) {
            renderedView = v;
            break;
        }
    }
    if(renderedView) {
        [renderedView removeFromSuperview];
        canceled = YES;
    }
    return canceled;
}

#pragma mark - getter
- (RongRTCAVCapturer *)capturer {
    if(!_capturer) {
        _capturer = [RongRTCAVCapturer sharedInstance];
    }
    return _capturer;
}
- (RongRTCVideoCaptureParam *)captureParam {
    if(!_captureParam) {
        _captureParam = [[RongRTCVideoCaptureParam alloc] init];
    }
    return _captureParam;
}
@end
