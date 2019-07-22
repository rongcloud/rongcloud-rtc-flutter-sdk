//
//  RCFlutterRTCWrapper.m
//  rongcloud_rtc_plugin
//
//  Created by Sin on 2019/7/4.
//

#import "RCFlutterRTCWrapper.h"
#import "RCFlutterRTCMethodKey.h"
#import "RCFlutterRTCViewFactory.h"
#import "RCFlutterRTCConfig.h"
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCRTCFlutterLog.h"

@interface RCFlutterRTCWrapper ()<RongRTCRoomDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) RongRTCRoom *rtcRoom;
@property (nonatomic, strong) RongRTCAVCapturer *capturer;
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
    if([RCFlutterRTCMethodKeyConfig isEqualToString:call.method]) {
        [self config:call.arguments];
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
    }else if([RCFlutterRTCMethodKeyRemovePlatformView isEqualToString:call.method]) {
        [self removePlatformView:call.arguments];
    }else if([RCFlutterRTCMethodKeySubscribeAVStream isEqualToString:call.method]) {
        [self subscribeAVStream:call.arguments result:result];
    }else if([RCFlutterRTCMethodKeyUnsubscribeAVStream isEqualToString:call.method]) {
        [self unsubscribeAVStream:call.arguments result:result];
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
    }else if([RCFlutterRTCMethodKeyExchangeVideo isEqualToString:call.method]) {
        [self exchangeVideo:call.arguments];
    }
    else {
        [RCRTCLog e:[NSString stringWithFormat:@" iOS can't response method : %@",call.method]];
        result(FlutterMethodNotImplemented);
    }
}

- (void)config:(id)arg {
    NSString *LOG_TAG = @"config";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        [[RCFlutterRTCConfig sharedConfig] updateParam:dic];
    }
}

- (void)joinRTCRoom:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"joinRTCRoom";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        __weak typeof(self) ws = self;
        [[RongRTCEngine sharedEngine] joinRoom:roomId completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
            if(room) {
                ws.rtcRoom = room;
                ws.rtcRoom.delegate = ws;
            }
            [RCRTCLog i:[NSString stringWithFormat:@"%@ result:%@",LOG_TAG,@(code)]];
            result(@(code));
        }];
    }
}

- (void)leaveRTCRoom:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"leaveRTCRoom";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        [[RongRTCEngine sharedEngine] leaveRoom:roomId completion:^(BOOL isSuccess, RongRTCCode code) {
            result(@(code));
            [RCRTCLog i:[NSString stringWithFormat:@"%@ result:%@",LOG_TAG,@(code)]];
        }];
    }
}

- (void)publishAVStream:(FlutterResult )result {
    NSString *LOG_TAG = @"publishAVStream";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start",LOG_TAG]];
    if(!self.rtcRoom) {
        result(@(RongRTCCodeNotInRoom));
        [RCRTCLog e:[NSString stringWithFormat:@"%@ not in room",LOG_TAG]];
        return;
    }
    [self.rtcRoom publishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        result(@(desc));
        [RCRTCLog i:[NSString stringWithFormat:@"%@ result:%@",LOG_TAG,@(desc)]];
    }];
}

- (void)unpublishAVStream:(FlutterResult )result {
    NSString *LOG_TAG = @"unpublishAVStream";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start",LOG_TAG]];
    if(!self.rtcRoom) {
        result(@(RongRTCCodeNotInRoom));
        [RCRTCLog e:[NSString stringWithFormat:@"%@ not in room",LOG_TAG]];
        return;
    }
    [self.rtcRoom unpublishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        result(@(desc));
        [RCRTCLog i:[NSString stringWithFormat:@"%@ result:%@",LOG_TAG,@(desc)]];
    }];
}

- (void)renderLocalVideoView:(id)arg {
    NSString *LOG_TAG = @"renderLocalVideoView";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
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
        
        [self.capturer setCaptureParam:[RCFlutterRTCConfig sharedConfig].captureParam];
        [self.capturer startCapture];
    }
}

- (void)renderRemoteVideoView:(id)arg  {
    NSString *LOG_TAG = @"renderRemoteVideoView";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
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
    NSString *LOG_TAG = @"exchangeVideo";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId1 = [dic[@"viewId1"] intValue];
        int viewId2 = [dic[@"viewId2"] intValue];
        [[RCFlutterRTCViewFactory sharedInstance] exchangeVideo:viewId1 with:viewId2];
    }
}

- (void)subscribeAVStream:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG = @"subscribeAVStream";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        if(!self.rtcRoom) {
            result(@(RongRTCCodeNotInRoom));
            [RCRTCLog e:[NSString stringWithFormat:@"%@ not in room",LOG_TAG]];
            return;
        }
        NSString *userId = (NSString *)arg;
        RongRTCRemoteUser *user = [self getRemoteUser:userId];
        if(user) {
            [self.rtcRoom subscribeAVStream:user.remoteAVStreams tinyStreams:nil completion:^(BOOL isSuccess, RongRTCCode desc) {
                result(@(desc));
                [RCRTCLog i:[NSString stringWithFormat:@"%@ result:%@",LOG_TAG,@(desc)]];
            }];
        }else {
            result(@(RongRTCCodeInvalidUserId));
            [RCRTCLog e:[NSString stringWithFormat:@"%@ user not in room:%@",LOG_TAG,userId]];
        }
    }
}

- (void)unsubscribeAVStream:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG = @"unsubscribeAVStream";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        if(!self.rtcRoom) {
            result(@(RongRTCCodeNotInRoom));
            [RCRTCLog e:[NSString stringWithFormat:@"%@ not in room",LOG_TAG]];
            return;
        }
        NSString *userId = (NSString *)arg;
        RongRTCRemoteUser *user = [self getRemoteUser:userId];
        if(user) {
            [self.rtcRoom unsubscribeAVStream:user.remoteAVStreams completion:^(BOOL isSuccess, RongRTCCode desc) {
                result(@(desc));
                [RCRTCLog i:[NSString stringWithFormat:@"%@ result:%@",LOG_TAG,@(desc)]];
            }];
        }else {
            result(@(RongRTCCodeInvalidUserId));
            [RCRTCLog e:[NSString stringWithFormat:@"%@ user not in room:%@",LOG_TAG,userId]];
        }
    }
}

- (void)getRemoteUsers:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG = @"getRemoteUsers";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *roomId = (NSString *)arg;
        NSMutableArray<NSString *> *userIds = [NSMutableArray new];
        if(![self.rtcRoom.roomId isEqualToString:roomId]) {
            result(userIds);
            [RCRTCLog e:[NSString stringWithFormat:@"%@ not in room",LOG_TAG]];
            return;
        }
        for(RongRTCRemoteUser *u in self.rtcRoom.remoteUsers) {
            [userIds addObject:u.userId];
        }
        result(userIds);
    }
}

- (void)removePlatformView:(id)arg {
    NSString *LOG_TAG = @"removePlatformView";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int viewId = [dic[@"viewId"] intValue];
        [[RCFlutterRTCViewFactory sharedInstance] removeRenderVideoView:viewId];
    }
}


- (void)muteLocalAudio:(id)arg {
    NSString *LOG_TAG = @"muteLocalAudio";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        BOOL muted = [dic[@"muted"] boolValue];
        [self.capturer setMicrophoneDisable:muted];
    }
}

- (void)muteRemoteAudio:(id)arg {
    NSString *LOG_TAG = @"muteRemoteAudio";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        BOOL muted = [dic[@"muted"] boolValue];
        NSString *userId = dic[@"userId"];
        for(RongRTCRemoteUser *user in self.rtcRoom.remoteUsers) {
            if([user.userId isEqualToString:userId]) {
                for(RongRTCAVInputStream *stream in user.remoteAVStreams) {
                    if(RTCMediaTypeAudio == stream.streamType) {
                        stream.disable = muted;
                        return;
                    }
                }
            }
        }
    }
}

- (void)switchCamera:(id)arg {
    NSString *LOG_TAG = @"switchCamera";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    [self.capturer switchCamera];
}

#pragma mark - RongRTCRoomDelegate
-(void)didJoinUser:(RongRTCRemoteUser*)user {
    NSString *userId = user.userId;
    if(userId) {
        [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyUserJoined arguments:@{@"userId":userId}];
    }
    NSString *LOG_TAG = @"onUserJoined";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
}

-(void)didLeaveUser:(RongRTCRemoteUser*)user {
    NSString *userId = user.userId;
    if(userId) {
        [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyUserLeaved arguments:@{@"userId":userId}];
    }
    NSString *LOG_TAG = @"onUserLeaved";
    [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
}

- (void)didPublishStreams:(NSArray <RongRTCAVInputStream *>*)streams {
    if(streams.count > 0) {
        RongRTCAVInputStream *stream = streams[0];
        NSString *userId = stream.userId;
        if(userId) {
            [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyRemoteUserPublishStreams arguments:@{@"userId":userId}];
        }
        NSString *LOG_TAG = @"onUserStreamPublished";
        [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
    }
}

- (void)didUnpublishStreams:(NSArray<RongRTCAVInputStream *>*)streams {
    if(streams.count > 0) {
        RongRTCAVInputStream *stream = streams[0];
        NSString *userId = stream.userId;
        if(userId) {
            [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyRemoteUserUnpublishStreams arguments:@{@"userId":userId}];
        }
        NSString *LOG_TAG = @"onUserStreamUnpublished";
        [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
        
    }
}

- (void)stream:(RongRTCAVInputStream*)stream didAudioMute:(BOOL)mute {
    if(stream) {
        NSString *userId = stream.userId;
        if(userId) {
            [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyRemoteUserAudioEnabled arguments:@{@"userId":userId,@"enable":@(!mute)}];
        }
        NSString *LOG_TAG = @"onUserAudioEnabled";
        [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
    }
}

- (void)stream:(RongRTCAVInputStream*)stream didVideoEnable:(BOOL)enable {
    if(stream) {
        NSString *userId = stream.userId;
        if(userId) {
            [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyRemoteUserVideoEnabled arguments:@{@"userId":userId,@"enable":@(enable)}];
        }
        NSString *LOG_TAG = @"onUserVideoEnabled";
        [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
    }
}

- (void)didReportFirstKeyframe:(RongRTCAVInputStream *)stream {
    if(stream) {
        NSString *userId = stream.userId;
        if(userId) {
            [self.channel invokeMethod:RCFlutterRTCMethodCallBackKeyRemoteUserFirstKeyframe arguments:@{@"userId":userId}];
        }
        NSString *LOG_TAG = @"onUserFirstKeyframeReceived";
        [RCRTCLog i:[NSString stringWithFormat:@"%@ user:%@",LOG_TAG,userId]];
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
@end
