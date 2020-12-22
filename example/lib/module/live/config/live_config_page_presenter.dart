import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';

import 'live_config_page_contract.dart';
import 'live_config_page_model.dart';

class LiveConfigPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return LiveConfigPageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    connectIM();
  }

  @override
  Future<void> connectIM() async {
    bool success = await model?.connectIM();
    if (success)
      view?.onIMConnected();
    else
      view?.onIMConnectError();
  }

  @override
  void requestPermission() {
    model?.requestPermission(
      () {
        view?.onPermissionGranted();
      },
      (camera, mic) {
        view?.onPermissionDenied(camera, mic);
      },
    );
  }

  @override
  void requestCameraPermission() {
    model?.requestCameraPermission(
      () {
        view?.onCameraPermissionGranted();
      },
      () {
        view?.onCameraPermissionDenied();
      },
    );
  }

  @override
  void requestMicPermission() {
    model?.requestMicPermission(
      () {
        view?.onMicPermissionGranted();
      },
      () {
        view?.onMicPermissionDenied();
      },
    );
  }

  @override
  void startPreview() {
    model?.startPreview((view) {
      this.view?.onPreviewStarted(view);
    });
  }

  @override
  void stopPreview() {
    model?.stopPreview(
      () {
        view?.onPreviewStopped();
      },
    );
  }

  @override
  Future<dynamic> switchCamera() {
    return model?.switchCamera();
  }

  @override
  void joinRoom(
    BuildContext context,
    Mode mode,
    String id,
  ) {
    model?.joinRoom(
      context,
      mode,
      id,
      (context) {
        view?.onJoinRoomSuccess(context);
      },
      (context, info) {
        view?.onJoinRoomError(context, info);
      },
    );
  }

  @override
  void exit() {
    model?.exit();
  }
}
