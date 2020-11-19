import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:rongcloud_rtc_plugin/agent/room/rcrtc_remote_user.dart';
import 'package:rongcloud_rtc_plugin/agent/stream/rcrtc_camera_output_stream.dart';

enum StreamType { StreamTypeAudio, StreamTypeVideo }

class RemoteUserStatus {
  bool audioStatus;
  bool videoStatus;
  RCRTCRemoteUser user;

  RemoteUserStatus(this.user, this.audioStatus, this.videoStatus);
}

abstract class View implements IView {
  void onPermissionStatus(PermissionStatus status);

  void onVideoViewCreated(TextureView view);

  void onRemoveVideoView(String userId);

  void onPushed();

  void onPushError(String info);

  void onCameraChanged(bool isFront);
}

abstract class Model implements IModel {
  Future<PermissionStatus> requestPermission();

  Future<PermissionStatus> requestCameraPermission();

  Future<PermissionStatus> requestMicPermission();

  void createVideoView(
    void onVideoViewCreated(TextureView view),
    void readyToPush(),
  );

  Future<StatusCode> push();

  void pull(
    void onVideoViewCreated(TextureView view),
    void onRemoveVideoView(String userId),
  );

  void switchCamera(void onCameraChanged(bool isFront));

  void setCameraCaptureOrientation(RCRTCCameraCaptureOrientation orientation);

  Future<bool> changeAudioStreamState();

  Future<bool> changeVideoStreamState(
    void onVideoViewCreated(TextureView view),
    void onRemoveVideoView(String userId),
  );

  List<RemoteUserStatus> getUserList();

  Future<bool> changeRemoteAudioStreamState(RemoteUserStatus user);

  Future<bool> changeRemoteVideoStreamState(RemoteUserStatus user);

  void changeVideoResolution(String level, void onVideoViewCreated(TextureView view), void onRemoveVideoView(String userId));

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

  void setCameraCaptureOrientation(RCRTCCameraCaptureOrientation orientation);

  Future<bool> changeAudioStreamState();

  Future<bool> changeVideoStreamState();

  List<RemoteUserStatus> getUserList();

  Future<bool> changeRemoteAudioStreamState(RemoteUserStatus user);

  Future<bool> changeRemoteVideoStreamState(RemoteUserStatus user);

  void changeVideoResolution(String level);

  Future<StatusCode> exit();
}
