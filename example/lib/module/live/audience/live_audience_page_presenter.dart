import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/module/live/audience/live_audience_page_model.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'live_audience_page_contract.dart';

class LiveAudiencePagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return LiveAudiencePageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _room = Data.Room.fromJSON(arguments);
    model?.initEngine();

    subscribe();

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

    bool unsubscribed = await model?.unsubscribeUrl(_room);
    if (!unsubscribed) return _joinError(MessageError.unsubscribe_error);

    StatusCode joinCode = await model?.joinRoom(_room);
    if (joinCode.status != Status.ok) return _joinError(MessageError.join_error);

    model?.subscribe(
      (view) {
        this.view?.onUserJoined(view);
      },
      (uid, stream) {
        this.view?.onUserAudioStreamChanged(uid, stream);
      },
      (uid, stream) {
        this.view?.onUserVideoStreamChanged(uid, stream);
      },
      (uid) {
        this.view?.onUserLeaved(uid);
      },
    );

    model?.publish(
      config,
      (view) {
        this.view?.onUserJoined(view);
      },
      (uid, stream) {
        this.view?.onUserAudioStreamChanged(uid, stream);
      },
      (uid, stream) {
        this.view?.onUserVideoStreamChanged(uid, stream);
      },
    );

    this.view?.onJoined();
  }

  void _joinError(MessageError error) {
    view?.onJoinError();
    _sendErrorMessage(_room.user.id, error);
  }

  void _sendErrorMessage(String uid, MessageError error) {}

  @override
  void subscribe() {
    model?.subscribeUrl(
      _room,
      (view) {
        this.view?.onUserJoined(view);
      },
      (code, message) {
        this.view?.onSubscribeUrlError(code, message);
      },
    );
  }

  @override
  Future<bool> switchCamera() {
    return model?.switchCamera();
  }

  @override
  void changeAudioStreamState(Data.Config config) {
    model?.changeAudioStreamState(config, (uid, stream) {
      view?.onUserAudioStreamChanged(uid, stream);
    });
  }

  @override
  void changeVideoStreamState(Data.Config config) {
    model?.changeVideoStreamState(config, (uid, stream) {
      view?.onUserVideoStreamChanged(uid, stream);
    });
  }

  @override
  Future<bool> leaveLink() {
    return model?.leaveLink();
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
