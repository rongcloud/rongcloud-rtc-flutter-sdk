import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'rong_method_key.dart';
import 'rong_rtc_config.dart';

class RongRTCEngine {
  static const MethodChannel _channel =
      const MethodChannel('plugins.rongcloud.im/rtc_plugin');
  
  ///配置
  ///
  ///请在 [renderLocalVideo] 接口前调用
  static void config(RongRTCConfig config) {
    Map conf = config.toMap();
    _channel.invokeMethod(RCRTCMethodKey.Config,conf);
  }

  /// 加入 RTC 房间
  /// 
  /// [roomId] 房间 id
  /// 
  /// [finished] 回调结果，告知结果成功与否，code 参见 [RongRTCCode]
  static void joinRTCRoom(String roomId,Function (int code) finished) async {
    _addMethodCallHandler();
    int code = await _channel.invokeMethod(RCRTCMethodKey.JoinRTCRoom,roomId);
    if(finished != null) {
      finished(code);
    }
  }

  /// 离开 RTC 房间
  /// 
  /// [roomId] 房间 id
  /// 
  /// [finished] 回调结果，告知结果成功与否，code 参见 [RongRTCCode]
  static void leaveRTCRoom(String roomId,Function (int code) finished) async {
    int code = await _channel.invokeMethod(RCRTCMethodKey.LeaveRTCRoom,roomId);
    if(finished != null) {
      finished(code);
    }
  }

  /// 获取当前房间的其他用户 id 列表
  static Future<List> getRemoteUsers(String roomId) async {
    List userIds = await _channel.invokeMethod(RCRTCMethodKey.GetRemoteUsers,roomId);
    return userIds;
  }

  /// 渲染本地视频
  /// 
  /// 必须要先于 [publishAVStream] 调用
  static void renderLocalVideo(int viewId) {
    Map map = {"viewId":viewId};
    _channel.invokeMethod(RCRTCMethodKey.RenderLocalVideo,map);
  }

  /// 渲染远端用户视频
  /// 
  /// [userId] 用户 id
  /// 
  /// [viewId] 视频所在 viewId
  static void renderRemoteVideo(String userId,int viewId) {
    Map map = {"viewId":viewId,"userId":userId};
    _channel.invokeMethod(RCRTCMethodKey.RenderRemoteVideo,map);
  }

  /// 本地静音开关
  /// 
  /// [muted] 是否轻音
  static void muteLocalAudio(bool muted) {
    Map map = {"muted":muted};
    _channel.invokeMethod(RCRTCMethodKey.MuteLocalAudio,map);
  }

  ///切换视频，调用之后会将两个用户的视频进行交换，包含视频位置、视频屏幕大小的切换
  ///
  /// [viewId1] 第一个用户的视频 viewId
  /// 
  /// [viewId2] 第二个用户的视频 viewId
  static void exchangeVideo(int viewId1,int viewId2) {
    Map map = {"viewId1":viewId1,"viewId2":viewId2};
    _channel.invokeMethod(RCRTCMethodKey.ExchangeVideo,map);
  }

  /// 远端用户静音开关
  static void muteRemoteAudio(String userId,bool muted) {
    Map map = {"userId":userId,"muted":muted};
    _channel.invokeMethod(RCRTCMethodKey.MuteRemoteAudio,map);
  }

  /// 切换本地用户摄像头
  static void switchCamera() {
    _channel.invokeMethod(RCRTCMethodKey.SwitchCamera);
  }

  /// 移除 iOS/Android 的 platform view
  /// 
  /// [viewId] 视频 viewId
  static void removePlatformView(int viewId) {
    if(viewId == null) {
      return;
    }
    Map map = {"viewId":viewId};
    _channel.invokeMethod(RCRTCMethodKey.RemovePlatformView,map);
  }

  /// 当前用户发布音视频流
  /// 
  /// 必须在 [renderLocalVideo] 后调用 
  static void publishAVStream(Function (int code) finished) async {
    int code = await _channel.invokeMethod(RCRTCMethodKey.PublishAVStream);
    if(finished != null) {
      finished(code);
    }
  }


  /// 取消发布当前用户音视频流
  static void unpublishAVStream(Function (int code) finished) async {
    int code = await _channel.invokeMethod(RCRTCMethodKey.UnpublishAVStream);
    if(finished != null) {
      finished(code);
    }
  }

  /// 订阅远端用户的音视频流
  /// 
  /// [userId] 远端用户 id
  static void subscribeAVStream(String userId,Function (int code) finished) {
    _channel.invokeMethod(RCRTCMethodKey.SubscribeAVStream,userId);
  }

  /// 取消订阅远端用户的音视频流
  /// 
  /// [userId] 远端用户 id
  static void unsubscribeAVStream(String userId,Function (int code) finished) {
    _channel.invokeMethod(RCRTCMethodKey.UnsubscribeAVStream,userId);
  }

  /// 有远端用户加入的回调
  static void Function(String userId) onUserJoined;

  /// 有远端用户离开的回调
  static void Function(String userId) onUserLeaved;

  /// 有远端用户发布音视频的回调
  static void Function(String userId) onUserStreamPublished;

  /// 有远端用户取消发布音视频流的回调
  static void Function(String userId) onUserStreamUnpublished;

  /// 远端用户的视频是否可用的回调，如对方关闭了摄像头
  static void Function(String userId,bool enable) onUserVideoEnabled;

  /// 远端用户的音频是否可用的回调，如对方关闭了麦克风
  static void Function(String userId,bool enable) onUserAudioEnabled;

  /// 收到远端用户第一关键帧的回调
  static void Function(String userId) onUserFirstKeyframeReceived;

  /// 创建 iOS/Android 的 platform view
  static Widget createPlatformView(String userId,int width,int height,Function(int viewId) created) {
    if(TargetPlatform.iOS == defaultTargetPlatform) {
      return UiKitView(
        viewType: 'plugins.rongcloud.im/rtc_view',
        onPlatformViewCreated: (int viewId) {
          if(created != null) {
            created(viewId);
          }
        },
        creationParams: <String,dynamic>{
          "userId":userId,
          "width":width,
          "height":height
        },
        creationParamsCodec: new StandardMessageCodec(),
          
      );
    } else if(TargetPlatform.android == defaultTargetPlatform) {
      return AndroidView(
        viewType: 'plugins.rongcloud.im/rtc_view',
        onPlatformViewCreated: (int viewId) {
          if(created != null) {
            created(viewId);
          }
        },
        creationParams: <String,dynamic>{
          "userId":userId,
          "width":width,
          "height":height,
        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return null;
  }


  static void _addMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map arg = call.arguments;
      switch (call.method) {
        case RCRTCMethodCallBackKey.UserJoined:
          if(onUserJoined != null) {
            onUserJoined(arg["userId"]);
          }
          break;
        case RCRTCMethodCallBackKey.UserLeaved:
          if(onUserLeaved != null) {
            onUserLeaved(arg["userId"]);
          }
          break;
        case RCRTCMethodCallBackKey.RemoteUserPublishStreams:
          if(onUserStreamPublished != null) {
            onUserStreamPublished(arg["userId"]);
          }
          break;
        case RCRTCMethodCallBackKey.RemoteUserUnpublishStreams:
          if(onUserStreamUnpublished != null) {
            onUserStreamUnpublished(arg["userId"]);
          }
          break;
        case RCRTCMethodCallBackKey.RemoteUserVideoEnabled:
          if(onUserVideoEnabled != null) {
            onUserVideoEnabled(arg["userId"],arg["enable"]);
          }
          break;
        case RCRTCMethodCallBackKey.RemoteUserAudioEnabled:
          if(onUserAudioEnabled != null) {
            onUserVideoEnabled(arg["userId"],arg["enable"]);
          }
          break;
        case RCRTCMethodCallBackKey.RemoteUserFirstKeyframe:
          if(onUserFirstKeyframeReceived != null) {
            onUserFirstKeyframeReceived(arg["userId"]);
          }
          break;
      }
    });
  }
    
  
}