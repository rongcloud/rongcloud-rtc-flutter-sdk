import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../colors.dart';
import 'audio_mix_mode_selector.dart';
import 'resizable_tabs.dart' as TabBar;

class _Effect {
  String name;
  int id;

  _Effect(this.name, this.id);
}

class _EffectConfig {
  int effect;
  int volume;
  int loop;

  _EffectConfig.config()
      : effect = 0,
        volume = 100,
        loop = 1;
}

class _MixConfig {
  AudioMixerMode mode;
  int music;
  int volume;
  int mixVolume;
  bool playback;
  int playbackVolume;

  _MixConfig.config()
      : mode = AudioMixerMode.MIX,
        music = 0,
        volume = 100,
        mixVolume = 100,
        playback = false,
        playbackVolume = 100;
}

class BottomAudioEffectMixSettingsSheet {
  static void show() {
    showModalBottomSheet(
      context: ContextHolder.currentContext,
      backgroundColor: ColorConfig.bottomSheetBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (context) {
        return _BottomAudioEffectMixSettingsSheet();
      },
    );
  }
}

class _BottomAudioEffectMixSettingsSheet extends StatefulWidget {
  @override
  _BottomAudioEffectMixSettingsSheetState createState() => _BottomAudioEffectMixSettingsSheetState();
}

class _BottomAudioEffectMixSettingsSheetState extends State<_BottomAudioEffectMixSettingsSheet> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    _preloadEffects();
    _audioMixer = RCRTCAudioMixer.getInstance();
    super.initState();
  }

  Future<void> _preloadEffects() async {
    _effectManager = await RCRTCEngine.getInstance().getAudioEffectManager();
    for (int i = 0; i < EffectStrings.length; i++) {
      final _Effect effect = _Effect(EffectStrings[i], i);
      int code = await _effectManager.preloadEffectFromAssets('assets/audio/effect_$i.mp3', effect.id);
      if (code == 0) _effects.add(effect);
    }
    setState(() {
      _preloadEffect = false;
    });
  }

  @override
  void dispose() {
    _effects.forEach((effect) {
      _effectManager.unloadEffect(effect.id);
    });
    _effectManager.stopAllEffects();
    _audioMixer.stop();
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
                  '音效/混音',
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
              maxHeight: 310.dp,
            ),
            padding: EdgeInsets.only(
              bottom: 20.dp,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.dp),
                  child: TabBar.TabBar(
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
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEffectSettings(context),
                      _buildMixSettings(context),
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

  Widget _buildEffectSettings(BuildContext context) {
    return _preloadEffect
        ? Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20.dp),
                  child: _buildEffectSetter(context),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.dp),
                  child: Divider(
                    height: 1.dp,
                    color: ColorConfig.bottomSheetDividerColor,
                  ),
                ),
                _buildEffectVolumeSlider(context),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.dp),
                  child: Divider(
                    height: 1.dp,
                    color: ColorConfig.bottomSheetDividerColor,
                  ),
                ),
                _buildEffectLoopSlider(context),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.dp),
                  child: Divider(
                    height: 1.dp,
                    color: ColorConfig.bottomSheetDividerColor,
                  ),
                ),
                _buildEffectActions(context),
              ],
            ),
          );
  }

  Widget _buildEffectSetter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: '音效'.toConfigStyleSetter(
        value: _effects[effect.effect].name,
        forward: true,
        onTap: () {
          _showEffectSelectorPage(context, effect.effect).then((value) {
            setState(() {
              effect.effect = value;
            });
          });
        },
      ),
    );
  }

  Future<dynamic> _showEffectSelectorPage(BuildContext context, int index) {
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
                    '选择音效',
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
                  itemCount: _effects.length,
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
                    return _effects[index].name.toConfigStyleSetter(
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

  Widget _buildEffectVolumeSlider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: '音效音量'.toBottomSheetStyleSlider(
        current: effect.volume.toDouble(),
        max: 100,
        onChanged: (value) {
          setState(() {
            effect.volume = value.toInt();
          });
        },
      ),
    );
  }

  Widget _buildEffectLoopSlider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: '循环次数'.toBottomSheetStyleSlider(
        current: effect.loop.toDouble(),
        min: 1,
        max: 5,
        onChanged: (value) {
          setState(() {
            effect.loop = value.toInt();
          });
        },
      ),
    );
  }

  Widget _buildEffectActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 10.dp),
      child: Row(
        children: [
          '播放'.toBlueLabelButton(
            onPressed: () => _effectManager.playEffect(effect.effect, effect.loop, effect.volume),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.dp),
            child: '停止'.toRedLabelButton(
              onPressed: () => _effectManager.stopAllEffects(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixSettings(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 20.dp,
              bottom: 10.dp,
            ),
            child: _buildMixModeSelector(context),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMusicSetter(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMixVolumeSlider(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMixMixVolumeSlider(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMixPlaybackSwitcher(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMixPlaybackVolumeSlider(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(
              height: 1.dp,
              color: ColorConfig.bottomSheetDividerColor,
            ),
          ),
          _buildMixActions(context),
        ],
      ),
    );
  }

  Widget _buildMixModeSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: AudioMixModeSelector(
        title: '混音模式',
        mode: mix.mode,
        onSelected: (mode) {
          setState(() {
            mix.mode = mode;
          });
        },
      ),
    );
  }

  Widget _buildMusicSetter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.dp,
        vertical: 10.dp,
      ),
      child: '背景音乐'.toConfigStyleSetter(
        value: MusicStrings[mix.music],
        forward: true,
        onTap: () {
          _showMusicSelectorPage(context, mix.music).then((value) {
            setState(() {
              mix.music = value;
            });
          });
        },
      ),
    );
  }

  Future<dynamic> _showMusicSelectorPage(BuildContext context, int index) {
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
                    '选择音乐',
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
                  itemCount: MusicStrings.length,
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
                    return MusicStrings[index].toConfigStyleSetter(
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

  Widget _buildMixVolumeSlider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: '音量'.toBottomSheetStyleSlider(
        current: mix.volume.toDouble(),
        max: 100,
        onChanged: (value) {
          setState(() {
            mix.volume = value.toInt();
          });
        },
      ),
    );
  }

  Widget _buildMixMixVolumeSlider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: '混音音量'.toBottomSheetStyleSlider(
        current: mix.mixVolume.toDouble(),
        max: 100,
        onChanged: (value) {
          setState(() {
            mix.mixVolume = value.toInt();
          });
        },
      ),
    );
  }

  Widget _buildMixPlaybackSwitcher(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.dp,
        vertical: 5.dp,
      ),
      child: '本端播放'.toConfigStyleSwitcher(
        value: mix.playback,
        padding: false,
        onTap: () => _changeMixPlaybackConfig(),
      ),
    );
  }

  void _changeMixPlaybackConfig() {
    setState(() {
      mix.playback = !mix.playback;
    });
  }

  Widget _buildMixPlaybackVolumeSlider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: '本端播放音量'.toBottomSheetStyleSlider(
        current: mix.playbackVolume.toDouble(),
        max: 100,
        onChanged: (value) {
          setState(() {
            mix.playbackVolume = value.toInt();
          });
        },
      ),
    );
  }

  Widget _buildMixActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 10.dp),
      child: Row(
        children: [
          '播放'.toBlueLabelButton(
            onPressed: () {
              _audioMixer.setVolume(mix.volume);
              _audioMixer.setMixingVolume(mix.mixVolume);
              _audioMixer.setPlaybackVolume(mix.playbackVolume);
              _audioMixer.startMixFromAssets('assets/audio/music_${mix.music}.mp3', mix.mode, mix.playback, 1);
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.dp),
            child: '停止'.toRedLabelButton(
              onPressed: () => _audioMixer.stop(),
            ),
          ),
        ],
      ),
    );
  }

  final List<TabBar.Tab> tabs = [
    TabBar.Tab(text: '音效'),
    TabBar.Tab(text: '混音'),
  ];

  TabController _tabController;

  RCRTCAudioEffectManager _effectManager;
  final List<_Effect> _effects = List();
  bool _preloadEffect = true;
  final _EffectConfig effect = _EffectConfig.config();

  RCRTCAudioMixer _audioMixer;
  final _MixConfig mix = _MixConfig.config();
}
