import 'dart:io';
import 'dart:typed_data';

import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_audio_mixer.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_engine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class AudioTabbedPage extends StatefulWidget {
  const AudioTabbedPage({Key key}) : super(key: key);

  @override
  _AudioTabbedPageState createState() => _AudioTabbedPageState();
}

class _AudioTabbedPageState extends State<AudioTabbedPage> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: '混音'),
    Tab(text: '音效'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        labelColor: Colors.blue,
        controller: _tabController,
        tabs: myTabs,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildMixerPage(context),
          buildEffectPage(context),
        ],
      ),
    );
  }

  int playCount = 1;
  bool preloadOne = false;
  bool preloadTwo = false;
  bool preloadThree = false;

  List<String> dropdownValues = ['本地播放，混音', '本地不播放，混音', '本地播放，不混音', '本地播放，混音，禁止麦克'];
  String dropdownValue = '本地播放，混音';

  var mixer = RCRTCAudioMixer.getInstance();

  bool effectOnePlaying = false;
  bool effectTwoPlaying = false;
  bool effectThreePlaying = false;

  double effectVolumeOne = 50.0;
  double effectVolumeTwo = 50.0;
  double effectVolumeThree = 50.0;
  double effectVolumeAll = 50.0;

  double mixLocalVolume = 50.0;
  double mixRemoteVolume = 50.0;
  double mixMicrophoneVolume = 50.0;

  bool mixPlaying = false;

  bool enablePlayback = true;
  AudioMixerMode mode = AudioMixerMode.MIX;

  buildMixerPage(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Text("选择音频"),
                ),
                Expanded(
                  flex: 50,
                  child: TextButton(
                    child: Text(
                      'assets/audio/effect2.mp3',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: IconButton(
                    icon: mixPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    onPressed: () {
                      if (mixPlaying) {
                        RCRTCAudioMixer.getInstance().pause();
                      } else {
                        RCRTCAudioMixer.getInstance().setVolume(mixLocalVolume.toInt());
                        RCRTCAudioMixer.getInstance().setVolume(mixRemoteVolume.toInt());
                        RCRTCAudioMixer.getInstance().setVolume(mixMicrophoneVolume.toInt());
                        RCRTCAudioMixer.getInstance().startMixFromAssets('assets/audio/effect2.mp3', mode, enablePlayback, 2);
                      }
                      setState(() {
                        mixPlaying = !mixPlaying;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () {
                      RCRTCAudioMixer.getInstance().stop();
                      setState(() {
                        mixPlaying = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Text("本地音量"),
                ),
                Expanded(
                  flex: 70,
                  child: Slider(
                    value: mixLocalVolume,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        mixLocalVolume = value;
                      });
                      RCRTCAudioMixer.getInstance().setPlaybackVolume(value.toInt());
                    },
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text('100'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Text("远端音量"),
                ),
                Expanded(
                  flex: 70,
                  child: Slider(
                    value: mixRemoteVolume,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        mixRemoteVolume = value;
                      });
                      RCRTCAudioMixer.getInstance().setVolume(value.toInt());
                    },
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text('100'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Text("麦克音量"),
                ),
                Expanded(
                  flex: 70,
                  child: Slider(
                    value: mixMicrophoneVolume,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        mixMicrophoneVolume = value;
                      });
                      RCRTCAudioMixer.getInstance().setMixingVolume(value.toInt());
                    },
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text('100'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Text('混音模式:'),
                ),
                Expanded(
                  flex: 80,
                  child: ListTile(
                    // title: const Text('混音模式:'),
                    trailing: DropdownButton<String>(
                      value: dropdownValue,
                      // hint: const Text('本地播放，混音'),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                        if (newValue == '本地播放，混音') {
                          mode = AudioMixerMode.MIX;
                          enablePlayback = true;
                        } else if (newValue == '本地不播放，混音') {
                          mode = AudioMixerMode.MIX;
                          enablePlayback = false;
                        } else if (newValue == '本地播放，不混音') {
                          mode = AudioMixerMode.NONE;
                          enablePlayback = true;
                        } else if (newValue == '本地播放，混音，禁止麦克') {
                          mode = AudioMixerMode.REPLACE;
                          enablePlayback = true;
                        }
                      },
                      items: <String>['本地播放，混音', '本地不播放，混音', '本地播放，不混音', '本地播放，混音，禁止麦克'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final List<String> modeList = ['本地播放，混音', '本地不播放，混音', '本地播放，不混音', '本地播放，混音，禁止麦克'];
  final Map<String, dynamic> modeMap = {
    '本地播放，混音': 0,
    '本地不播放，混音': 1,
    '本地播放，不混音': 2,
    '本地播放，混音，禁止麦克': 3,
  };

  void listDir(String path) async {
    var dir = Directory(path);
    try {
      var dirList = dir.list();
      await for (FileSystemEntity f in dirList) {
        if (f is File) {
          print('Found ==> file ${f.path}');
        } else if (f is Directory) {
          print('Found ==> dir ${f.path}');
          listDir(f.path);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> loadFile(String filePath) async {
    Directory directory = await getTemporaryDirectory();
    String dirPath = directory.path;
    String dstFilePath = directory.path + '/' + filePath;
    if (await File(dstFilePath).exists()) {
      return dstFilePath;
    }
    var pathList = filePath.split(new RegExp(r"\/"));
    pathList.removeLast();
    for (String dir in pathList) {
      dirPath += '/';
      dirPath += dir;
      if (!await Directory(dirPath).exists()) {
        Directory(dirPath).create();
      }
    }
    File file = await File(dstFilePath).create();
    ByteData data = await rootBundle.load(filePath);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await file.writeAsBytes(bytes);
    return dstFilePath;
  }

  buildEffectPage(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: Text("音效 1"),
                ),
                Expanded(
                  flex: 17,
                  child: Switch(
                    value: preloadOne,
                    onChanged: (bool value) async {
                      setState(() {
                        preloadOne = value;
                      });
                      if (preloadOne) {
                        String filePath = await loadFile('assets/audio/effect0.mp3');
                        var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                        preloadEffect.preloadEffect(filePath, 0, (error) {
                          Toast.show(
                            context,
                            "音效(1)加载完成",
                            duration: 3,
                          );
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: Slider(
                    value: effectVolumeOne,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        effectVolumeOne = value;
                      });
                      RCRTCEngine.getInstance().getAudioEffectManager().then((manager) {
                        manager.setEffectVolume(0, value.toInt());
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: IconButton(
                    icon: effectOnePlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      if (effectOnePlaying) {
                        preloadEffect.pauseEffect(0);
                      } else {
                        preloadEffect.playEffect(0, playCount, (effectVolumeOne).toInt());
                      }
                      setState(() {
                        effectOnePlaying = !effectOnePlaying;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      preloadEffect.stopEffect(0);
                      setState(() {
                        effectOnePlaying = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: Text("音效 2"),
                ),
                Expanded(
                  flex: 17,
                  child: Switch(
                    value: preloadTwo,
                    onChanged: (bool value) async {
                      setState(() {
                        preloadTwo = value;
                      });
                      if (preloadTwo) {
                        String filePath = await loadFile('assets/audio/effect1.mp3');
                        var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                        preloadEffect.preloadEffect(filePath, 1, (error) {
                          Toast.show(
                            context,
                            "音效(2)加载完成",
                            duration: 3,
                          );
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: Slider(
                    value: effectVolumeTwo,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        effectVolumeTwo = value;
                      });
                      RCRTCEngine.getInstance().getAudioEffectManager().then((manager) {
                        manager.setEffectVolume(1, value.toInt());
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: IconButton(
                    icon: effectTwoPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      if (effectTwoPlaying) {
                        preloadEffect.pauseEffect(1);
                      } else {
                        preloadEffect.playEffect(1, playCount, (effectVolumeOne).toInt());
                      }
                      setState(() {
                        effectTwoPlaying = !effectTwoPlaying;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      preloadEffect.stopEffect(1);
                      setState(() {
                        effectTwoPlaying = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: Text("音效 3"),
                ),
                Expanded(
                  flex: 17,
                  child: Switch(
                    value: preloadThree,
                    onChanged: (bool value) async {
                      setState(() {
                        preloadThree = value;
                      });
                      if (preloadThree) {
                        String filePath = await loadFile('assets/audio/effect2.mp3');
                        var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                        preloadEffect.preloadEffect(filePath, 2, (error) {
                          Toast.show(
                            context,
                            "音效(3)加载完成",
                            duration: 3,
                          );
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: Slider(
                    value: effectVolumeThree,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        effectVolumeThree = value;
                      });
                      RCRTCEngine.getInstance().getAudioEffectManager().then((manager) {
                        manager.setEffectVolume(2, value.toInt());
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: IconButton(
                    icon: effectThreePlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      if (effectThreePlaying) {
                        preloadEffect.pauseEffect(2);
                      } else {
                        preloadEffect.playEffect(2, playCount, (effectVolumeThree).toInt());
                      }
                      setState(() {
                        effectThreePlaying = !effectThreePlaying;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      preloadEffect.stopEffect(2);
                      setState(() {
                        effectThreePlaying = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Text("全局音量"),
                ),
                Expanded(
                  flex: 70,
                  child: Slider(
                    value: effectVolumeAll,
                    min: 0.0,
                    max: 100.0,
                    divisions: 1000,
                    activeColor: Colors.blue,
                    onChanged: (double value) {
                      setState(() {
                        effectVolumeAll = value;
                        effectVolumeOne = value;
                        effectVolumeTwo = value;
                        effectVolumeThree = value;
                      });
                      RCRTCEngine.getInstance().getAudioEffectManager().then((manager) {
                        manager.setEffectsVolume(value.toInt());
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text('100'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 30,
                  child: Text('设置循环次数：'),
                ),
                Expanded(
                  flex: 35,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      // icon: Icon(Icons.text_fields),
                      // labelText: count.toString(),
                      // helperText: '请输入数字：',
                    ),
                    onChanged: (str) {
                      playCount = int.parse(str);
                    },
                    autofocus: false,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        //判断keyword是否为空
                        text: this.playCount.toString(),
                        // 保持光标在最后
                        selection: TextSelection.fromPosition(
                          TextPosition(affinity: TextAffinity.downstream, offset: '${this.playCount}'.length),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 30,
                  child: TextButton(
                    child: Text('停止所有音效'),
                    onPressed: () async {
                      var preloadEffect = await RCRTCEngine.getInstance().getAudioEffectManager();
                      preloadEffect.stopAllEffects();
                      setState(() {
                        effectOnePlaying = false;
                        effectTwoPlaying = false;
                        effectThreePlaying = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
