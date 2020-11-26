import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:rongcloud_rtc_plugin/agent/room/rcrtc_remote_user.dart';
import 'package:rongcloud_rtc_plugin/agent/stream/rcrtc_camera_output_stream.dart';

class RemoteUserStatus {
  bool audioStatus;
  bool videoStatus;
  RCRTCRemoteUser user;

  RemoteUserStatus(this.user, this.audioStatus, this.videoStatus);
}

abstract class View implements IView {
  void invalidate();

  void onViewCreated(VideoStreamWidget view);

  void onRemoveView(String userId);

  void onPublished();

  void onPublishError(String info);
}

abstract class Model implements IModel {
  void subscribe(
    void onViewCreated(VideoStreamWidget view),
    void onRemoveView(String userId),
    void invalidate(),
  );

  Future<StatusCode> publish(
    Config config,
    void onViewCreated(VideoStreamWidget view),
  );

  Future<bool> switchCamera();

  void setCameraCaptureOrientation(RCRTCCameraCaptureOrientation orientation);

  Future<bool> changeAudioStreamState(Config config);

  Future<bool> changeVideoStreamState(
    Config config,
    void onViewCreated(VideoStreamWidget view),
    void onRemoveView(String userId),
  );

  void changeRemoteAudioSubscribeState(bool unsubscribe);

  List<RemoteUserStatus> getUserList();

  Future<bool> changeRemoteAudioStreamState(RemoteUserStatus user);

  Future<bool> changeRemoteVideoStreamState(RemoteUserStatus user);

  Future<StatusCode> exit();
}

abstract class Presenter implements IPresenter {
  void subscribe();

  void publish(Config config);

  Future<bool> switchCamera();

  void setCameraCaptureOrientation(RCRTCCameraCaptureOrientation orientation);

  Future<bool> changeAudioStreamState(Config config);

  Future<bool> changeVideoStreamState(Config config);

  void changeRemoteAudioSubscribeState(bool unsubscribe);

  List<RemoteUserStatus> getUserList();

  Future<bool> changeRemoteAudioStreamState(RemoteUserStatus user);

  Future<bool> changeRemoteVideoStreamState(RemoteUserStatus user);

  Future<StatusCode> exit();
}
