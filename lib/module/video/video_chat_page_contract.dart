import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/video_view.dart';

abstract class View implements IView {
  void onPermissionStatus(PermissionStatus status);

  void onVideoViewCreated(VideoView view);

  void onRemoveVideoView(String userId);

  void onPushed();

  void onPushError(String info);
}

abstract class Model implements IModel {
  Future<PermissionStatus> requestPermission();

  Future<PermissionStatus> requestCameraPermission();

  Future<PermissionStatus> requestMicPermission();

  void createVideoView(
    void onVideoViewCreated(VideoView view),
    void readyToPush(),
  );

  Future<StatusCode> push();

  void pull(
    void onVideoViewCreated(VideoView view),
    void onRemoveVideoView(String userId),
  );

  void switchCamera();

  Future<bool> changeAudioStreamState();

  Future<bool> changeVideoStreamState(
    void onVideoViewCreated(VideoView view),
    void onRemoveVideoView(String userId),
  );

  Future<StatusCode> exit();
}

abstract class Presenter implements IPresenter {
  void requestPermission();

  void requestCameraPermission();

  void requestMicPermission();

  void createVideoView();

  void push();

  void pull();

  void switchCamera();

  Future<bool> changeAudioStreamState();

  Future<bool> changeVideoStreamState();

  Future<StatusCode> exit();
}
