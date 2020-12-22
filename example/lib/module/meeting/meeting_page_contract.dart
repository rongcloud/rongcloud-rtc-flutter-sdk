import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';

abstract class View implements IView {
  void onUserJoined(UserView view);

  void onUserLeaved(String uid);

  void onUserAudioStreamChanged(String uid, dynamic stream);

  void onUserVideoStreamChanged(String uid, dynamic stream);

  void onPublished();

  void onPublishError(String info);
}

abstract class Model implements IModel {
  void subscribe(
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
    void onUserLeaved(String uid),
  );

  Future<StatusCode> publish(
    Config config,
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
  );

  Future<bool> switchCamera();

  void changeAudioStreamState(
    Config config,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  );

  void changeVideoStreamState(
    Config config,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  );

  void changeRemoteAudioStreamState(
    UserView view,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  );

  void changeRemoteVideoStreamState(
    UserView view,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  );

  void unsubscribeRemoteAudioStreams(List<UserView> views);

  void subscribeRemoteAudioStreams(List<UserView> views);

  void unsubscribeRemoteVideoStreams(List<UserView> views);

  void subscribeRemoteVideoStreams(List<UserView> views);

  void changeAudioStreamConfig(Config config);

  void changeVideoStreamConfig(Config config);

  Future<StatusCode> exit();
}

abstract class Presenter implements IPresenter {
  void subscribe();

  void publish(Config config);

  Future<bool> switchCamera();

  void changeAudioStreamState(Config config);

  void changeVideoStreamState(Config config);

  void changeRemoteAudioStreamState(UserView view);

  void changeRemoteVideoStreamState(UserView view);

  void unsubscribeRemoteAudioStreams(List<UserView> views);

  void subscribeRemoteAudioStreams(List<UserView> views);

  void unsubscribeRemoteVideoStreams(List<UserView> views);

  void subscribeRemoteVideoStreams(List<UserView> views);

  void changeAudioStreamConfig(Config config);

  void changeVideoStreamConfig(Config config);

  Future<StatusCode> exit();
}
