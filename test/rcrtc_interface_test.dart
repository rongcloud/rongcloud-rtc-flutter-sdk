import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

String appKey = 'z3v5yqkbv8v30';
String userName = "cvnjyte";
String userId = "frtcu1604022940878";
String token = "HE+dGwLwrttpDpSM9aYCFcl0y3dZHpzqVguvQ1awzCHsL1rIG8Gw3A==@emx6.cn.rongnav.com;emx6.cn.rongcfg.com";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  int i = 10000;
  while ((i -= 1) != 0) {
    group("Test RCRTCEngine Interface", () {
      String roomId = "ut";
      test("test IM Client", () async {
        RongIMClient.init(appKey);
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

      test("test RTC start camera", () async {
        RCRTCVideoStreamConfig _defaultVideoStreamConfig;
        _defaultVideoStreamConfig = RCRTCVideoStreamConfig(300, 1000, RCRTCFps.fps_30, RCRTCVideoResolution.RESOLUTION_720_1280);
        RCRTCCameraOutputStream camera = await RCRTCEngine.getInstance().getDefaultVideoStream();
        expect(camera != null, true);
        await camera.setVideoConfig(_defaultVideoStreamConfig);
        await camera.startCamera();
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

        await stream.setMicrophoneDisable(true);
        expect(stream.isMicrophoneDisable(), true);
      });

      test("test RTC default video stream", () async {
        RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
        expect(stream != null, true);
        stream.setCameraCaptureOrientation(RCRTCCameraCaptureOrientation.Portrait);
        if (stream.isFrontCamera()) {
          await stream.switchCamera();
          expect(stream.isFrontCamera(), false);
          await stream.switchCamera();
          expect(stream.isFrontCamera(), true);
        }
      });

      test("test RTC subscribeStreams", () async {
        RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
        RCRTCLocalUser localUser = room.localUser;

        for (RCRTCRemoteUser user in room.remoteUserList) {
          localUser.subscribeStreams(user.streamList);
          user.streamList.whereType<RCRTCVideoInputStream>().forEach((stream) {});
        }

        room.onRemoteUserPublishResource = (user, streams) {
          localUser.subscribeStreams(streams);
          streams.whereType<RCRTCVideoInputStream>().forEach((stream) {});
          streams.whereType<RCRTCAudioInputStream>().forEach((stream) {});
        };

        room.onRemoteUserUnPublishResource = (user, streams) {
          localUser.unsubscribeStreams(streams);
          streams.whereType<RCRTCVideoInputStream>().forEach((stream) {});
          streams.whereType<RCRTCAudioInputStream>().forEach((stream) {});
        };

        room.onRemoteUserLeft = (user) {};
      });

      test("test RTC changeVideoStreamState", () async {
        RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
        var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
        await stream.stopCamera();
        await localUser.unPublishStreams([stream]);

        RCRTCVideoStreamConfig cfg = RCRTCVideoStreamConfig(300, 1000, RCRTCFps.fps_30, RCRTCVideoResolution.RESOLUTION_720_1280);
        await stream.setVideoConfig(cfg);
        await stream.startCamera().then((value) {
          localUser.publishStreams([stream]);
        });
      });

      test("test RTC setCameraFocusPositionInPreview", () async {
        var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
        bool val = await stream.isCameraFocusSupported();
        if (val) {
          stream.setCameraFocusPositionInPreview(20, 20);
        }
        val = await stream.isCameraExposurePositionSupported();
        if (val) {
          stream.setCameraExposurePositionInPreview(20, 20);
        }
      });

      test("test RTC registerStatusReportListener", () async {
        RCRTCEngine.getInstance().registerStatusReportListener(null);
        RCRTCEngine.getInstance().unRegisterStatusReportListener();
      });

      test("test RTC enableSpeaker", () async {
        RCRTCEngine.getInstance().enableSpeaker(true);
        RCRTCEngine.getInstance().enableSpeaker(false);
      });

      test("test RTC AudioEffectManager", () async {
        RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
        manager.release();
      });

      test("test RTC RCRTCAudioMixer", () async {
        await RCRTCAudioMixer.getInstance().getMixingVolume();
        await RCRTCAudioMixer.getInstance().getCurrentPosition();
        await RCRTCAudioMixer.getInstance().getPlaybackVolume();
      });

      test("test RTC AudioEffect", () async {
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
      });

      // Future<RCRTCFileVideoOutputStream> createFileVideoOutputStream({@required String path, @required String tag, bool replace = true, bool playback = true})

      test("test RTC leaveRoom", () async {
        RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
        var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
        await stream.stopCamera();
        await localUser.unPublishStreams([stream]);
        int code = await RCRTCEngine.getInstance().leaveRoom();
        RCRTCEngine.getInstance().unInit();
        RongIMClient.disconnect(false);
        expect(code, 0);
      });
    });
  }
}

Future<dynamic> connectIM(String roomId) {
  Completer completer = new Completer();
  RongIMClient.connect(
    token,
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
