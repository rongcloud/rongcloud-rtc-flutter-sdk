import 'package:flutter/widgets.dart';

import '../module/audio/audio_chat_page.dart';
import '../module/config/config_page.dart';
import '../module/home/home_page.dart';
import '../module/live/audience/live_audience_page.dart';
import '../module/live/host/live_host_page.dart';
import '../module/login/login_page.dart';
import '../module/settings/set_resolution_page.dart';
import '../module/settings/settings_page.dart';
import '../module/video/video_chat_page.dart';

class RouterManager {
  static initRouters() {
    _routes = {
      LOGIN: (context) => LoginPage(),
      HOME: (context) => HomePage(),
      CONFIG: (context) => ConfigPage(),
      LIVE_HOST: (context) => LiveHostPage(),
      LIVE_AUDIENCE: (context) => LiveAudiencePage(),
      VIDEO_CHAT: (context) => VideoChatPage(),
      AUDIO_CHAT: (context) => AudioChatPage(),
      SETTINGS: (context) => SettingsPage(),
      SET_RESOLUTION: (context) => SetResolutionPage(),
    };
    return _routes;
  }

  static const String LOGIN = '/login';
  static const String HOME = '/home';
  static const String CONFIG = '/config';
  static const String LIVE_HOST = '/live/host';
  static const String LIVE_AUDIENCE = '/live/audience';
  static const String VIDEO_CHAT = '/video';
  static const String AUDIO_CHAT = "/audio";
  static const String SETTINGS = '/settings';
  static const String SET_RESOLUTION = '/settings/resolution';

  static Map<String, WidgetBuilder> _routes;
}
