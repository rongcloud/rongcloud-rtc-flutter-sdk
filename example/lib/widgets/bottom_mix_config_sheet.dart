import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../colors.dart';
import 'buttons.dart';

typedef MixConfigSelected = void Function(RCRTCMixConfig config);

class BottomMixConfigSheet {
  static void show(BuildContext context, {MixConfigSelected selected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConfig.bottomSheetBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (BuildContext context) {
        return MixConfigSheetWidget(selected);
      },
    );
  }
}

class MixConfigSheetWidget extends StatefulWidget {
  final MixConfigSelected _selected;

  MixConfigSheetWidget(this._selected);

  @override
  _MixConfigSheetState createState() => _MixConfigSheetState();
}

class _MixConfigSheetState extends State<MixConfigSheetWidget> {
  MixLayoutMode _mode = MixLayoutMode.SUSPENSION;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.dp,
        left: 20.dp,
        right: 20.dp,
        bottom: 20.dp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "合流布局",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  decoration: TextDecoration.none,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: 'pop_page_close'.png.image.toButton(
                      onPressed: () => Navigator.pop(context),
                    ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 20.dp,
                  bottom: 20.dp,
                ),
                child: Text(
                  "布局类型:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _mode == MixLayoutMode.CUSTOM ? selectedRadio() : unselectedRadio(),
                    Padding(
                      padding: EdgeInsets.only(left: 5.dp),
                      child: Text(
                        '自定义布局',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _onMixConfigChecked(MixLayoutMode.CUSTOM),
              ),
              Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _mode == MixLayoutMode.SUSPENSION ? selectedRadio() : unselectedRadio(),
                    Padding(
                      padding: EdgeInsets.only(left: 5.dp),
                      child: Text(
                        '悬浮布局',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _onMixConfigChecked(MixLayoutMode.SUSPENSION),
              ),
              Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _mode == MixLayoutMode.ADAPTIVE ? selectedRadio() : unselectedRadio(),
                    Padding(
                      padding: EdgeInsets.only(left: 5.dp),
                      child: Text(
                        '自适应布局',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _onMixConfigChecked(MixLayoutMode.ADAPTIVE),
              ),
            ],
          )
        ],
      ),
    );
  }

  _onMixConfigChecked(MixLayoutMode mode) async {
    if (_mode == mode) return;

    _mode = mode;
    RCRTCMixConfig config = RCRTCMixConfig();
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCVideoOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    config.hostStreamId = stream.streamId;
    config.hostUserId = room.localUser.id;
    config.mode = mode;

    VideoLayout videoLayout = new VideoLayout();
    videoLayout.bitrate = 256;
    videoLayout.width = 720;
    videoLayout.height = 1280;
    videoLayout.fps = 25;
    VideoConfig videoConfig = new VideoConfig();
    videoConfig.videoLayout = videoLayout;

    AudioConfig audioConfig = new AudioConfig();
    audioConfig.bitrate = 128;

    MediaConfig mediaConfig = new MediaConfig();
    mediaConfig.audioConfig = audioConfig;
    mediaConfig.videoConfig = videoConfig;

    config.mediaConfig = mediaConfig;

    if (mode == MixLayoutMode.CUSTOM) {
      CustomLayout main = CustomLayout();
      main.streamId = stream.streamId;
      main.x = 0;
      main.y = 0;
      main.width = 720;
      main.height = 1280;
      main.userId = room.localUser.id;

      List<CustomLayout> list = List();
      list.add(main);

      int index = 1;

      for (RCRTCRemoteUser user in room.remoteUserList) {
        user.streamList.whereType<RCRTCVideoInputStream>().forEach((stream) {
          CustomLayout customLayout = new CustomLayout();
          customLayout.x = 620 - 10 * index;
          customLayout.y = 1180 - 10 * index;
          customLayout.width = 100;
          customLayout.height = 100;
          customLayout.userId = user.id;
          customLayout.streamId = stream.streamId;
          list.add(customLayout);

          index++;
        });
      }

      CustomLayoutList customLayoutList = CustomLayoutList(list);
      config.customLayoutList = customLayoutList;
    }

    widget._selected(config);
    setState(() {});
  }
}
