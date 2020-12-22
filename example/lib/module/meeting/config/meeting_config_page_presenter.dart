import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';

import 'meeting_config_page_contract.dart';
import 'meeting_config_page_model.dart';

class MeetingConfigPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return MeetingConfigPageModel();
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
  void joinRoom(
    BuildContext context,
    Config config,
    String id,
  ) {
    model?.joinRoom(
      context,
      config,
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
