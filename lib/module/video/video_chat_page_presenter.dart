import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/module/video/video_chat_page_model.dart';
import 'package:FlutterRTC/widgets/video_view.dart';
import 'package:flutter/widgets.dart';

class VideoChatPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return VideoChatPageModel();
  }

  @override
  void init(BuildContext context) {
    requestPermission();
    pull();
  }

  @override
  void requestPermission() async {
    PermissionStatus status = await model?.requestPermission();
    view?.onPermissionStatus(status);
  }

  @override
  void requestCameraPermission() async {
    PermissionStatus status = await model?.requestCameraPermission();
    view?.onPermissionStatus(status);
  }

  @override
  void requestMicPermission() async {
    PermissionStatus status = await model?.requestMicPermission();
    view?.onPermissionStatus(status);
  }

  @override
  void createVideoView() {
    model?.createVideoView(
      (view) {
        this.view?.onVideoViewCreated(view);
      },
      () {
        push();
      },
    );
  }

  @override
  void push() async {
    StatusCode code = await model?.push();
    if (code.status == Status.ok) {
      view?.onPushed();
    } else {
      view?.onPushError(code.message);
    }
  }

  @override
  void pull() {
    model?.pull(
      (view) {
        this.view?.onVideoViewCreated(view);
      },
      (userId) {
        this.view?.onRemoveVideoView(userId);
      },
    );
  }

  @override
  void switchCamera() {
    model?.switchCamera();
  }

  @override
  Future<bool> changeAudioStreamState() {
    return model?.changeAudioStreamState();
  }

  @override
  Future<bool> changeVideoStreamState() {
    return model?.changeVideoStreamState(
      (view) {
        this.view?.onVideoViewCreated(view);
      },
      (userId) {
        this.view?.onRemoveVideoView(userId);
      },
    );
  }

  @override
  Future<StatusCode> exit() {
    return model?.exit();
  }
}