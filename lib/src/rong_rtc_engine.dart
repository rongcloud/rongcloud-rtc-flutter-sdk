import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'rong_method_key.dart';
import 'connection_status_convert.dart';

class RongRtcEngine {
  static const MethodChannel _channel =
      const MethodChannel('plugins.rongcloud.im/rtc_plugin');

  static Future<int> joinRTCRoom(String roomId) async {
    _addMethodCallHandler();
    int code = await _channel.invokeMethod(MethodKey.JoinRTCRoom,roomId);
    return code;
  }

  static Future<int> leaveRTCRoom(String roomId) async {
    int code = await _channel.invokeMethod(MethodKey.LeaveRTCRoom,roomId);
    return code;
  }

  static Future<List> getRemoteUsers(String roomId) async {
    List userIds = await _channel.invokeMethod(MethodKey.GetRemoteUsers,roomId);
    return userIds;
  }
  ///必须在 publishAVStream 前调用
  static void renderLocalVideo(int viewId) {
    Map map = {"viewId":viewId};
    _channel.invokeMethod(MethodKey.RenderLocalVideo,map);
  }

  static void renderRemoteVideo(int viewId,String userId) {
    Map map = {"viewId":viewId,"userId":userId};
    _channel.invokeMethod(MethodKey.RenderRemoteVideo,map);
  }

  static void muteLocalAudio(bool muted) {
    Map map = {"muted":muted};
    _channel.invokeMethod(MethodKey.MuteLocalAudio,map);
  }

  // static void updateVideoViewSize(int viewId,int width,int height) {
  //   Map map = {"viewId":viewId,"width":width,"height":height};
  //   _channel.invokeMethod("updateVideoViewSize",map);
  // }

  static void exchangeVideo(int viewId1,int viewId2) {
    Map map = {"viewId1":viewId1,"viewId2":viewId2};
    _channel.invokeMethod("exchangeVideo",map);
  }

  static void muteRemoteAudio(String userId,bool muted) {
    Map map = {"userId":userId,"muted":muted};
    _channel.invokeMethod(MethodKey.MuteRemoteAudio,map);
  }

  static void switchCamera() {
    _channel.invokeMethod(MethodKey.SwitchCamera);
  }

  static void removeNativeView(int viewId) {
    if(viewId == null) {
      return;
    }
    Map map = {"viewId":viewId};
    _channel.invokeMethod(MethodKey.RemoveNativeView,map);
  }

  ///必须在 renderLocalVideo 后调用
  static void publishAVStream() {
    _channel.invokeMethod(MethodKey.PublishAVStream);
  }

  static void unpublishAVStream() {
    _channel.invokeMethod(MethodKey.UnpublishAVStream);
  }


  static void subscribeAVStream(String userId) {
    _channel.invokeMethod(MethodKey.SubscribeAVStream,userId);
  }

  static void unsubscribeAVStream(String userId) {
    _channel.invokeMethod(MethodKey.UnsubscribeAVStream,userId);
  }


  static void Function(String roomId) onJoinRTCRoomSuccess;

  static void Function(String userId) onUserJoined;

  static void Function(String userId) onUserLeaved;

  static void Function(String userId) onOthersPublishStreams;

  static void Function(String methodName,int code) onError;


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

  static Function(int connectionStatus) onConnectionStatusChange;

  static void _addMethodCallHandler() {

    _channel.setMethodCallHandler((MethodCall call) {
      Map arg = call.arguments;
      switch (call.method) {
        case MethodCallBackKey.UserJoined:
          if(onUserJoined != null) {
            onUserJoined(arg["userId"]);
          }
          break;
        case MethodCallBackKey.UserLeaved:
          if(onUserLeaved != null) {
            onUserLeaved(arg["userId"]);
          }
          break;
        case MethodCallBackKey.OthersPublishStreams:
          if(onOthersPublishStreams != null) {
            onOthersPublishStreams(arg["userId"]);
          }
          break;
        case MethodCallBackKey.ConnectionStatusChange:
          if (onConnectionStatusChange != null) {
            Map map = call.arguments;
            int code = map["status"];
            int status = ConnectionStatusConvert.convert(code);
            onConnectionStatusChange(status);
          }
          break;
      }
    });
  }
    
  
}