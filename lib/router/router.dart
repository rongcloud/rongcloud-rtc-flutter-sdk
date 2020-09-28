import 'package:flutter/widgets.dart';

import '../module/home/home_page.dart';
import '../module/live/audience/live_audience_page.dart';
import '../module/live/host/live_host_page.dart';
import '../module/splash/splash_page.dart';
import '../module/video_chat/video_chat_page.dart';

class RouterManager {
  static initRouters() {
    _routes = {
      SPLASH: (context) => SplashPage(),
      HOME: (context) => HomePage(),
      LIVE_HOST: (context) => LiveHostPage(),
      LIVE_AUDIENCE: (context) => LiveAudiencePage(),
      VIDEO_CHAT: (context) => VideoChatPage(),
    };
    return _routes;
  }

  static const String SPLASH = '/';
  static const String HOME = '/home';
  static const String LIVE_HOST = '/live/host';
  static const String LIVE_AUDIENCE = '/live/audience';
  static const String VIDEO_CHAT = '/videochat';

  static Map<String, WidgetBuilder> _routes;
}
