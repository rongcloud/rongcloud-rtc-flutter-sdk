import 'package:flutter/widgets.dart';

import '../module/audio_live/audience/audio_live_audience_page.dart';
import '../module/audio_live/audio_config/audio_live_create_page.dart';
import '../module/audio_live/audio_live_list/audio_live_list.dart';
import '../module/audio_live/live/audio_live_page.dart';
import '../module/home/home_page.dart';
import '../module/live/audience/live_audience_page.dart';
import '../module/live/config/live_config_page.dart';
import '../module/live/home/live_home_page.dart';
import '../module/live/host/live_host_page.dart';
import '../module/login/login_page.dart';
import '../module/meeting/config/meeting_config_page.dart';
import '../module/meeting/meeting_page.dart';
import '../module/settings/settings_page.dart';

class RouterManager {
  static initRouters() {
    _routes = {
      LOGIN: (context) => LoginPage(),
      HOME: (context) => HomePage(),
      LIVE_HOME: (context) => LiveHomePage(),
      LIVE_CONFIG: (context) => LiveConfigPage(),
      LIVE_HOST: (context) => LiveHostPage(),
      LIVE_AUDIENCE: (context) => LiveAudiencePage(),
      MEETING_CONFIG: (context) => MeetingConfigPage(),
      MEETING: (context) => MeetingPage(),
      SETTINGS: (context) => SettingsPage(),
      AUDIO_LIVE_LIST: (context) => AudioLiveList(),
      AUDIO_LIVE_CREATE: (context) => AudioLiveCreatePage(),
      AUDIO_LIVE: (context) => AudioLivePage(),
      AUDIO_LIVE_AUDIENCE: (context) => AudioLiveAudiencePage(),
    };
    return _routes;
  }

  static const String LOGIN = '/login';
  static const String HOME = '/home';
  static const String LIVE_HOME = '/live/home';
  static const String LIVE_CONFIG = '/live/config';
  static const String LIVE_HOST = '/live/host';
  static const String LIVE_AUDIENCE = '/live/audience';
  static const String MEETING_CONFIG = '/meeting/config';
  static const String MEETING = '/meeting';
  static const String SETTINGS = '/settings';
  static const String AUDIO_LIVE_LIST = '/audio_live/audio_live_list';
  static const String AUDIO_LIVE_CREATE = '/audio_live/audio_config';
  static const String AUDIO_LIVE = '/audio_live/live';
  static const String AUDIO_LIVE_AUDIENCE = '/audio_live/audience';

  static Map<String, WidgetBuilder> _routes;
}
