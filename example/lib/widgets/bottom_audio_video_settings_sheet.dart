import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/resolution_selector.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../colors.dart';
import 'resizable_tabs.dart' as TabBar;

abstract class BottomAudioVideoSettingsSheetCallback {
  void changedVideoFPS(RCRTCFps fps);

  void changedVideoResolution(Resolution resolution);

  void changedVideoLocalMirror(bool mirror);

  void changedAudioSpeakerState(bool speaker);
}

class BottomAudioVideoSettingsSheet {
  static void show(
    Config config, {
    BottomAudioVideoSettingsSheetCallback callback,
  }) {
    showModalBottomSheet(
      context: ContextHolder.currentContext,
      backgroundColor: ColorConfig.bottomSheetBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (context) {
        return _BottomAudioVideoSettingsSheet(config, callback);
      },
    );
  }
}

class _BottomAudioVideoSettingsSheet extends StatefulWidget {
  _BottomAudioVideoSettingsSheet(this.config, this.callback);

  @override
  _BottomAudioVideoSettingsSheetState createState() => _BottomAudioVideoSettingsSheetState(config, callback);

  final Config config;
  final BottomAudioVideoSettingsSheetCallback callback;
}

class _BottomAudioVideoSettingsSheetState extends State<_BottomAudioVideoSettingsSheet> with SingleTickerProviderStateMixin {
  _BottomAudioVideoSettingsSheetState(this.config, this.callback);

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20.dp,
              right: 20.dp,
              top: 20.dp,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '设置',
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.white,
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
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: 260.dp,
            ),
            padding: EdgeInsets.only(
              left: 20.dp,
              right: 20.dp,
              bottom: 20.dp,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar.TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    decoration: TextDecoration.none,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15.sp,
                    decoration: TextDecoration.none,
                  ),
                  labelPadding: EdgeInsets.only(right: 20.dp),
                  indicatorPadding: EdgeInsets.only(right: 20.dp),
                  indicatorColor: Colors.white,
                  tabs: tabs,
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVideoSettings(context),
                      _buildAudioSettings(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSettings(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.dp),
            child: _buildFPSSetter(context),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildResolutionSelector(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMirrorSwitcher(context),
        ],
      ),
    );
  }

  Widget _buildFPSSetter(BuildContext context) {
    return '帧率'.toConfigStyleSetter(
      value: FPSStrings[config.fps.index],
      onTap: () {
        _showFPSSelectorPage(context, config.fps.index).then((value) {
          setState(() {
            config.fps = RCRTCFps.values[value];
            callback?.changedVideoFPS(config.fps);
          });
        });
      },
    );
  }

  Future<dynamic> _showFPSSelectorPage(BuildContext context, int index) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: ColorConfig.bottomSheetBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '选择帧率',
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(20.dp),
                      child: 'pop_page_close'.png.image.toButton(
                            onPressed: () => Navigator.pop(context, index),
                          ),
                    ),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 300.dp,
                ),
                padding: EdgeInsets.only(
                  left: 20.dp,
                  right: 20.dp,
                  bottom: 20.dp,
                ),
                child: ListView.separated(
                  itemCount: FPSStrings.length,
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.dp),
                      child: Divider(
                        height: 1.dp,
                        color: ColorConfig.bottomSheetDividerColor,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    return FPSStrings[index].toConfigStyleSetter(
                      value: '',
                      onTap: () => Navigator.pop(context, index),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildResolutionSelector(BuildContext context) {
    return ResolutionSelector(
      title: '分辨率',
      resolution: config.resolution,
      onSelected: (resolution) {
        setState(() {
          config.resolution = resolution;
          callback?.changedVideoResolution(config.resolution);
        });
      },
    );
  }

  Widget _buildMirrorSwitcher(BuildContext context) {
    return '本地镜像'.toConfigStyleSwitcher(
      value: config.mirror,
      padding: false,
      onTap: () => _changeMirrorConfig(),
    );
  }

  void _changeMirrorConfig() {
    setState(() {
      config.mirror = !config.mirror;
      callback?.changedVideoLocalMirror(config.mirror);
    });
  }

  Widget _buildAudioSettings(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.dp),
            child: _buildSpeakerSwitcher(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerSwitcher(BuildContext context) {
    return '开启扬声器'.toConfigStyleSwitcher(
      value: config.speaker,
      padding: false,
      onTap: () => _changeSpeakerConfig(),
    );
  }

  void _changeSpeakerConfig() {
    setState(() {
      config.speaker = !config.speaker;
      callback?.changedAudioSpeakerState(config.speaker);
    });
  }

  final Config config;
  final BottomAudioVideoSettingsSheetCallback callback;

  final List<TabBar.Tab> tabs = [
    TabBar.Tab(text: '视频'),
    TabBar.Tab(text: '音频'),
  ];

  TabController _tabController;
}
