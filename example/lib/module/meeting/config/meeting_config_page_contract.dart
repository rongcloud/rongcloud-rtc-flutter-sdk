import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/widgets.dart';

abstract class View implements IView {
  void onIMConnected();

  void onIMConnectError();

  void onPermissionGranted();

  void onPermissionDenied(bool camera, bool mic);

  void onCameraPermissionGranted();

  void onCameraPermissionDenied();

  void onMicPermissionGranted();

  void onMicPermissionDenied();

  void onJoinRoomSuccess(BuildContext context);

  void onJoinRoomError(BuildContext context, String info);
}

abstract class Model implements IModel {
  Future<dynamic> connectIM();

  void requestPermission(
    void onGranted(),
    void onDenied(bool camera, bool mic),
  );

  void requestCameraPermission(
    void onGranted(),
    void onDenied(),
  );

  void requestMicPermission(
    void onGranted(),
    void onDenied(),
  );

  void joinRoom(
    BuildContext context,
    Config config,
    String id,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  );

  void exit();
}

abstract class Presenter implements IPresenter {
  void connectIM();

  void requestPermission();

  void requestCameraPermission();

  void requestMicPermission();

  void joinRoom(BuildContext context, Config config, String id);

  void exit();
}
