import 'package:FlutterRTC/module/home/home_page.dart';
import 'package:FlutterRTC/module/live/audience/live_audience_page.dart';
import 'package:FlutterRTC/module/live/host/live_host_page.dart';
import 'package:FlutterRTC/module/splash/splash_page.dart';
import 'package:flutter/widgets.dart';

class RouterManager {
  static initRouters() {
    _routes = {
      SPLASH: (context) => SplashPage(),
      HOME: (context) => HomePage(),
      LIVE_HOST: (context) => LiveHostPage(),
      LIVE_AUDIENCE: (context) => LiveAudiencePage(),
    };
    return _routes;
  }

  static const String SPLASH = '/';
  static const String HOME = '/home';
  static const String LIVE_HOST = '/live/host';
  static const String LIVE_AUDIENCE = '/live/audience';

  static Map<String, WidgetBuilder> _routes;
}
