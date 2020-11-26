import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';

import 'home_page_contract.dart';
import 'home_page_model.dart';

class HomePagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return HomePageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    loadLiveRoomList(true);
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
