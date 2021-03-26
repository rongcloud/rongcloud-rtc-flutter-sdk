import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

const String APP_KEY = 'z3v5yqkbv8v30';
const String USER_NAME = "cvnjyte";
const String USER_ID = "frtcu1604022940878";
const String TOKEN = "HE+dGwLwrttpDpSM9aYCFcl0y3dZHpzqVguvQ1awzCHsL1rIG8Gw3A==@emx6.cn.rongnav.com;emx6.cn.rongcfg.com";
const String ROOM_ID = "ut";

const RCRTCRoomType type = RCRTCRoomType.Normal;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Test RTC Engine'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _testCounter = 10;
  RCRTCTextureView _mainView;
  RCRTCTextureView _subView;

  void _incrementCounter() async {
    if (_testCounter <= 0) {
      return;
    }

    RongIMClient.init(APP_KEY);
    bool ok = await connectIM(ROOM_ID);
    if (!ok) {
      throw 'RongIMClient error';
    }

    await RCRTCEngine.getInstance().init(null);
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: ROOM_ID,
      roomConfig: RCRTCRoomConfig(type, RCRTCLiveType.AudioVideo, RCRTCLiveRoleType.Broadcaster),
    );
    if (result.code != 0) {
      throw 'joinRoom failed ' + result.code.toString();
    }

    RCRTCVideoStreamConfig defaultVideoStreamConfig = RCRTCVideoStreamConfig(300, 1000, RCRTCFps.fps_30, RCRTCVideoResolution.RESOLUTION_720_1280);
    RCRTCCameraOutputStream vs = await RCRTCEngine.getInstance().getDefaultVideoStream();
    if (vs == null) {
      throw 'getDefaultVideoStream failed';
    }
    await vs.setVideoConfig(defaultVideoStreamConfig);

    RCRTCTextureView videoView = RCRTCTextureView(
      (videoView, id) {
        vs.setTextureView(id);
        vs.startCamera();
      },
      mirror: true,
    );

    setState(() {
      _mainView = videoView;
    });

    await RCRTCEngine.getInstance().getRoom().localUser.publishDefaultStreams().then((code) {
      if (code != 0) {
        throw 'publishDefaultStreams failed';
      }
    });

    RCRTCMicOutputStream as = await RCRTCEngine.getInstance().getDefaultAudioStream();
    if (as == null) {
      throw 'getDefaultAudioStream failed';
    }

    await as.mute(true);
    if (!as.isMute()) {
      throw 'mute failed';
    }

    await as.mute(false);
    if (as.isMute()) {
      throw 'mute failed';
    }

    await as.setMicrophoneDisable(true);
    if (as.isMicrophoneDisable()) {
      throw 'setMicrophoneDisable failed';
    }

    vs.setCameraCaptureOrientation(RCRTCCameraCaptureOrientation.Portrait);
    if (vs.isFrontCamera()) {
      await vs.switchCamera();
      bool ret = await vs.switchCamera();
      if (ret != vs.isFrontCamera()) {
        throw 'switchCamera failed';
      }
    }

    for (RCRTCRemoteUser user in RCRTCEngine.getInstance().getRoom().remoteUserList) {
      RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(user.streamList);
      user.streamList.whereType<RCRTCVideoInputStream>().forEach((stream) {
        RCRTCTextureView view = RCRTCTextureView(
          (view, id) async {
            stream.setTextureView(id);
          },
        );
        setState(() {
          _subView = view;
        });
      });
    }

    RCRTCEngine.getInstance().getRoom().onRemoteUserPublishResource = (user, streams) {
      RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(streams);
      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {});
      streams.whereType<RCRTCAudioInputStream>().forEach((stream) {});
    };

    RCRTCEngine.getInstance().getRoom().onRemoteUserUnPublishResource = (user, streams) {
      RCRTCEngine.getInstance().getRoom().localUser.unsubscribeStreams(streams);
      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {});
      streams.whereType<RCRTCAudioInputStream>().forEach((stream) {});
    };

    RCRTCEngine.getInstance().getRoom().onRemoteUserLeft = (user) {};

    bool val = await vs.isCameraFocusSupported();
    if (val) {
      vs.setCameraFocusPositionInPreview(20, 20);
    }
    val = await vs.isCameraExposurePositionSupported();
    if (val) {
      vs.setCameraExposurePositionInPreview(20, 20);
    }

    RCRTCEngine.getInstance().registerStatusReportListener(null);
    RCRTCEngine.getInstance().unRegisterStatusReportListener();

    RCRTCEngine.getInstance().enableSpeaker(true);
    RCRTCEngine.getInstance().enableSpeaker(false);

    await RCRTCAudioMixer.getInstance().getMixingVolume();
    await RCRTCAudioMixer.getInstance().getCurrentPosition();
    await RCRTCAudioMixer.getInstance().getPlaybackVolume();

    RCRTCAudioEffectManager am = await RCRTCEngine.getInstance().getAudioEffectManager();
    await am.preloadEffect('assets/audio/effect0.mp3', 0);
    await am.getEffectsVolume();
    await am.setEffectsVolume(100);
    await am.playEffect(0, 10, 100);
    await am.pauseEffect(0);
    await am.resumeEffect(0);
    await am.pauseAllEffects();
    await am.resumeAllEffects();
    await am.stopEffect(0);
    await am.stopAllEffects();
    await am.unloadEffect(0);
    am.release();

    if (_testCounter > 0) {
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await vs.stopCamera();
        await RCRTCEngine.getInstance().getRoom().localUser.unPublishDefaultStreams();
        await RCRTCEngine.getInstance().leaveRoom();
        RCRTCEngine.getInstance().unInit();
        RongIMClient.disconnect(false);
        setState(() {
          --_testCounter;
        });
        if (_testCounter > 0) {
          _incrementCounter();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title),
        actions: [
          Text(
            '设置测试次数：',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                // icon: Icon(Icons.text_fields),
                // labelText: count.toString(),
                // helperText: '请输入数字：',
              ),
              onChanged: (str) {
                _testCounter = int.parse(str);
              },
              autofocus: false,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  //判断keyword是否为空
                  text: this._testCounter.toString(),
                  // 保持光标在最后
                  selection: TextSelection.fromPosition(
                    TextPosition(affinity: TextAffinity.downstream, offset: '${this._testCounter}'.length),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Container(
                child: _mainView != null ? _mainView : Container(),
                color: Colors.black,
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                child: _subView != null ? _subView : Container(),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<dynamic> connectIM(String roomId) {
    Completer completer = new Completer();
    RongIMClient.connect(
      TOKEN,
      (code, userId) {
        if (code == RCRTCErrorCode.OK || code == RCRTCErrorCode.ALREADY_CONNECTED) {
          RongIMClient.joinChatRoom(roomId, -1);
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }
}
