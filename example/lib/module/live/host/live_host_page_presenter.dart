import 'dart:convert';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_engine.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

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
      case MessageType.join:
        view?.onAudienceJoined(msg.user);
        view?.onReceiveMessage(msg);
        break;
      case MessageType.left:
        view?.onAudienceLeft(msg.user);
        view?.onReceiveMessage(msg);
        break;
      case MessageType.invite:
        Map<String, dynamic> data = jsonDecode(msg.message);
        bool agree = data['agree'];
        view?.onMemberInvited(msg.user, agree);
        break;
      case MessageType.error: // 发生错误
        break;
      default:
        break;
    }
  }

  @override
  void subscribe() {
    model?.subscribe(
      (view) {
        this.view?.onUserJoined(view);
      },
      (uid, audio) {
        this.view?.onUserAudioStreamChanged(uid, audio);
      },
      (uid, stream) {
        this.view?.onUserVideoStreamChanged(uid, stream);
      },
      (uid) {
        this.view?.onUserLeaved(uid);
      },
    );
  }

  @override
  void publish(Data.Config config) async {
    StatusCode code = await model?.publish(
      config,
      (view) {
        this.view?.onUserJoined(view);
      },
      (uid, audio) {
        view?.onUserAudioStreamChanged(uid, audio);
      },
      (uid, stream) {
        view?.onUserVideoStreamChanged(uid, stream);
      },
    );
    if (code.status == Status.ok) {
      view?.onPublished();
    } else {
      view?.onPublishError(code.message);
    }
  }

  @override
  void inviteMember(Data.User user) {
    model?.inviteMember(user);
  }

  @override
  void kickMember(Data.User user) {
    model?.kickMember(user);
  }

  @override
  void sendMessage(String message) {
    String id = RCRTCEngine.getInstance().getRoom().id;
    model?.sendMessage(
      id,
      message,
      (message) {
        _onMessageReceived(message, 0);
      },
    );
  }

  @override
  Future<bool> switchCamera() {
    return model?.switchCamera();
  }

  @override
  void changeAudioStreamState(Data.Config config) {
    model?.changeAudioStreamState(config, (uid, audio) {
      view?.onUserAudioStreamChanged(uid, audio);
    });
  }

  @override
  void changeVideoStreamState(Data.Config config) {
    model?.changeVideoStreamState(config, (uid, stream) {
      view?.onUserVideoStreamChanged(uid, stream);
    });
  }

  @override
  void changeRemoteAudioStreamState(UserView view) {
    model?.changeRemoteAudioStreamState(view, (uid, audio) {
      this.view?.onUserAudioStreamChanged(uid, audio);
    });
  }

  @override
  void changeRemoteVideoStreamState(UserView view) {
    model?.changeRemoteVideoStreamState(view, (uid, stream) {
      this.view?.onUserVideoStreamChanged(uid, stream);
    });
  }

  @override
  void changeMixConfig(RCRTCMixConfig config) {
    model?.changeMixConfig(config);
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
