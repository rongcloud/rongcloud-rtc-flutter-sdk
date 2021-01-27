import 'dart:async';
import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/module/audio_live/audio_live_view.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../global_config.dart';
import 'audio_live_page_contract.dart';

class AudioLivePageModel extends AbstractModel implements Model {
  @override
  Future<void> subscribe(
    void onUserJoined(AudioStreamView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserLeaved(String uid),
  ) async {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      AudioStreamView view = AudioStreamView(Data.User.unknown(user.id), name: true);
      List<RCRTCInputStream> subscribes = List();

      var audios = user.streamList.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) {
        var stream = audios.first;
        subscribes.add(stream);
        view.audioStream = stream;
      }

      localUser.subscribeStreams(subscribes);
      onUserJoined(view);
    }

    room.onRemoteUserJoined = (user) {
      AudioStreamView view = AudioStreamView(Data.User.unknown(user.id), name: true);
      onUserJoined(view);
    };

    room.onRemoteUserPublishResource = (user, streams) {
      List<RCRTCInputStream> subscribes = List();

      var audios = streams.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) {
        var stream = audios.first;
        subscribes.add(stream);
        onUserAudioStreamChanged(user.id, stream);
      }

      localUser.subscribeStreams(subscribes);
    };

    room.onRemoteUserUnPublishResource = (user, streams) {
      if (streams.whereType<RCRTCAudioInputStream>().isNotEmpty) {
        onUserAudioStreamChanged(user.id, null);
      }
    };

    room.onRemoteUserOffline = (user) {
      onUserLeaved(user.id);
    };

    room.onRemoteUserLeft = (user) {
      onUserLeaved(user.id);
    };
  }

  @override
  Future<StatusCode> publish(
    Data.Config config,
    void onUserJoined(AudioStreamView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
  ) async {
    String uid = RCRTCEngine.getInstance().getRoom().localUser.id;

    onUserJoined(AudioStreamView(Data.DefaultData.user, name: true));

    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();

    Completer<StatusCode> completer = Completer();
    RCRTCEngine.getInstance().getRoom().localUser.publishLiveStream(
      stream,
      (info) {
        onUserAudioStreamChanged(uid, stream);
        _requestCreateLiveRoom(Data.DefaultData.user, info.roomId, info.liveUrl);
        completer.complete(StatusCode(Status.ok, object: info));
      },
      (code, message) {
        completer.complete(StatusCode(Status.error, message: message));
      },
    );
    return completer.future;
  }

  void _requestCreateLiveRoom(Data.User user, String rid, String url) {
    Http.post(
      GlobalConfig.host + '/audio_room/$rid',
      {'user_id': user.id, 'user_name': user.name, 'mcu_url': url, 'key': GlobalConfig.appKey},
      (error, data) {
        print("_requestCreateLiveRoom success, error = $error, data = $data");
      },
      (error) {
        print("_requestCreateLiveRoom error, error = $error");
      },
      tag,
    );
  }

  @override
  void inviteMember(Data.User user) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {};
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.invite, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, user.id, textMessage);
  }

  @override
  void kickMember(Data.User user) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {};
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.kick, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, user.id, textMessage);
  }

  @override
  void acceptLink(Data.User user) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {
      'agree': true,
    };
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.link, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, user.id, textMessage);
  }

  @override
  void refuseLink(Data.User user) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {
      'agree': false,
    };
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.link, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, user.id, textMessage);
  }

  @override
  void sendMessage(
    String roomId,
    String message,
    void Function(Message message) onMessageSent,
  ) async {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.normal, message).toJSON());
    onMessageSent(await RongIMClient.sendMessage(RCConversationType.ChatRoom, roomId, textMessage));
  }

  Future<bool> switchCamera() async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return stream.switchCamera();
  }

  @override
  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  ) async {
    String roomId = RCRTCEngine.getInstance().getRoom().id;
    _requestLeaveLiveRoom(roomId);
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    int unPublishResult = await RCRTCEngine.getInstance().getRoom().localUser.unPublishStream(stream);
    int leaveResult = await RCRTCEngine.getInstance().leaveRoom();
    RongIMClient.quitChatRoom(roomId);

    RCRTCEngine.getInstance().unInit();
    RongIMClient.disconnect(false);

    if (unPublishResult == 0 && leaveResult == 0) {
      onSuccess(context);
    } else {
      onError(context, "exit error, unPublish code = $unPublishResult, leave code = $leaveResult");
    }
  }

  void _requestLeaveLiveRoom(String roomId) {
    print("_requestLeaveLiveRoom roomId = $roomId");
    Http.delete(
      GlobalConfig.host + '/audio_room/$roomId',
      {'key': GlobalConfig.appKey},
      (error, data) {
        print("_requestLeaveLiveRoom success, error = $error, data = $data");
      },
      (error) {
        print("_requestLeaveLiveRoom error, error = $error");
      },
      tag,
    );
  }
}
