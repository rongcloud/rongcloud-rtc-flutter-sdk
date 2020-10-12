import 'dart:async';

import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/utils/local_storage.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:FlutterRTC/module/home/home_page_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TestWidgetsFlutterBinding.ensureInitialized();

  group("Test RCRTCEngine Interface", () {
    test("test LocalStorage", () async {
      SharedPreferences.setMockInitialValues({}); // must call this function
      await LocalStorage.init();
      LocalStorage.setString("test", "LocalStorage");
      expect(LocalStorage.getString("test"), "LocalStorage");
    });

    test("test Login", () async {
      CancelToken tag;
      await Http.post(
        GlobalConfig.host + '/token/${DefaultData.user.id}',
        null,
        (error, data) {
          LoginData loginData = LoginData.fromJson(data);
          DefaultData.user.token = loginData.token;
        },
        (error) {
          DefaultData.user.token = null;
        },
        tag,
      );
      expect(DefaultData.user.token != null, true);
    });

    String roomId = "UnitTest";
    test("test IM Client", () async {
      RongIMClient.init(GlobalConfig.appKey);
      bool ok = await connectIM(roomId);
      expect(ok, true);
    });

    RCRTCRoom _room;
    RCRTCRoomType type = RCRTCRoomType.Normal;
    test("test RTC join room ", () async {
      await RCRTCEngine.getInstance().init(null);
      RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
        roomId: roomId,
        roomConfig: RCRTCRoomConfig(type, RCRTCLiveType.AudioVideo),
      );
      expect(result.code, 0);
      _room = RCRTCEngine.getInstance().getRoom();
      expect(_room != null, true);
    });


    RCRTCVideoStreamConfig _defaultVideoStreamConfig;
    test("test RTC start camera", () async {
      _defaultVideoStreamConfig = RCRTCVideoStreamConfig(300, 1000, RCRTCFps.fps_30, RCRTCVideoResolution.RESOLUTION_720_1280);
      RCRTCCameraOutputStream camera = await RCRTCEngine.getInstance().getDefaultVideoStream();
      expect(camera != null, true);
      camera.setVideoConfig(_defaultVideoStreamConfig);
      camera.startCamera();
    });


    RCRTCLocalUser _localUser;
    test("test RTC publish stream", () async {
      _localUser = _room.localUser;
      await _localUser.publishDefaultStreams().then((code) {
        expect(code, 0);
      });
      // _localUser.unpublishDefaultStreams();
    });


    test("test RTC default audio stream", () async {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      expect(stream != null, true);

      await stream.mute(true);
      expect(stream.isMute(), true);

      await stream.mute(false);
      expect(stream.isMute(), false);

      // await stream.setMicrophoneDisable(true);
      // expect(stream.isMicrophoneDisable(), true);

    });

    test("test RTC default video stream", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      expect(stream != null, true);

      if (stream.isFrontCamera()){
        await stream.switchCamera();
        expect(stream.isFrontCamera(), false);
        await stream.switchCamera();
        expect(stream.isFrontCamera(), true);
      }
    });

  });
}

Future<dynamic> connectIM(String roomId) {
  Completer completer = new Completer();
  RongIMClient.connect(
    DefaultData.user.token,
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
