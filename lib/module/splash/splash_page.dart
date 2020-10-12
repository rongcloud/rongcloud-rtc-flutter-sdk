import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/module/splash/splash_page_contract.dart';
import 'package:FlutterRTC/module/splash/splash_page_presenter.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashPage extends AbstractView {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends AbstractViewState<Presenter, SplashPage> implements View {
  @override
  Widget buildWidget(BuildContext context) {
    presenter.preload();
    return Scaffold(
        body: new Center(
      child: Text("Splash"),
    ));
  }

  @override
  Presenter createPresenter() {
    return SplashPagePresenter();
  }

  @override
  void onPreloadError(String info) {
    print(info);
  }

  @override
  void onPreloadSuccess() {
    Navigator.pop(context);
    Navigator.pushNamed(context, RouterManager.HOME);
  }
}
