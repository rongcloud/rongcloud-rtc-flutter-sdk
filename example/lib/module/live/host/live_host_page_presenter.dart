import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'live_host_page_contract.dart';
import 'live_host_page_model.dart';

class LiveHostPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return LiveHostPageModel();
  }

  @override
  void detachView() {
    RongIMClient.onMessageReceived = null;
    super.detachView();
  }

  @override
  Future<void> init(BuildContext context) async {
    RongIMClient.onMessageReceived = (message, left) => _onMessageReceived(message, left);
    subscribe();
  }

  void _onMessageReceived(Message message, int left) {
    String content = message.content.conversationDigest();
    Data.Message msg = Data.Message.fromJSON(jsonDecode(content));
    switch (msg.type) {
      case MessageType.normal:
        view?.onReceiveMessage(msg);
        break;
      case MessageType.request_list:
        view?.onReceiveMember(msg.user);
        break;
      case MessageType.invite:
        Map<String, dynamic> data = jsonDecode(msg.message);
        bool agree = data['agree'];
        view?.onMemberInvited(msg.user, agree);
        break;
      case MessageType.kick: // 断线
        break;
      case MessageType.error: // 发生错误
        break;
    }
  }

  @override
  void subscribe() {
    model?.subscribe(
      (view) {
        this.view?.onViewCreated(view);
      },
      (userId) {
        this.view?.onRemoveView(userId);
      },
      (userId) {
        this.view?.onMemberJoined(userId);
      },
    );
  }

  @override
  void publish(Data.Config config) async {
    StatusCode code = await model?.publish(
      config,
      (view) {
        this.view?.onViewCreated(view);
      },
    );
    if (code.status == Status.ok) {
      view?.onPublished();
    } else {
      view?.onPublishError(code.message);
    }
  }

  @override
  void requestMemberList() {
    model?.requestMemberList();
  }

  @override
  void inviteMember(Data.User user) {
    model?.inviteMember(user);
  }

  @override
  void exit(BuildContext context) {
    model?.exit(
      context,
      (context) {
        view?.onExit(context);
      },
      (context, info) {
        view?.onExitWithError(context, info);
      },
    );
  }
}
