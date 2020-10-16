import 'package:FlutterRTC/frame/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'global_config.dart';
import 'router/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage.init().then((value) => runApp(FlutterRTC()));
}

class FlutterRTC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    RongIMClient.init(GlobalConfig.appKey);
    return MaterialApp(
      title: GlobalConfig.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouterManager.SPLASH,
      routes: RouterManager.initRouters(),
    );
  }
}
