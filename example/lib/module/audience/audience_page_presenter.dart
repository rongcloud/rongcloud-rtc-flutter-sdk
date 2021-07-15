import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'audience_page_contract.dart';
import 'audience_page_model.dart';

class AudiencePagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return AudiencePageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    await changeSpeaker(false);

    RCRTCRoom? room = RCRTCEngine.getInstance().getRoom();
    var host = room?.remoteUserList.first;
    var audios = host?.streamList.whereType<RCRTCAudioInputStream>();
    var videos = host?.streamList.whereType<RCRTCVideoInputStream>();
    if (audios?.isNotEmpty ?? false) {
      RCRTCResourceState audioState = await audios!.first.getResourceState();
      print('Audience: Host ${host?.id} audio stream state = $audioState');
    } else {
      print('Audience: Host ${host?.id} unpublish audio stream');
    }
    if (videos?.isNotEmpty ?? false) {
      RCRTCResourceState videoState = await videos!.first.getResourceState();
      print('Audience: Host ${host?.id} video stream state = $videoState');
    } else {
      print('Audience: Host ${host?.id} unpublish video stream');
    }
  }

  @override
  void subscribe(AVStreamType type) {
    model.subscribe(
      type,
      (_) {
        view.onConnected();
      },
      (stream) {
        view.onAudioStreamReceived(stream);
      },
      (stream) {
        view.onVideoStreamReceived(stream);
      },
      (code, info) {
        view.onConnectError(code, info);
      },
    );
  }

  @override
  Future<bool> changeSpeaker(bool enable) {
    return model.changeSpeaker(enable);
  }

  @override
  void exit() {
    model.exit();
  }
}
