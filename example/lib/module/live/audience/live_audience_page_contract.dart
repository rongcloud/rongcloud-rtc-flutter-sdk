import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

abstract class View implements IView {
  void onReceiveMessage(Data.Message message);

  void onReceiveInviteMessage();

  void onReceiveKickMessage();

  void onSubscribeUrlError(int code, String message);

  void onJoined();

  void onJoinError();

  void onUserJoined(UserView view);

  void onUserLeaved(String uid);

  void onUserAudioStreamChanged(String uid, dynamic stream);

  void onUserVideoStreamChanged(String uid, dynamic stream);

  void onExit(BuildContext context);

  void onExitWithError(BuildContext context, String info);
}

abstract class Model implements IModel {
  // void initEngine();

  void unInitEngine();

  void subscribeLiveStreams(
    Data.Room room,
    void onUserJoined(UserView view),
  );

  void sendMessage(
    String roomId,
    String message,
    void onMessageSent(Message message),
  );

  void refuseInvite(Data.Room room);

  void agreeInvite(Data.Room room);

  // void subscribeUrl(
  //   Data.Room room,
  //   void onUserJoined(UserView view),
  //   void onSubscribeError(int code, String message),
  // );

  Future<bool> requestPermission();

  // Future<bool> unsubscribeUrl(Data.Room room);

  Future<StatusCode> joinRoom(Data.Room room);

  void subscribe(
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
    void onUserLeaved(String uid),
  );

  Future<StatusCode> publish(
    Data.Config config,
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
  );

  Future<bool> switchCamera();

  void changeAudioStreamState(
    Data.Config config,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  );

  void changeVideoStreamState(
    Data.Config config,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  );

  Future<bool> leaveLink();

  //添加初衷为了适配连麦场景，断开连麦再次加入room
  Future<bool> autoJoinRoom(String roomId);

  void exit(
    BuildContext context,
    Data.Room room,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void subscribeLiveStreams();

  void sendMessage(String message);

  void refuseInvite();

  void agreeInvite(Data.Config config);

  Future<bool> switchCamera();

  void changeAudioStreamState(Data.Config config);

  void changeVideoStreamState(Data.Config config);

  Future<bool> leaveLink();

  //添加初衷为了适配连麦场景，断开连麦再次加入room
  Future<bool> autoJoinRoom(String roomId);

  void exit(BuildContext context);
}
