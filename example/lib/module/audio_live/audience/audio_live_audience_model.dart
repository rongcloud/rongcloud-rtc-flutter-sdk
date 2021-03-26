import 'dart:async';
import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../audio_live_view.dart';
import 'audio_live_audience_contract.dart';

class AudioLiveAudienceModel extends AbstractModel implements Model {
//  @override
//  void initEngine() {
//    RCRTCEngine.getInstance().init(null);
//  }

  @override
  void unInitEngine() {
    RCRTCEngine.getInstance().unInit();
  }

  @override
  void subscribeLiveStreams(
    Data.Room room,
    void onUserJoined(AudioStreamView view),
  ) async {
    List<RCRTCInputStream> streams = await RCRTCEngine.getInstance().getRoom().getLiveStreams();
    RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(streams);
    AudioStreamView view = AudioStreamView(room.user, name: true);
    var audioStreams = streams.whereType<RCRTCAudioInputStream>();
    if (audioStreams.isNotEmpty) view.audioStream = audioStreams.first;
    var videoStreams = streams.whereType<RCRTCVideoInputStream>();
    if (videoStreams.isNotEmpty) view.audioStream = videoStreams.first;
    onUserJoined(view);
  }

  @override
  void sendMessage(
    String roomId,
    String message,
    void onMessageSent(Message message),
  ) async {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.normal, message).toJSON());
    onMessageSent(await RongIMClient.sendMessage(RCConversationType.ChatRoom, roomId, textMessage));
  }

  @override
  void refuseInvite(Data.Room room) {
    _sendInviteMessage(false, room.user.id);
  }

  @override
  void agreeInvite(Data.Room room) {
    _sendInviteMessage(true, room.user.id);
  }

  void _sendInviteMessage(bool agree, String uid) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {
      'agree': agree,
    };
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.invite, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, uid, textMessage);
  }

  @override
  void requestLink(Data.Room room) {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.link, '').toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, room.user.id, textMessage);
  }

//  @override
//  void subscribeUrl(
//    Data.Room room,
//    void onUserJoined(AudioStreamView view),
//    void onSubscribeError(int code, String message),
//  ) {
//    RCRTCEngine.getInstance().subscribeLiveStream(
//      url: room.url,
//      streamType: AVStreamType.audio,
//      onSuccess: () {},
//      onAudioStreamReceived: (stream) {
//        AudioStreamView view = AudioStreamView(room.user, name: true);
//        onUserJoined(view);
//      },
//      onVideoStreamReceived: (stream) {},
//      onError: (code, message) {
//        onSubscribeError(code, message);
//      },
//    );
//  }

  @override
  Future<bool> requestPermission() async {
    bool camera = await Permission.camera.request().isGranted;
    bool mic = await Permission.microphone.request().isGranted;
    return camera && mic;
  }

//  @override
//  Future<bool> unsubscribeUrl(Data.Room room) async {
//    int code = await RCRTCEngine.getInstance().unsubscribeLiveStream(room.url);
//    return code == 0;
//  }

  @override
  Future<StatusCode> joinRoom(Data.Room room) async {
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: room.id,
      roomConfig: RCRTCRoomConfig(RCRTCRoomType.Live, RCRTCLiveType.Audio, RCRTCLiveRoleType.Broadcaster),
    );
    if (result.code != 0) {
      joined = false;
      return StatusCode(Status.error, message: 'code = ${result.code}, reason = ${result.reason}');
    } else {
      joined = true;
      return StatusCode(Status.ok);
    }
  }

  @override
  void subscribe(
    void Function(AudioStreamView view) onUserJoined,
    void Function(String uid, dynamic stream) onUserAudioStreamChanged,
    void Function(String uid) onUserLeaved,
  ) {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      onUserJoined(AudioStreamView(Data.User.unknown(user.id)));

      List<RCRTCInputStream> subscribes = List();

      var audios = user.streamList.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) {
        var stream = audios.first;
        subscribes.add(stream);
        onUserAudioStreamChanged(user.id, stream);
      }

      localUser.subscribeStreams(subscribes);
    }

    room.onRemoteUserJoined = (user) {
      onUserJoined(AudioStreamView(Data.User.unknown(user.id)));
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
    onUserJoined(AudioStreamView(Data.DefaultData.user, name: true));

    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    stream.mute(!config.mic);
    onUserAudioStreamChanged(Data.DefaultData.user.id, stream);

    Completer<StatusCode> completer = Completer();
    RCRTCEngine.getInstance().getRoom().localUser.publishLiveStream(
      stream,
      (info) {
        completer.complete(StatusCode(Status.ok, object: info));
      },
      (code, message) {
        completer.complete(StatusCode(Status.error, message: message));
      },
    );
    return completer.future;
  }

  @override
  Future<bool> leaveLink() async {
    int result = await RCRTCEngine.getInstance().leaveRoom();
    joined = result != 0;
    return !joined;
  }

  @override
  Future<bool> autoJoinRoom(String roomId) async {
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: roomId,
      roomConfig: RCRTCRoomConfig(RCRTCRoomType.Live, RCRTCLiveType.Audio, RCRTCLiveRoleType.Audience),
    );
    joined = result.code != 0;
    return !joined;
  }

  @override
  void exit(
    BuildContext context,
    Data.Room room,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  ) async {
    int result = 0;
//    if (joined)
    result = await RCRTCEngine.getInstance().leaveRoom();
//    else
//      result = await RCRTCEngine.getInstance().unsubscribeLiveStream(room.url);
    RongIMClient.quitChatRoom(room.id);
    RongIMClient.disconnect(false);
    if (result > 0) {
      onError(context, "exit has some error");
    } else {
      onSuccess(context);
    }
  }

  bool joined = false;
}
