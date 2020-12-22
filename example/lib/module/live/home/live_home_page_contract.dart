import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/widgets.dart';

abstract class View implements IView {
  void onLiveRoomListLoaded(RoomList list);

  void onLiveRoomListLoadError(String info);

  void onLiveRoomJoined(BuildContext context, Room room);

  void onLiveRoomJoinError(BuildContext context, String info);
}

abstract class Model implements IModel {
  void loadLiveRoomList(
    bool reset,
    void onLoaded(RoomList list),
    void onLoadError(String info),
  );

  void requestJoinLiveRoom(
    BuildContext context,
    String roomId,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void loadLiveRoomList([bool reset]);

  void requestJoinLiveRoom(BuildContext context, Room room);
}
