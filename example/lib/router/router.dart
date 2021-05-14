import 'package:FlutterRTC/module/audience/audience_page.dart';
import 'package:FlutterRTC/module/connect/connect_page.dart';
import 'package:FlutterRTC/module/host/host_page.dart';
import 'package:FlutterRTC/module/meeting/meeting_page.dart';
import 'package:flutter/widgets.dart';

class RouterManager {
  static initRouters() {
    _routes = {
      CONNECT: (context) => ConnectPage(),
      MEETING: (context) => MeetingPage(),
      HOST: (context) => HostPage(),
      AUDIENCE: (context) => AudiencePage(),
    };
    return _routes;
  }

  static const String CONNECT = '/connect';
  static const String MEETING = '/meeting';
  static const String HOST = '/host';
  static const String AUDIENCE = '/audience';

  static Map<String, WidgetBuilder> _routes;
}
