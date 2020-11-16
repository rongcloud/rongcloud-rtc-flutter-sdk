import 'package:flutter/widgets.dart';

import '../module/home/home_page.dart';
import '../module/live/audience/live_audience_page.dart';
import '../module/live/host/live_host_page.dart';
import '../module/splash/splash_page.dart';
import '../module/video/video_chat_page.dart';
import '../module/audio/audio_chat_page.dart';

class RouterManager {
  static initRouters() {
    _routes = {
      SPLASH: (context) => SplashPage(),
      HOME: (context) => HomePage(),
      LIVE_HOST: (context) => LiveHostPage(),
      LIVE_AUDIENCE: (context) => LiveAudiencePage(),
      VIDEO_CHAT: (context) => VideoChatPage(),
      AUDIO_CHAT: (context) => AudioChatPage(),
    };
    return _routes;
  }

  static const String SPLASH = '/';
  static const String HOME = '/home';
  static const String LIVE_HOST = '/live/host';
  static const String LIVE_AUDIENCE = '/live/audience';
  static const String VIDEO_CHAT = '/video';
  static const String AUDIO_CHAT = "/audio";

  static Map<String, WidgetBuilder> _routes;
}
