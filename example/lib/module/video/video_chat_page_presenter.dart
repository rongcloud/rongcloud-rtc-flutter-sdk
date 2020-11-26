import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/module/video/video_chat_page_model.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class VideoChatPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return VideoChatPageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    subscribe();
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
      () {
        this.view?.invalidate();
      },
    );
  }

  void publish(Config config) async {
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
  Future<bool> switchCamera() {
    return model?.switchCamera();
  }

  @override
  Future<bool> changeAudioStreamState(Config config) {
    return model?.changeAudioStreamState(config);
  }

  @override
  Future<bool> changeVideoStreamState(Config config) {
    return model?.changeVideoStreamState(
      config,
      (view) {
        this.view?.onViewCreated(view);
      },
      (userId) {
        this.view?.onRemoveView(userId);
      },
    );
  }

  @override
  void changeRemoteAudioSubscribeState(bool unsubscribe) {
    model?.changeRemoteAudioSubscribeState(unsubscribe);
  }

  @override
  Future<StatusCode> exit() {
    return model?.exit();
  }

  @override
  List<RemoteUserStatus> getUserList() {
    return model?.getUserList();
  }

  @override
  Future<bool> changeRemoteAudioStreamState(RemoteUserStatus user) {
    return model?.changeRemoteAudioStreamState(user);
  }

  @override
  Future<bool> changeRemoteVideoStreamState(RemoteUserStatus user) {
    return model?.changeRemoteVideoStreamState(user);
  }

  @override
  void setCameraCaptureOrientation(RCRTCCameraCaptureOrientation rotation) {
    model?.setCameraCaptureOrientation(rotation);
  }
}
