import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';

import 'audio_live_create_contract.dart';
import 'audio_live_create_model.dart';

class AudioLiveCreatePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return AudioLiveCreateModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    connectIM();
  }

  @override
  Future<void> connectIM() async {
    bool success = await model?.connectIM();
    if (success) {
      view?.onIMConnected();
    } else {
      view?.onIMConnectError();
    }
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
