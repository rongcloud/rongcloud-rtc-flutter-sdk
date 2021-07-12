import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/presenter.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/view.dart';
import 'package:rc_rtc_flutter_example/widgets/ui.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

abstract class View implements IView {
  void onLocalViewCreated(UserView view);

  void onUserJoin(User user);

  void onUserLeft(String id);

  void onUserAudioStatusChanged(String id, bool publish);

  void onUserVideoStatusChanged(String id, bool publish);

  void onExit();

  void onExitWithError(int code);
}

abstract class Model implements IModel {
  Future<UserView> createLocalView();

  Future<void> setEncoderMirror(bool mirror);

  Future<bool> muteAudio(bool mute);

  Future<bool> muteVideo(bool mute);

  Future<bool> changeMic(bool open);

  Future<bool> changeCamera(bool open);

  Future<bool> changeAudio(bool publish);

  Future<bool> changeVideo(bool publish);

  Future<bool> changeFrontCamera(bool front);

  Future<bool> changeSpeaker(bool speaker);

  Future<void> changeVideoConfig(RCRTCVideoStreamConfig config);

  Future<bool> changeTinyVideoConfig(RCRTCVideoStreamConfig config);

  void switchToNormalStream(String id);

  void switchToTinyStream(String id);

  Future<RCRTCAudioInputStream?> changeRemoteAudioStatus(String id, bool subscribe);

  Future<RCRTCVideoInputStream?> changeRemoteVideoStatus(String id, bool subscribe);

  Future<int> exit();
}

abstract class Presenter implements IPresenter {
  Future<void> setEncoderMirror(bool mirror);

  Future<bool> muteAudio(bool mute);

  Future<bool> muteVideo(bool mute);

  Future<bool> changeMic(bool open);

  Future<bool> changeCamera(bool open);

  Future<bool> changeAudio(bool publish);

  Future<bool> changeVideo(bool publish);

  Future<bool> changeFrontCamera(bool front);

  Future<bool> changeSpeaker(bool speaker);

  Future<void> changeVideoConfig(RCRTCVideoStreamConfig config);

  Future<bool> changeTinyVideoConfig(RCRTCVideoStreamConfig config);

  void switchToNormalStream(String id);

  void switchToTinyStream(String id);

  Future<RCRTCAudioInputStream?> changeRemoteAudioStatus(String id, bool subscribe);

  Future<RCRTCVideoInputStream?> changeRemoteVideoStatus(String id, bool subscribe);

  void exit();
}
