import 'dart:convert';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/material.dart';
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
  void init(BuildContext context) {
    requestPermission();
    RCRTCEngine
        .getInstance()
        .room
        .onRemoteUserPublishResource = (user, streams) => _onRemoteUserPublishResource(user, streams);
    RCRTCEngine
        .getInstance()
        .room
        .onRemoteUserUnpublishResource = (user, streams) => _onRemoteUserLeft(user);
    RCRTCEngine
        .getInstance()
        .room
        .onRemoteUserLeft = (user) => _onRemoteUserLeft(user);
    RongIMClient.onMessageReceived = (message, left) => _onMessageReceived(message, left);
  }

  @override
  void requestPermission() {
    model?.requestPermission(() {
      view?.onPermissionGranted();
    }, (camera, mic) {
      view?.onPermissionDenied(camera, mic);
    });
  }

  void _onRemoteUserPublishResource(RCRTCRemoteUser user, List<RCRTCInputStream> streams) {
    RCRTCEngine
        .getInstance()
        .room
        .localUser
        .subscribeStreams(streams);
    streams.forEach((stream) {
      if (stream.type == MediaType.video) {
        RCRTCVideoView videoView = RCRTCVideoView(
          onCreated: (videoView, id) {
            (stream as RCRTCVideoInputStream).setVideoView(videoView, id);
          },
          viewType: RCRTCViewType.remote,
        );
        view?.onCreateRemoteView(user.id, videoView);
        return;
      }
    });
  }

  void _onRemoteUserLeft(RCRTCRemoteUser user) {
    view?.onReleaseRemoteView(user.id);
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
        LiveType type = LiveType.values[data['type']];
        view?.onMemberInvited(msg.user, agree, type);
        break;
      case MessageType.kick: // 断线
        break;
      case MessageType.error: // 发生错误
        break;
    }
  }

  @override
  void requestCameraPermission() {
    model?.requestCameraPermission(() {
      view?.onCameraPermissionGranted();
    }, () {
      view?.onCameraPermissionDenied();
    });
  }

  @override
  void requestMicPermission() {
    model?.requestMicPermission(() {
      view?.onMicPermissionGranted();
    }, () {
      view?.onMicPermissionDenied();
    });
  }

  @override
  void initVideoView() async {
    model?.initVideoView(
          (videoView) {
        view?.onVideoViewReady(videoView);
      },
          () {
        push();
      },
    );
  }

  @override
  void push() async {
    model?.push(
          () {
        view?.onPushed();
      },
          (info) {
        view?.onPushError(info);
      },
    );
  }

  @override
  void requestMemberList() {
    model?.requestMemberList();
  }

  @override
  void inviteMember(Data.User user, LiveType type) {
    model?.inviteMember(user, type);
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

  @override
  void muteMicrophone() {
    model?.muteMicrophone((state) {
      view?.onMicrophoneStatusChanged(state);
    });
  }

  @override
  void switchCamera() {
    model?.switchCamera((isFront) {
      view?.onCameraStatusChanged(isFront);
    });
  }

  @override
  void setMirror() {
    model?.setMirror((state) {
      view?.onCameraMirrorChanged(state);
    });
  }
}
