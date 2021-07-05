import 'package:rc_rtc_flutter_example/data/constants.dart';
import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'connect_page_contract.dart';
import 'connect_page_model.dart';

class ConnectPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return ConnectPageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    disconnect();
    model.load();
  }

  @override
  void clear() {
    model.clear();
  }

  @override
  Future<Result> token(String key) {
    return model.token(key);
  }

  @override
  void connect(
    String key,
    String navigate,
    String file,
    String media,
    String token,
  ) {
    model.connect(
      key,
      navigate,
      file,
      media,
      token,
      (code, info) {
        if (code == RCRTCErrorCode.OK)
          view.onConnected(info);
        else
          view.onConnectError(code, info);
      },
    );
  }

  @override
  void login(String name) {
    model.login(
      name,
      (code, info) {
        if (code == RCRTCErrorCode.OK)
          view.onConnected(info);
        else
          view.onConnectError(code, info);
      },
    );
  }

  @override
  void disconnect() {
    model.disconnect();
  }

  @override
  void action(
    String info,
    Mode mode,
    RCRTCLiveType type,
  ) {
    model.action(
      info,
      mode,
      type,
      (code, info) {
        if (code != RCRTCErrorCode.OK) {
          view.onError(code, info);
        } else {
          view.onDone(info);
        }
      },
    );
  }
}
