import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_engine.dart';
import 'package:rongcloud_rtc_plugin/agent/room/rcrtc_room.dart';

import 'audio_live_audience_contract.dart';
import 'audio_live_audience_model.dart';

class AudioLiveAudiencePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return AudioLiveAudienceModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _room = Data.Room.fromJSON(arguments);
//    model?.initEngine();

//    subscribe();

    RCRTCRoom liveRoom = RCRTCEngine.getInstance().getRoom();
    //单独订阅主播流
    liveRoom.onPublishLiveStreams = (streams) {
      liveRoom.localUser.subscribeStreams(streams);
    };

    liveRoom.onUnPublishLiveStreams = (streams) {
      liveRoom.localUser.unsubscribeStreams(streams);
    };

    RongIMClient.onMessageReceived = (message, left) => _onMessageReceived(message, left);

    _sendJoinMessage();
  }

  void _onMessageReceived(Message message, int left) {
    String content = message.content.conversationDigest();
    Data.Message msg = Data.Message.fromJSON(jsonDecode(content));
    switch (msg.type) {
      case MessageType.normal:
      case MessageType.join:
      case MessageType.left:
        view?.onReceiveMessage(msg);
        break;
      case MessageType.invite:
        view?.onReceiveInviteMessage();
        break;
      case MessageType.link:
        Map<String, dynamic> data = jsonDecode(msg.message);
        bool agree = data['agree'];
        view?.onRequestLinkResult(agree);
        break;
      case MessageType.kick: // 被断线
        view?.onReceiveKickMessage();
        break;
      default: // 不处理
        break;
    }
  }

  void _sendJoinMessage() {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.join, '').toJSON());
    RongIMClient.sendMessage(RCConversationType.ChatRoom, _room.id, textMessage);
  }

  @override
  void detachView() {
    model?.unInitEngine();
    RongIMClient.onMessageReceived = null;
    super.detachView();
  }

  @override
  void subscribeLiveStreams() async {
    model?.subscribeLiveStreams(_room, (view) {
      this.view?.onUserJoined(view);
    });
  }

  @override
  void sendMessage(String message) {
    model?.sendMessage(
      _room.id,
      message,
      (message) {
        _onMessageReceived(message, 0);
      },
    );
  }

  @override
  void refuseInvite() {
    model?.refuseInvite(_room);
  }

  @override
  Future<void> agreeInvite(Data.Config config) async {
    model?.agreeInvite(_room);

    bool hasPermission = await model?.requestPermission();
    if (!hasPermission) return _joinError(MessageError.no_permission);

//    bool unsubscribed = await model?.unsubscribeUrl(_room);
//    if (!unsubscribed) return _joinError(MessageError.unsubscribe_error);
    int code = await RCRTCEngine.getInstance().leaveRoom();
    if (code != 0) return _joinError(MessageError.unsubscribe_error);

    StatusCode joinCode = await model?.joinRoom(_room);
    if (joinCode.status != Status.ok) return _joinError(MessageError.join_error);

    model?.subscribe(
      (user) {
        this.view?.onUserJoined(user);
      },
      (uid, stream) {
        this.view?.onUserAudioStreamChanged(uid, stream);
      },
      (uid) {
        this.view?.onUserLeaved(uid);
      },
    );

    model?.publish(
      config,
      (user) {
        this.view?.onUserJoined(user);
      },
      (uid, stream) {
        this.view?.onUserAudioStreamChanged(uid, stream);
      },
    );

    this.view?.onJoined();
  }

  @override
  void requestLink() {
    model?.requestLink(_room);
  }

  void _joinError(MessageError error) {
    view?.onJoinError();
    _sendErrorMessage(_room.user.id, error);
  }

  void _sendErrorMessage(String uid, MessageError error) {}

//  @override
//  void subscribe() {
//    model?.subscribeUrl(
//      _room,
//      (view) {
//        this.view?.onUserJoined(view);
//      },
//      (code, message) {
//        this.view?.onSubscribeUrlError(code, message);
//      },
//    );
//  }

  @override
  Future<bool> leaveLink() {
    return model?.leaveLink();
  }

  @override
  Future<bool> autoJoinRoom(String roomId) {
    return model?.autoJoinRoom(roomId);
  }

  @override
  void exit(BuildContext context) {
    _sendLeftMessage();
    model?.exit(
      context,
      _room,
      (context) {
        view?.onExit(context);
      },
      (context, info) {
        view?.onExitWithError(context, info);
      },
    );
  }

  void _sendLeftMessage() {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.left, '').toJSON());
    RongIMClient.sendMessage(RCConversationType.ChatRoom, _room.id, textMessage);
  }

  Data.Room _room;
}
