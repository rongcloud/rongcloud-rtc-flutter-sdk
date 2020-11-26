import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';

abstract class View implements IView {
  // void onLiveRoomListLoaded(RoomList list);
  //
  // void onLiveRoomListLoadError(String info);

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

  // void onJoinLiveRoomSuccess(BuildContext context, Room room);
  //
  // void onJoinLiveRoomError(BuildContext context, String info);
}

abstract class Model implements IModel {
  // void loadLiveRoomList(
  //   bool reset,
  //   void onLoaded(RoomList list),
  //   void onLoadError(String info),
  // );

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
    ConfigMode mode,
    String id,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  );

  // void joinLiveRoom(
  //   BuildContext context,
  //   String roomId,
  //   void onJoined(BuildContext context),
  //   void onJoinError(BuildContext context, String info),
  // );

  void exit();
}

abstract class Presenter implements IPresenter {
  // void loadLiveRoomList([bool reset]);

  void connectIM();

  void requestPermission();

  void requestCameraPermission();

  void requestMicPermission();

  void startPreview();

  void stopPreview();

  Future<dynamic> switchCamera();

  void joinRoom(BuildContext context, ConfigMode mode, String id);

  // void joinLiveRoom(BuildContext context, Room room);

  void exit();
}
