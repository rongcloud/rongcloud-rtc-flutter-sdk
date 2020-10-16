import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';

abstract class View implements IView {
  void onPreloadSuccess();

  void onPreloadError(String info);
}

abstract class Model implements IModel {
  void preload(
    onPreloadSuccess(),
    onPreloadError(String info),
  );
}

abstract class Presenter implements IPresenter {
  void preload();
}
