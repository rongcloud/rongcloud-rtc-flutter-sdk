import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';

abstract class View implements IView {
  void onViewCreated(VideoStreamWidget view);

  void onRemoveView(String userId);

  void onPublished();

  void onPublishError(String info);

  void onReceiveMessage(Message message);

  void onReceiveMember(User user);

  void onMemberInvited(User user, bool agree);

  void onMemberJoined(String userId);

  void onExit(BuildContext context);

  void onExitWithError(BuildContext context, String info);
}

abstract class Model implements IModel {
  void subscribe(
    void onViewCreated(VideoStreamWidget view),
    void onRemoveView(String userId),
    void onMemberJoined(String userId),
  );

  Future<StatusCode> publish(
    Config config,
    void onViewCreated(VideoStreamWidget view),
  );

  void requestMemberList();

  void inviteMember(User user);

  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void subscribe();

  void publish(Config config);

  void requestMemberList();

  void inviteMember(User user);

  void exit(BuildContext context);
}
