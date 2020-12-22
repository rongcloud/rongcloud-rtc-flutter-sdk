import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/module/audio_live/audio_live_view.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

abstract class View implements IView {
  void onPublished();

  void onPublishError(String info);

  void onReceiveLinkRequest(Data.User user);

  void onReceiveMessage(Data.Message message);

  void onAudienceJoined(Data.User user);

  void onAudienceLeft(Data.User user);

  void onMemberInvited(Data.User user, bool agree);

  void onUserJoined(AudioStreamView view);

  void onUserLeaved(String uid);

  void onUserAudioStreamChanged(String uid, dynamic stream);

  void onExit(BuildContext context);

  void onExitWithError(BuildContext context, String info);
}

abstract class Model implements IModel {
  void subscribe(
    void onUserJoined(AudioStreamView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserLeaved(String uid),
  );

  Future<StatusCode> publish(
    Data.Config config,
    void onUserJoined(AudioStreamView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
  );

  void inviteMember(Data.User user);

  void kickMember(Data.User user);

  void acceptLink(Data.User user);

  void refuseLink(Data.User user);

  void sendMessage(
    String roomId,
    String message,
    void onMessageSent(Message message),
  );

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

  void acceptLink(Data.User user);

  void refuseLink(Data.User user);

  void sendMessage(String message);

  void exit(BuildContext context);
}
