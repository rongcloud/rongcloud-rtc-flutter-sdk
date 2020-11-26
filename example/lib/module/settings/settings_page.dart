import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

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
      body: Container(
        color: Colors.grey.shade300,
        child: Column(
          children: [
            AppBar(
              title: Text(
                "设置",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0.sp,
                  decoration: TextDecoration.none,
                ),
              ),
              iconTheme: IconThemeData.fallback(),
              backgroundColor: Colors.white,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: 20.0.width,
                      top: 15.0.height,
                      bottom: 15.0.height,
                    ),
                    child: Text(
                      "视频全局配置",
                      style: TextStyle(
                        fontSize: 12.0.sp,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      height: 40.0.height,
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        left: 20.0.width,
                        right: 20.0.width,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "视频分辨率",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Spacer(),
                          Text(
                            Resolutions[DefaultData.videoConfig.resolution.index],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _selectResolution(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 1.0.height),
                  ),
                  GestureDetector(
                    child: Container(
                      height: 40.0.height,
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        left: 20.0.width,
                        right: 20.0.width,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "大小流",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Spacer(),
                          Switch(
                            value: DefaultData.enableTinyStream,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() {
                                DefaultData.enableTinyStream = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _changeTinyStreamState(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectResolution() {
    Navigator.pushNamed(context, RouterManager.SET_RESOLUTION).then((value) {
      setState(() {
        DefaultData.videoConfig.resolution = RCRTCVideoResolution.values[value];
      });
    });
  }

  void _changeTinyStreamState() {
    setState(() {
      DefaultData.enableTinyStream = !DefaultData.enableTinyStream;
    });
  }

  bool _first = true;
}
