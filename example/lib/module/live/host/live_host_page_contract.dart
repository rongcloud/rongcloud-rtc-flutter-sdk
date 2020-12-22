import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rcrtc_mix_config.dart';

abstract class View implements IView {
  void onPublished();

  void onPublishError(String info);

  void onReceiveMessage(Data.Message message);

  void onAudienceJoined(Data.User user);

  void onAudienceLeft(Data.User user);

  void onMemberInvited(Data.User user, bool agree);

  void onUserJoined(UserView view);

  void onUserLeaved(String uid);

  void onUserAudioStreamChanged(String uid, dynamic stream);

  void onUserVideoStreamChanged(String uid, dynamic stream);

  void onExit(BuildContext context);

  void onExitWithError(BuildContext context, String info);
}

abstract class Model implements IModel {
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

  void inviteMember(Data.User user);

  void kickMember(Data.User user);

  void sendMessage(
    String roomId,
    String message,
    void onMessageSent(Message message),
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

  void changeRemoteAudioStreamState(
    UserView view,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  );

  void changeRemoteVideoStreamState(
    UserView view,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  );

  void changeMixConfig(RCRTCMixConfig config);

  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void subscribe();

  void publish(Data.Config config);

  void inviteMember(Data.User user);

  void kickMember(Data.User user);

  void sendMessage(String message);

  Future<bool> switchCamera();

  void changeAudioStreamState(Data.Config config);

  void changeVideoStreamState(Data.Config config);

  void changeRemoteAudioStreamState(UserView view);

  void changeRemoteVideoStreamState(UserView view);

  void changeMixConfig(RCRTCMixConfig config);

  void exit(BuildContext context);
}
