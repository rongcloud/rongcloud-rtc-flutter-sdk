import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/material.dart';

abstract class View implements IView {
  //获取房间列表成功
  void onLiveRoomListSuccess(RoomList list);

  //获取房间列表失败
  void onLiveRoomListFailure(String error);

  //加入房间成功
  void joinRoomSuccess(BuildContext context, Room room);

  //加入房间失败
  void joinRoomFailure(BuildContext context, String error);
}

abstract class Model implements IModel {
  void getLiveRoomList(
    bool reset,
    void onLoaded(RoomList list),
    void onLoadError(String error),
  );

  void requestJoinLiveRoom(
    BuildContext context,
    String roomId,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String error),
  );
}

abstract class Presenter implements IPresenter {
  //请求房间列表
  void getAudioLiveRoomList([bool reset]);

  //加入IM房间用于/统计在在线人数/发送消息
  void joinAudioLiveRoom(BuildContext context, Room room);
}
