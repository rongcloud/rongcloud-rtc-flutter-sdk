import 'dart:convert';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/module/live/audience/live_audience_page_model.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'live_audience_page_contract.dart';

class LiveAudiencePagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return LiveAudiencePageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _roomId = arguments['roomId'];
    _url = arguments['url'];
    model?.initEngine();
    pull();
    RongIMClient.onMessageReceived = (message, left) => _onMessageReceived(message, left);
  }

  @override
  void detachView() {
    model?.unInitEngine();
    RongIMClient.onMessageReceived = null;
    super.detachView();
  }

  @override
  void pull() {
    model?.pull(
      _url,
      (videoView) {
        view?.onPulled(videoView);
      },
      (code, message) {
        view?.onPullError(code, message);
      },
    );
  }

  void _onMessageReceived(Message message, int left) {
    String content = message.content.conversationDigest();
    Data.Message msg = Data.Message.fromJSON(jsonDecode(content));
    switch (msg.type) {
      case MessageType.normal:
        view?.onReceiveMessage(msg);
        break;
      case MessageType.request_list:
        _sendRequestListMessage(msg.user.id);
        break;
      case MessageType.invite:
        view?.onReceiveInviteMessage(msg.user);
        break;
      case MessageType.kick: // 被断线
        break;
      case MessageType.error: // 这个消息对于观众来讲不存在
        break;
    }
  }

  @override
  void sendMessage(String message) {
    model?.sendMessage(
      _roomId,
      message,
      (message) {
        _onMessageReceived(message, 0);
      },
    );
  }

  void _sendRequestListMessage(String uid) {
    model?.sendRequestListMessage(uid);
  }

  @override
  void refuseInvite(Data.User user) {
    model?.refuseInvite(user);
  }

  @override
  void agreeInvite(
    Data.User user,
    void onVideoViewReady(RCRTCTextureView videoView),
    void onRemoteVideoViewReady(String uid, RCRTCTextureView videoView),
    void onRemoteVideoViewClose(String uid),
  ) {
    model?.agreeInvite(
      user,
      _roomId,
      _url,
      onVideoViewReady,
      onRemoteVideoViewReady,
      onRemoteVideoViewClose,
    );
  }

  @override
  void exit(BuildContext context) {
    model?.exit(
      context,
      _roomId,
      _url,
      (context) {
        view?.onExit(context);
      },
      (context, info) {
        view?.onExitWithError(context, info);
      },
    );
  }

  String _roomId;
  String _url;
}
