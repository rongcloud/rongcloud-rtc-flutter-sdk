import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
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
  }

  @override
  void subscribe(AVStreamType type) {
    model?.subscribe(
      type,
      (_) {
        view?.onConnected();
      },
      (stream) {
        view?.onAudioStreamReceived(stream);
      },
      (stream) {
        view?.onVideoStreamReceived(stream);
      },
      (code, info) {
        view?.onConnectError(code, info);
      },
    );
  }

  @override
  Future<bool> changeSpeaker(bool enable) {
    return model?.changeSpeaker(enable);
  }

  @override
  void exit() {
    model?.exit();
  }
}
