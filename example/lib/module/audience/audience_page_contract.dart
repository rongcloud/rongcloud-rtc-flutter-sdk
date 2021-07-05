import 'package:rc_rtc_flutter_example/data/constants.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/presenter.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/view.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

abstract class View implements IView {
  void onConnected();

  void onVideoStreamReceived(RCRTCVideoInputStream? stream);

  void onAudioStreamReceived(RCRTCAudioInputStream? stream);

  void onConnectError(int code, String? message);
}

abstract class Model implements IModel {
  void subscribe(
    AVStreamType type,
    Callback success,
    Callback audio,
    Callback video,
    StateCallback error,
  );

  Future<bool> changeSpeaker(bool enable);

  void exit();
}

abstract class Presenter implements IPresenter {
  void subscribe(AVStreamType type);

  Future<bool> changeSpeaker(bool enable);

  void exit();
}
