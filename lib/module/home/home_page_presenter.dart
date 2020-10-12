import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'home_page_contract.dart';
import 'home_page_model.dart';

class HomePagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return HomePageModel();
  }

  @override
  void init(BuildContext context) {
    requestCurrentServerVersion();
    login();
    loadLiveRoomList(true);
  }

  @override
  void requestCurrentServerVersion() {
    model?.requestCurrentServerVersion(
      (version) {
        view?.onServerVersionLoaded(version);
      },
    );
  }

  @override
  void login() {
    model?.login(
      () {
        view?.onLoginSuccess();
      },
      (info) {
        view?.onLoginError(info);
      },
    );
  }

  @override
  void loadLiveRoomList([bool reset]) {
    model?.loadLiveRoomList(
      reset ?? false,
      (list) {
        view?.onLiveRoomListLoaded(list);
      },
      (info) {
        view?.onLiveRoomListLoadError(info);
      },
    );
  }

  @override
  void requestJoinRoom(BuildContext context, String roomId, RCRTCRoomType type) {
    model?.requestJoinRoom(
      context,
      roomId,
      type,
      (context) {
        view?.onLiveRoomCreated(context);
      },
      (context, info) {
        view?.onLiveRoomCreateError(context, info);
      },
    );
  }

  @override
  void requestJoinLiveRoom(BuildContext context, Room room) {
    model?.requestJoinLiveRoom(
      context,
      room.id,
      (context) {
        view?.onLiveRoomJoined(context, room);
      },
      (context, info) {
        view?.onLiveRoomJoinError(context, info);
      },
    );
  }
}
