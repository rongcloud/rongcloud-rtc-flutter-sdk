import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'global_config.dart';
import 'login_page.dart';

void main() => runApp(FlutterRTC());

class FlutterRTC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RongIMClient.init(GlobalConfig.appKey);
    return MaterialApp(
      title: GlobalConfig.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
