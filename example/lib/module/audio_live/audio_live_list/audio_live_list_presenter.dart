import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';

import 'audio_live_list_contract.dart';
import 'audio_live_list_model.dart';

class AudioLiveListPresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return AudioLiveListModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    getAudioLiveRoomList(true);
  }

  @override
  void getAudioLiveRoomList([bool reset]) {
    model?.getLiveRoomList(
      reset ?? false,
      (list) {
        view?.onLiveRoomListSuccess(list);
      },
      (error) {
        view?.onLiveRoomListFailure(error);
      },
    );
  }

  @override
  void joinAudioLiveRoom(BuildContext context, Room room) {
    model?.requestJoinLiveRoom(
      context,
      room.id,
      (context) {
        view?.joinRoomSuccess(context, room);
      },
      (context, error) {
        view?.joinRoomFailure(context, error);
      },
    );
  }
}
