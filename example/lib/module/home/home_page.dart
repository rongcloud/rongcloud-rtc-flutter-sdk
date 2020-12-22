import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

import 'colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 375, height: 667);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: 'home_page_background'.png.assetImage,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 36.dp,
                  right: 20.dp,
                ),
                child: 'home_page_setting_icon'.png.image,
              ),
              onTap: () {
                Navigator.pushNamed(context, RouterManager.SETTINGS);
              },
            ),
            Divider(
              height: 43.5.dp,
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.dp),
                  child: Text(
                    "模式选择页",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            Divider(
              height: 20.dp,
            ),
            _buildModeButton(
              'meeting_mode_icon',
              '多人视频会议',
              '适用于多人音视频通话场景',
              () {
                Navigator.pushNamed(context, RouterManager.MEETING_CONFIG);
              },
            ),
            Divider(
              height: 20.dp,
            ),
            _buildModeButton(
              'live_mode_icon',
              '视频互动直播',
              '适用于主播连麦及观众场景',
              () {
                Navigator.pushNamed(context, RouterManager.LIVE_HOME);
              },
            ),
            Divider(
              height: 20.dp,
            ),
            _buildModeButton(
              'audio_live_mode_icon',
              '音频互动直播',
              '适用于多人语音通话场景',
              () {
                Navigator.pushNamed(context, RouterManager.AUDIO_LIVE_LIST);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String image, String title, String info, void onTap()) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(
          left: 20.dp,
          right: 20.dp,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 13.5.dp,
          horizontal: 24.dp,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.dp),
          color: ColorConfig.modeButtonBackgroundColor,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 24.dp),
              child: image.png.image,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
                Divider(
                  height: 5.dp,
                ),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorConfig.modeButtonInfoTextColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
