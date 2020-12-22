import 'dart:async';
import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'live_host_page_contract.dart';

class LiveHostPageModel extends AbstractModel implements Model {
  @override
  Future<void> subscribe(
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
    void onUserLeaved(String uid),
  ) async {
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

    room.onRemoteUserLeft = (user) {
      onUserLeaved(user.id);
    };
  }

  @override
  Future<StatusCode> publish(
    Data.Config config,
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) async {
    List<RCRTCOutputStream> streams = List();
    String uid = RCRTCEngine.getInstance().getRoom().localUser.id;

    onUserJoined(UserView(Data.DefaultData.user));

    if (config.mic) {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      streams.add(stream);
      onUserAudioStreamChanged(uid, stream);
    }

    if (config.camera) {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      stream.setVideoConfig(config.videoConfig);
      stream.startCamera();
      streams.add(stream);
      onUserVideoStreamChanged(uid, stream);
    }

    Completer<StatusCode> completer = Completer();
    bool callback = false;
    int count = streams.length;
    streams.forEach((stream) async {
      StatusCode code = await _publish(stream);
      count--;
      if (code.status == Status.ok && !callback) {
        callback = true;
        completer.complete(code);
        _liveInfo = code.object;
        _requestCreateLiveRoom(Data.DefaultData.user, code.object.roomId, code.object.liveUrl);
      } else if (!callback && count <= 0) {
        callback = true;
        completer.complete(code);
      }
    });
    return completer.future;
  }

  Future<StatusCode> _publish(RCRTCOutputStream stream) {
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

  void _requestCreateLiveRoom(Data.User user, String rid, String url) {
    Http.post(
      GlobalConfig.host + '/live_room/$rid',
      {'user_id': user.id, 'user_name': user.name, 'mcu_url': url},
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

  @override
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
  Future<void> changeRemoteAudioStreamState(
    UserView view,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    if (view.audio) {
      await localUser.unsubscribeStream(view.audioStream);
      onUserAudioStreamChanged(view.user.id, null);
    } else {
      await localUser.subscribeStream(view.audioStream);
      onUserAudioStreamChanged(view.user.id, view.audioStream);
    }
  }

  @override
  Future<void> changeRemoteVideoStreamState(
    UserView view,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    if (view.video) {
      await localUser.unsubscribeStream(view.videoStream);
      onUserVideoStreamChanged(view.user.id, null);
    } else {
      await localUser.subscribeStream(view.videoStream);
      onUserVideoStreamChanged(view.user.id, view.videoStream);
    }
  }

  @override
  void changeMixConfig(RCRTCMixConfig config) {
    _liveInfo?.setMixConfig(config);
  }

  @override
  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  ) async {
    String roomId = RCRTCEngine.getInstance().getRoom().id;
    _requestLeaveLiveRoom(roomId);
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    int unPublishResult = await RCRTCEngine.getInstance().getRoom().localUser.unPublishStreams(await localUser.getStreams());
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
      GlobalConfig.host + '/live_room/$roomId',
      null,
      (error, data) {
        print("_requestLeaveLiveRoom success, error = $error, data = $data");
      },
      (error) {
        print("_requestLeaveLiveRoom error, error = $error");
      },
      tag,
    );
  }

  RCRTCLiveInfo _liveInfo;
}
