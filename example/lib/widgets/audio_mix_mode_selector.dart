import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class AudioMixModeSelector extends StatelessWidget {
  AudioMixModeSelector({
    @required this.title,
    @required this.mode,
    @required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 10.dp,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  mode == AudioMixerMode.NONE ? selectedRadio() : unselectedRadio(),
                  Padding(
                    padding: EdgeInsets.only(left: 5.dp),
                    child: Text(
                      '不混合',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelected(AudioMixerMode.NONE);
              },
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  mode == AudioMixerMode.MIX ? selectedRadio() : unselectedRadio(),
                  Padding(
                    padding: EdgeInsets.only(left: 5.dp),
                    child: Text(
                      '混合',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelected(AudioMixerMode.MIX);
              },
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  mode == AudioMixerMode.REPLACE ? selectedRadio() : unselectedRadio(),
                  Padding(
                    padding: EdgeInsets.only(left: 5.dp),
                    child: Text(
                      '替换',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelected(AudioMixerMode.REPLACE);
              },
            ),
          ],
        ),
      ],
    );
  }

  final String title;
  final AudioMixerMode mode;
  final Function(AudioMixerMode mode) onSelected;
}
