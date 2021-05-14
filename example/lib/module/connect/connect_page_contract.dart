import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

abstract class View implements IView {
  void onConnected(String id);

  void onConnectError(int code, String id);

  void onDone(String info);

  void onError(int code, String info);
}

abstract class Model implements IModel {
  void load();

  void clear();

  Future<Result> token(String key);

  void connect(
    String key,
    String navigate,
    String file,
    String media,
    String token,
    StateCallback callback,
  );

  void login(
    String name,
    StateCallback callback,
  );

  void disconnect();

  void action(
    String info,
    Mode mode,
    RCRTCLiveType type,
    StateCallback callback,
  );
}

abstract class Presenter implements IPresenter {
  void clear();

  Future<Result> token(String key);

  void connect(
    String key,
    String navigate,
    String file,
    String media,
    String token,
  );

  void login(
    String name,
  );

  void disconnect();

  void action(
    String info,
    Mode mode,
    RCRTCLiveType type,
  );
}
