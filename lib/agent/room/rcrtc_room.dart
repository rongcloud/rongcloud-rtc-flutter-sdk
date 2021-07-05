import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin/src/util/message_factory.dart';

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
  final List<RCRTCRemoteUser> remoteUserList = [];

  Function(RCRTCRemoteUser remoteUser)? onRemoteUserJoined;
  Function(RCRTCRemoteUser remoteUser)? onRemoteUserOffline;
  Function(RCRTCRemoteUser remoteUser)? onRemoteUserLeft;
  Function(RCRTCRemoteUser remoteUser, List<RCRTCInputStream> streamList)? onRemoteUserPublishResource;
  Function(RCRTCRemoteUser remoteUser, List<RCRTCInputStream> streamList)? onRemoteUserUnPublishResource;
  Function(List<RCRTCInputStream> streamList)? onPublishLiveStreams;
  Function(List<RCRTCInputStream> streamList)? onUnPublishLiveStreams;
  Function(Message message)? onReceiveMessage;

  RCRTCRoom.fromJson(Map<String, dynamic> jsonObj)
      : _channel = MethodChannel('rong.flutter.rtclib/Room:${jsonObj['id']}'),
        id = jsonObj['id'],
        localUser = RCRTCLocalUser.fromJson(jsonObj['localUser']) {
    List<dynamic> jsonRemoteUserList = jsonObj['remoteUserList'];
    jsonRemoteUserList.forEach((user) {
      remoteUserList.add(RCRTCRemoteUser.fromJson(user));
    });
    _channel.setMethodCallHandler(methodCallHandler);
  }

  Future<dynamic> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onUserJoined':
        _handleOnUserJoined(call.arguments);
        break;
      case 'onUserOffline':
        _handleOnUserOffline(call.arguments);
        break;
      case 'onUserLeft':
        _handleOnUserLeft(call.arguments);
        break;
      case 'onRemoteUserPublishResource':
        _handleOnRemoteUserPublishResource(call.arguments);
        break;
      case 'onRemoteUserUnPublishResource':
        _handleOnRemoteUserUnPublishResource(call.arguments);
        break;
      case 'onRemoteUserPublishLiveResource':
        _handleOnPublishLiveStreams(call.arguments);
        break;
      case 'onRemoteUserUnPublishLiveResource':
        _handleOnUnPublishLiveStreams(call.arguments);
        break;
      case 'onReceiveMessage':
        _handleOnReceiveMessage(call.arguments);
        break;
    }
  }

  void _handleOnUserJoined(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    RCRTCRemoteUser targetUser = RCRTCRemoteUser.fromJson(jsonObj['remoteUser']);
    for (RCRTCRemoteUser user in remoteUserList) assert(user.id != targetUser.id);
    remoteUserList.add(targetUser);
    onRemoteUserJoined?.call(targetUser);
  }

  void _handleOnUserOffline(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser? targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        remoteUserList.remove(user);
        break;
      }
    }
    onRemoteUserOffline?.call(targetUser!);
  }

  void _handleOnUserLeft(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser? targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        remoteUserList.remove(user);
        break;
      }
    }
    onRemoteUserLeft?.call(targetUser!);
  }

  void _handleOnRemoteUserPublishResource(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser? targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        break;
      }
    }
    List<dynamic> jsonStreamList = jsonObj['streamList'];
    List<RCRTCInputStream> targetStreamList = jsonStreamList.map((stream) {
      if (stream['type'] == 0) {
        return RCRTCAudioInputStream.fromJson(stream);
      } else {
        return RCRTCVideoInputStream.fromJson(stream);
      }
    }).toList();
    targetUser?.streamList.addAll(targetStreamList);
    onRemoteUserPublishResource?.call(targetUser!, targetStreamList);
  }

  void _handleOnRemoteUserUnPublishResource(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    String userId = jsonObj['remoteUser']['id'];
    RCRTCRemoteUser? targetUser;
    for (RCRTCRemoteUser user in remoteUserList) {
      if (user.id == userId) {
        targetUser = user;
        break;
      }
    }
    List<dynamic> jsonStreamList = jsonObj['streamList'];
    List<RCRTCInputStream> targetStreamList = [];
    for (Map<String, dynamic> jsonStream in jsonStreamList) {
      for (RCRTCStream stream in targetUser!.streamList) {
        if (stream.streamId == jsonStream['streamId'] && stream.type.index == jsonStream['type']) {
          targetStreamList.add(stream as RCRTCInputStream);
          break;
        }
      }
    }
    for (RCRTCStream stream in targetStreamList) targetUser!.streamList.remove(stream);
    onRemoteUserUnPublishResource?.call(targetUser!, targetStreamList);
  }

  void _handleOnPublishLiveStreams(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    List<dynamic> list = jsonObj['streamList'];
    List<RCRTCInputStream> streams = list.map((stream) {
      if (stream['type'] == 0) {
        return RCRTCAudioInputStream.fromJson(stream);
      } else {
        return RCRTCVideoInputStream.fromJson(stream);
      }
    }).toList();
    onPublishLiveStreams?.call(streams);
  }

  void _handleOnUnPublishLiveStreams(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    List<dynamic> jsonStreamList = jsonObj['streamList'];
    List<RCRTCInputStream> streams = jsonStreamList.map((stream) {
      if (stream['type'] == 0) {
        return RCRTCAudioInputStream.fromJson(stream);
      } else {
        return RCRTCVideoInputStream.fromJson(stream);
      }
    }).toList();
    onUnPublishLiveStreams?.call(streams);
  }

  void _handleOnReceiveMessage(String msg) {
    Message? message = MessageFactory.instance?.string2Message(msg);
    if (message != null) onReceiveMessage?.call(message);
  }

  Future<int> setRoomAttributeValue(String key, String value, MessageContent message) async {
    Map<String, dynamic> arguments = {
      "key": key,
      "value": value,
      "object": message.getObjectName(),
      "content": message.encode(),
    };
    int? result = await _channel.invokeMethod('setRoomAttributeValue', arguments);
    return result ?? -1;
  }

  Future<int> deleteRoomAttributes(List<String> keys, MessageContent message) async {
    Map<String, dynamic> arguments = {
      "keys": jsonEncode(keys),
      "object": message.getObjectName(),
      "content": message.encode(),
    };
    int? result = await _channel.invokeMethod('deleteRoomAttributes', arguments);
    return result ?? -1;
  }

  Future<Map<String, String>?> getRoomAttributes(List<String> keys) async {
    Map<String, dynamic> arguments = {
      "keys": jsonEncode(keys),
    };
    Map<String, String>? results = await _channel.invokeMapMethod('getRoomAttributes', arguments);
    return results;
  }

  Future<void> sendMessage(
    MessageContent message,
    void onSuccess(int id),
    void onError(int id, int code),
  ) async {
    Map<String, dynamic> arguments = {
      "object": message.getObjectName(),
      "content": message.encode(),
    };
    Map result = await _channel.invokeMethod('sendMessage', arguments);
    int id = result["id"];
    int code = result["code"];
    if (code != 0)
      onError(id, code);
    else
      onSuccess(id);
  }

  Future<List<RCRTCInputStream>> getLiveStreams() async {
    List<dynamic>? list = await _channel.invokeListMethod('getLiveStreams');
    List<RCRTCInputStream> streams = [];
    list?.forEach((element) {
      var stream = jsonDecode(element);
      if (stream['type'] == 0) {
        streams.add(RCRTCAudioInputStream.fromJson(stream));
      } else {
        streams.add(RCRTCVideoInputStream.fromJson(stream));
      }
    });
    return streams;
  }

  Future<String?> getSessionId() async {
    return _channel.invokeMethod('getSessionId');
  }
}
