import 'dart:convert';

import 'package:flutter/services.dart';

import '../../utils/rcrtc_debug_checker.dart';
import '../stream/rcrtc_audio_input_stream.dart';
import '../stream/rcrtc_input_stream.dart';
import '../stream/rcrtc_stream.dart';
import '../stream/rcrtc_video_input_stream.dart';
import 'rcrtc_local_user.dart';
import 'rcrtc_remote_user.dart';

class RCRTCRoom {
  final MethodChannel _channel;
  final String id;
  final RCRTCLocalUser localUser;
  final List<RCRTCRemoteUser> remoteUserList = List<RCRTCRemoteUser>();

  Function(RCRTCRemoteUser remoteUser) onRemoteUserJoined;
  Function(RCRTCRemoteUser remoteUser) onRemoteUserLeft;
  Function(RCRTCRemoteUser remoteUser, List<RCRTCInputStream> streamList) onRemoteUserPublishResource;
  Function(RCRTCRemoteUser remoteUser, List<RCRTCInputStream> streamList) onRemoteUserUnpublishResource;

  RCRTCRoom.fromJson(Map<String, dynamic> jsonObj)
      : _channel = MethodChannel('rong.flutter.rtclib/Room:${jsonObj['id']}'),
        id = jsonObj['id'],
        localUser = RCRTCLocalUser.fromJson(jsonObj['localUser']) {
    List<dynamic> jsonRemoteUserList = jsonObj['remoteUserList'];
    for (var jsonRemoteUser in jsonRemoteUserList) remoteUserList.add(RCRTCRemoteUser.fromJson(jsonRemoteUser));
    _channel.setMethodCallHandler(methodCallHandler);
  }

  Future<dynamic> methodCallHandler(MethodCall call) {
    switch (call.method) {
      case 'onUserJoined':
        _handleOnUserJoined(call.arguments);
        break;
      case 'onUserLeft':
        _handleOnUserLeft(call.arguments);
        break;
      case 'onRemoteUserPublishResource':
        _handleOnRemoteUserPublishResource(call.arguments);
        break;
      case 'onRemoteUserUnpublishResource':
        _handleOnRemoteUserUnpublishResource(call.arguments);
        break;
    }
    return null;
  }

  void _handleOnUserJoined(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    RCRTCRemoteUser targetUser = RCRTCRemoteUser.fromJson(jsonObj['remoteUser']);
    for (RCRTCRemoteUser user in remoteUserList) assert(user.id != targetUser.id);
    remoteUserList.add(targetUser);
    if (onRemoteUserJoined != null) onRemoteUserJoined(targetUser);
  }

  void _handleOnUserLeft(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        remoteUserList.remove(user);
        break;
      }
    }
    RCRTCDebugChecker.notNull(targetUser);
    if (onRemoteUserLeft != null) onRemoteUserLeft(targetUser);
  }

  void _handleOnRemoteUserPublishResource(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        break;
      }
    }
    RCRTCDebugChecker.notNull(targetUser);
    List<dynamic> jsonStreamList = jsonObj['streamList'];
    List<RCRTCInputStream> targetStreamList = jsonStreamList.map((stream) {
      if (stream['type'] == 0) {
        return RCRTCAudioInputStream.fromJson(stream);
      } else {
        return RCRTCVideoInputStream.fromJson(stream);
      }
    }).toList();
    targetUser.streamList.addAll(targetStreamList);
    if (onRemoteUserPublishResource != null) onRemoteUserPublishResource(targetUser, targetStreamList);
  }

  void _handleOnRemoteUserUnpublishResource(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        break;
      }
    }
    RCRTCDebugChecker.notNull(targetUser);
    List<dynamic> jsonStreamList = jsonObj['streamList'];
    List<RCRTCInputStream> targetStreamList = List();
    for (Map<String, dynamic> jsonStream in jsonStreamList) {
      for (RCRTCStream stream in targetUser.streamList) {
        if (stream.streamId == jsonStream['id'] && stream.type.index == jsonStream['type']) {
          targetStreamList.add(stream);
          break;
        }
      }
    }
    RCRTCDebugChecker.isTrue(targetStreamList.length == jsonStreamList.length);
    for (RCRTCStream stream in targetStreamList) targetUser.streamList.remove(stream);
    if (onRemoteUserUnpublishResource != null) onRemoteUserUnpublishResource(targetUser, targetStreamList);
  }
}
