import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:flutter/widgets.dart';

abstract class View implements IView {
  void onServerVersionLoaded(BuildContext context, String version);

  void onLoginSuccess();

  void onLoginError(BuildContext context, String info);
}

abstract class Model implements IModel {
  void requestCurrentServerVersion(
    BuildContext context,
    void onLoaded(BuildContext context, String version),
  );

  void login(
    BuildContext context,
    void onLoginSuccess(),
    void onLoginError(BuildContext context, String info),
  );
}

abstract class Presenter implements IPresenter {
  void requestCurrentServerVersion(BuildContext context);

  void login(BuildContext context);
}
