import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/cupertino.dart';

import 'home_page_model.dart';

abstract class View implements IView {
  void onServerVersionLoaded(String version);

  void onLoginSuccess();

  void onLoginError(String info);

  void onLiveRoomListLoaded(RoomList list);

  void onLiveRoomListLoadError(String info);

  void onLiveRoomCreated(BuildContext context);

  void onLiveRoomCreateError(BuildContext context, String info);

  void onLiveRoomJoined(BuildContext context, Room room);

  void onLiveRoomJoinError(BuildContext context, String info);
}

abstract class Model implements IModel {
  void requestCurrentServerVersion(
    void onLoaded(String version),
  );

  void login(
    void onLoginSuccess(),
    void onLoginError(String info),
  );

  void initRCRTCEngine();

  void loadLiveRoomList(
    bool reset,
    void onLoaded(RoomList list),
    void onLoadError(String info),
  );

  void requestJoinRoom(
    BuildContext context,
    String roomId,
    ChatType type,
    void onCreated(BuildContext context),
    void onCreateError(BuildContext context, String info),
  );

  void requestJoinLiveRoom(
    BuildContext context,
    String roomId,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void requestCurrentServerVersion();

  void login();

  void initRCRTCEngine();

  void loadLiveRoomList([bool reset]);

  void requestJoinRoom(BuildContext context, String roomId, ChatType type);

  void requestJoinLiveRoom(BuildContext context, Room room);
}
