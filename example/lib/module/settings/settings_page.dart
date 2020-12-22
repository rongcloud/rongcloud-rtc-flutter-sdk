import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';

import 'colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    if (_first) {
      _first = false;
      ScreenUtil.init(context, width: 375, height: 667);
    }

    return Scaffold(
      backgroundColor: ColorConfig.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: 'navigator_back'.png.image,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "设置",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: ColorConfig.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.dp),
            child: Text(
              '当前用户',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.sp,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.dp,
              right: 20.dp,
              top: 10.dp,
            ),
            child: Text(
              '用户ID：${DefaultData.user.id}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.dp),
            child: Text(
              '用户名：${DefaultData.user.name}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.dp,
              right: 20.dp,
              top: 10.dp,
            ),
            child: Wrap(
              children: [
                '退出登陆'.toRedLabelButton(
                  onPressed: () => _logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    DefaultData.logout();
    Navigator.pushNamedAndRemoveUntil(context, RouterManager.LOGIN, (route) => false);
  }

  bool _first = true;
}
