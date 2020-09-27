import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:rongcloud_rtc_plugin/agent/view/rcrtc_video_view.dart';

abstract class View implements IView {
  void onPermissionGranted();

  void onPermissionDenied(bool camera, bool mic);

  void onCameraPermissionGranted();

  void onCameraPermissionDenied();

  void onMicPermissionGranted();

  void onMicPermissionDenied();

  void onVideoViewReady(RCRTCVideoView videoView);

  void onPushed();

  void onPushError(String info);

  void onExit(BuildContext context);

  void onExitWithError(BuildContext context, String info);

  void onReceiveMessage(Message message);

  void onReceiveMember(User user);

  void onMemberInvited(User user, bool agree, LiveType type);

  void onCreateRemoteView(String uid, RCRTCVideoView videoView);

  void onReleaseRemoteView(String uid);

  void onCameraStatusChanged(bool isFront);

  void onCameraMirrorChanged(bool state);

  void onMicrophoneStatusChanged(bool state);
}

abstract class Model implements IModel {
  void setMirror(void onCameraMirrorChanged(bool state));

  void switchCamera(void onCameraStatusChanged(bool isFront));

  void muteMicrophone(void onMicrophoneStatusChanged(bool state));

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

  void initVideoView(
    void onVideoViewReady(RCRTCVideoView view),
    void readyToPush(),
  );

  void push(
    void onSuccess(),
    void onError(String info),
  );

  void requestMemberList();

  void inviteMember(User user, LiveType type);

  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void setMirror();

  void switchCamera();

  void muteMicrophone();

  void requestPermission();

  void requestCameraPermission();

  void requestMicPermission();

  void initVideoView();

  void push();

  void requestMemberList();

  void inviteMember(User user, LiveType type);

  void exit(BuildContext context);
}
