import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/material.dart';

abstract class View implements IView {
  void onIMConnected();

  void onIMConnectError();

  void onMicPermissionGranted();

  void onMicPermissionDenied();

  void onJoinRoomSuccess(BuildContext context);

  void onJoinRoomError(BuildContext context, String info);
}

abstract class Model implements IModel {
  Future<dynamic> connectIM();

  void requestMicPermission(
    void onGranted(),
    void onDenied(),
  );

  void joinRoom(
    BuildContext context,
    Mode mode,
    String uid,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  );

  void exit();
}

abstract class Presenter implements IPresenter {
  void connectIM();

  void requestMicPermission();

  void joinRoom(BuildContext context, Mode mode, String id);

  void exit();
}
