import 'dart:async';
import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'live_audience_page_contract.dart';

class LiveAudiencePageModel extends AbstractModel implements Model {
  // @override
  // void initEngine() {
  //   RCRTCEngine.getInstance().init(null);
  // }

  @override
  void unInitEngine() {
    RCRTCEngine.getInstance().unInit();
  }

  @override
  void subscribeLiveStreams(
    Data.Room room,
    void Function(UserView view) onUserJoined,
  ) async {
    List<RCRTCInputStream> streams = await RCRTCEngine.getInstance().getRoom().getLiveStreams();
    RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(streams);

    UserView view = UserView(room.user);
    var audioStreams = streams.whereType<RCRTCAudioInputStream>();
    if (audioStreams.isNotEmpty) view.audioStream = audioStreams.first;
    var videoStreams = streams.whereType<RCRTCVideoInputStream>();
    if (videoStreams.isNotEmpty) view.videoStream = videoStreams.first;
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

  // void subscribeUrl(
  //   Data.Room room,
  //   void onUserJoined(UserView view),
  //   void onSubscribeError(int code, String message),
  // ) {
  //   RCRTCEngine.getInstance().subscribeLiveStream(
  //     url: room.url,
  //     streamType: AVStreamType.audio_video,
  //     onSuccess: () {},
  //     onAudioStreamReceived: (stream) {},
  //     onVideoStreamReceived: (stream) {
  //       UserView view = UserView(room.user);
  //       view.videoStream = stream;
  //       onUserJoined(view);
  //     },
  //     onError: (code, message) {
  //       onSubscribeError(code, message);
  //     },
  //   );
  // }

  @override
  Future<bool> requestPermission() async {
    bool camera = await Permission.camera.request().isGranted;
    bool mic = await Permission.microphone.request().isGranted;
    return camera && mic;
  }

  // @override
  // Future<bool> unsubscribeUrl(Data.Room room) async {
  //   int code = await RCRTCEngine.getInstance().unsubscribeLiveStream(room.url);
  //   return code == 0;
  // }

  @override
  Future<StatusCode> joinRoom(Data.Room room) async {
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: room.id,
      roomConfig: RCRTCRoomConfig(RCRTCRoomType.Live, RCRTCLiveType.AudioVideo, RCRTCLiveRoleType.Broadcaster),
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
    void Function(UserView view) onUserJoined,
    void Function(String uid, dynamic stream) onUserAudioStreamChanged,
    void Function(String uid, dynamic stream) onUserVideoStreamChanged,
    void Function(String uid) onUserLeaved,
  ) {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      UserView view = UserView(Data.User.unknown(user.id));
      List<RCRTCInputStream> subscribes = List();

      var audios = user.streamList.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) {
        var stream = audios.first;
        subscribes.add(stream);
        view.audioStream = stream;
      }

      var videos = user.streamList.whereType<RCRTCVideoInputStream>();
      if (videos.isNotEmpty) {
        var stream = videos.first;
        subscribes.add(stream);
        view.videoStream = stream;
      }

      localUser.subscribeStreams(subscribes);
      onUserJoined(view);
    }

    room.onRemoteUserJoined = (user) {
      UserView view = UserView(Data.User.unknown(user.id));
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

      var videos = streams.whereType<RCRTCVideoInputStream>();
      if (videos.isNotEmpty) {
        var stream = videos.first;
        subscribes.add(stream);
        onUserVideoStreamChanged(user.id, stream);
      }

      localUser.subscribeStreams(subscribes);
    };

    room.onRemoteUserUnPublishResource = (user, streams) {
      if (streams.whereType<RCRTCAudioInputStream>().isNotEmpty) {
        onUserAudioStreamChanged(user.id, null);
      }

      if (streams.whereType<RCRTCVideoInputStream>().isNotEmpty) {
        onUserVideoStreamChanged(user.id, null);
      }
    };

    room.onRemoteUserOffline = (user) {
      onUserLeaved(user.id);
    };

    room.onRemoteUserLeft = (user) {
      onUserLeaved(user.id);
    };
  }

  Future<StatusCode> publish(
    Data.Config config,
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) {
    UserView view = UserView(Data.DefaultData.user);
    onUserJoined(view);

    RCRTCEngine.getInstance().getDefaultAudioStream().then((stream) {
      stream.mute(!config.mic);
      onUserAudioStreamChanged(Data.DefaultData.user.id, stream);
    });

    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) {
      stream.setVideoConfig(config.videoConfig);
      if (config.camera) stream.startCamera();
      onUserVideoStreamChanged(Data.DefaultData.user.id, stream);
    });

    Completer<StatusCode> completer = Completer();
    RCRTCEngine.getInstance().getRoom().localUser.publishDefaultLiveStreams(
      (info) {
        completer.complete(StatusCode(Status.ok, object: info));
      },
      (code, message) {
        completer.complete(StatusCode(Status.error, message: message));
      },
    );
    return completer.future;
  }

  Future<bool> switchCamera() async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return stream.switchCamera();
  }

  Future<void> changeAudioStreamState(
    Data.Config config,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    bool enable = config.mic;
    enable = !enable;
    enable ? localUser.publishLiveStream(stream, (liveInfo) {}, (code, message) {}) : localUser.unPublishStream(stream);
    onUserAudioStreamChanged(localUser.id, enable ? stream : null);
  }

  Future<void> changeVideoStreamState(
    Data.Config config,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    bool enable = config.camera;
    enable = !enable;
    if (enable) {
      stream.setVideoConfig(config.videoConfig);
      stream.startCamera();
      localUser.publishLiveStream(stream, (liveInfo) {}, (code, message) {});
      onUserVideoStreamChanged(localUser.id, stream);
    } else {
      localUser.unPublishStream(stream);
      stream.stopCamera();
      onUserVideoStreamChanged(localUser.id, null);
    }
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
      roomConfig: RCRTCRoomConfig(RCRTCRoomType.Live, RCRTCLiveType.AudioVideo, RCRTCLiveRoleType.Audience),
    );
    joined = result.code != 0;
    return joined;
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
    // else
    // result = await RCRTCEngine.getInstance().unsubscribeLiveStream(room.url);
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
