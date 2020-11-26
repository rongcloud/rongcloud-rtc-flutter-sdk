import 'dart:async';
import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../global_config.dart';
import 'live_host_page_contract.dart';

class LiveHostPageModel extends AbstractModel implements Model {
  @override
  void subscribe(
    void Function(VideoStreamWidget view) onViewCreated,
    void Function(String userId) onRemoveView,
    void Function(String userId) onMemberJoined,
  ) {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    room.onRemoteUserJoined = (user) {
      onMemberJoined(user.id);
    };

    room.onRemoteUserPublishResource = (user, streams) {
      localUser.subscribeStreams(streams);
      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onViewCreated(VideoStreamWidget(Data.User.unknown(user.id), stream));
      });
    };

    room.onRemoteUserUnPublishResource = (user, streams) {
      localUser.unsubscribeStreams(streams);

      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onRemoveView(user.id);
      });
    };

    room.onRemoteUserLeft = (user) {
      onRemoveView(user.id);
    };
  }

  @override
  Future<StatusCode> publish(
    Data.Config config,
    void Function(VideoStreamWidget view) onViewCreated,
  ) async {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    RCRTCCameraOutputStream vos = await RCRTCEngine.getInstance().getDefaultVideoStream();
    vos.setVideoConfig(Data.DefaultData.videoConfig);
    if (config.camera) vos.startCamera();
    onViewCreated(VideoStreamWidget(Data.User.unknown(localUser.id), vos));

    RCRTCMicOutputStream aos = await RCRTCEngine.getInstance().getDefaultAudioStream();
    aos.mute(!config.mic);

    Completer<StatusCode> completer = Completer();
    localUser.publishDefaultLiveStreams(
      (info) {
        completer.complete(StatusCode(Status.ok, object: info));
        _requestCreateLiveRoom(info.userId, info.roomId, info.liveUrl);
      },
      (code, message) {
        completer.complete(StatusCode(Status.error, message: message));
      },
    );
    return completer.future;
  }

  void _requestCreateLiveRoom(String userId, String roomId, String url) {
    Http.post(
      GlobalConfig.host + '/live_room/$roomId',
      {'user_id': userId, 'mcu_url': url},
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
  void requestMemberList() async {
    String roomId = RCRTCEngine.getInstance().getRoom().id;
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.request_list, "").toJSON());
    RongIMClient.sendMessage(RCConversationType.ChatRoom, roomId, textMessage);
  }

  @override
  void inviteMember(Data.User user) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {};
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.invite, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, user.id, textMessage);
  }

  @override
  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  ) async {
    String roomId = RCRTCEngine.getInstance().getRoom().id;
    _requestLeaveLiveRoom(roomId);

    RongIMClient.quitChatRoom(roomId);
    int code = await RCRTCEngine.getInstance().leaveRoom();

    RCRTCEngine.getInstance().unInit();
    RongIMClient.disconnect(false);

    if (code == 0) {
      onSuccess(context);
    } else {
      onError(context, "exit error, code = $code");
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
}
