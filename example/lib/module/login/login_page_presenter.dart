import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/utils/local_storage.dart';
import 'package:flutter/widgets.dart';

import 'login_page_contract.dart';
import 'login_page_model.dart';

class LoginPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return LoginPageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    await LocalStorage.init();
    requestCurrentServerVersion(context);
  }

  @override
  void requestCurrentServerVersion(BuildContext context) {
    model?.requestCurrentServerVersion(
      context,
      (context, version) {
        view?.onServerVersionLoaded(context, version);
      },
    );
  }

  @override
  void login(BuildContext context) {
    model?.login(
      context,
      () {
        view?.onLoginSuccess();
      },
      (context, info) {
        view?.onLoginError(context, info);
      },
    );
  }
}
