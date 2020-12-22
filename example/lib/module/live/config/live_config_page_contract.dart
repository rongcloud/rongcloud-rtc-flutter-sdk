import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
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

  void onPreviewStarted(VideoStreamWidget view);

  void onPreviewStopped();

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

  void startPreview(
    void onPreviewStarted(VideoStreamWidget view),
  );

  void stopPreview(
    void onPreviewStopped(),
  );

  Future<dynamic> switchCamera();

  void joinRoom(
    BuildContext context,
    Mode mode,
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

  void startPreview();

  void stopPreview();

  Future<dynamic> switchCamera();

  void joinRoom(BuildContext context, Mode mode, String id);

  void exit();
}
