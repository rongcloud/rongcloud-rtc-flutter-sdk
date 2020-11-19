import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

abstract class View implements IView {
  void onReceiveMessage(Data.Message message);

  void onReceiveInviteMessage(Data.User user, LiveType type);

  void onPulled(RCRTCTextureView videoView);

  void onPullError(int code, String message);

  void onExit(BuildContext context);

  void onExitWithError(BuildContext context, String info);
}

abstract class Model implements IModel {
  void sendMessage(
    String roomId,
    String message,
    void onMessageSent(Message message),
  );

  void sendRequestListMessage(String uid);

  void refuseInvite(Data.User user, LiveType type);

  void agreeInvite(
    Data.User user,
    String roomId,
    String url,
    LiveType type,
    void onVideoViewReady(RCRTCTextureView videoView),
    void onRemoteVideoViewReady(String uid, RCRTCTextureView videoView),
    void onRemoteVideoViewClose(String uid),
  );

  void pull(
    String url,
    void onSuccess(RCRTCTextureView videoView),
    void onError(int code, String message),
  );

  void exit(
    BuildContext context,
    String roomId,
    String url,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void sendMessage(String message);

  void refuseInvite(Data.User user, LiveType type);

  void agreeInvite(
    Data.User user,
    LiveType type,
    void onVideoViewReady(RCRTCTextureView videoView),
    void onRemoteVideoViewReady(String uid, RCRTCTextureView videoView),
    void onRemoteVideoViewClose(String uid),
  );

  void pull();

  void exit(BuildContext context);
}
