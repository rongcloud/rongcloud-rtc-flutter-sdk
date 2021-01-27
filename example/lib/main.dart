import 'package:FlutterRTC/frame/utils/local_storage.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_engine.dart';

import 'global_config.dart';
import 'router/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  RongIMClient.setServerInfo(GlobalConfig.navServer, GlobalConfig.fileServer);
  RongIMClient.init(GlobalConfig.appKey);

  if (GlobalConfig.mediaServer.isNotEmpty) {
    RCRTCEngine.getInstance().setMediaServerUrl(GlobalConfig.mediaServer);
  }

  LocalStorage.init().then((value) => runApp(FlutterRTC()));
}

class FlutterRTC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    return MaterialApp(
      navigatorKey: ContextHolder.key,
      title: GlobalConfig.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouterManager.LOGIN,
      routes: RouterManager.initRouters(),
    );
  }
}
