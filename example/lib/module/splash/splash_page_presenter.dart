import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/module/splash/splash_page_contract.dart';
import 'package:FlutterRTC/module/splash/splash_page_model.dart';
import 'package:flutter/cupertino.dart';

class SplashPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return SplashPageModel();
  }

  @override
  void init(BuildContext context) {
    // TODO: implement init
  }

  @override
  void preload() {
    model?.preload(() {
      view?.onPreloadSuccess();
    }, (info) {
      view?.onPreloadError(info);
    });
  }
}
