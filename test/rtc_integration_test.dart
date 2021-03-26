import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

String key = 'z3v5yqkbv8v30';
String uid = 'frtcu1604022940878';
String token = 'HE+dGwLwrttpDpSM9aYCFcl0y3dZHpzqVguvQ1awzCHsL1rIG8Gw3A==@emx6.cn.rongnav.com;emx6.cn.rongcfg.com';
String url = 's3Hv+rNvnY7QXIKf1xiO18YSjZCBX52V3RaHj9FfjJXeS9fKs2Xeyp1A38qdQN/KnUPbyolF38qLQe76/zCuo8s8q7vJP4Wd8juBsNkp3cvZKZWryiuFrNsrq7zeK6uW3jyCq8Q+u6uHPrue2D+rntsrq6uGPqiw2jy7q8swrqDAELegwxOCmfJx7/vLbsC8V3HaiNAugpnsRd2chhCLy9UV1pyBFd/Dh0nWzddF2JvXRdbC0RPezoIuvZXdFqyW3ASLqOcysMuzce/6gKmEbbNEnZnsHIylh0OJz9IV3pzXSInI10HWzotI2J6HRo6eh0jXmNFA28vsI4CU1DKDlcYVva7wLt/6s3HvrdH2wQ==';
String add_url = '';
String media_url = 'https://rtc-data-bdcbj.rongcloud.net';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  tearDownAll(() async {
    exit(0);
  });

  group("Meeting Mode Testing", () {
    test("Connect IM", () async {
      RongIMClient.init(key);
      bool ok = await connectIM();
      expect(ok, true);
    });

    // test("Set Media Url", () async {
    //   await RCRTCEngine.getInstance().setMediaServerUrl(media_url);
    // });

    test("Init Engine", () async {
      await RCRTCEngine.getInstance().init(null);
    });

    test("Join Room", () async {
      RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
        roomId: "meeting",
        roomConfig: RCRTCRoomConfig(RCRTCRoomType.Normal, RCRTCLiveType.AudioVideo, RCRTCLiveRoleType.Broadcaster),
      );
      expect(result.code, 0);
    });

    test("Open Camera", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.startCamera();
    });

    test("Close Camera", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.stopCamera();
    });

    test("Enable Speaker", () async {
      await RCRTCEngine.getInstance().enableSpeaker(true);
    });

    test("Disable Speaker", () async {
      await RCRTCEngine.getInstance().enableSpeaker(false);
    });

    test("Create Video Output Stream", () async {
      var stream = await RCRTCEngine.getInstance().createVideoOutputStream('test');
      expect(stream != null, true);
    });

    int texture;
    test("Create Texture", () async {
      texture = await RCRTCEngine.getInstance().createVideoRenderer();
      expect(texture >= 0, true);
    });

    test("Set Texture", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.setTextureView(texture);
    });

    test("Set Video Config", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      RCRTCVideoStreamConfig config = RCRTCVideoStreamConfig(200, 1000, RCRTCFps.fps_30, RCRTCVideoResolution.RESOLUTION_720_1280);
      await stream.setVideoConfig(config);
    });

    test("Mute Video Stream", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      int code = await stream.mute(true);
      expect(code, 0);
    });

    test("Dis Mute Video Stream", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      int code = await stream.mute(false);
      expect(code, 0);
    });

    test("Mute Audio Stream", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      int code = await stream.mute(true);
      expect(code, 0);
    });

    test("Dis Mute Audio Stream", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      int code = await stream.mute(false);
      expect(code, 0);
    });

    test("Release Texture", () async {
      await RCRTCEngine.getInstance().disposeVideoRenderer(texture);
    });

    test("Publish Normal Streams", () async {
      int code = await RCRTCEngine.getInstance().getRoom().localUser.publishDefaultStreams();
      expect(code, 0);
    });

    test("UnPublish Streams", () async {
      await RCRTCEngine.getInstance().getRoom().localUser.unPublishDefaultStreams();
    });

    test("Publish Normal Video Streams", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      int code = await RCRTCEngine.getInstance().getRoom().localUser.publishStream(stream);
      expect(code, 0);
    });

    test("Preload Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.preloadEffect('assets/audio/effect0.mp3', 0);
      expect(code, 0);
    });

    test("Set Audio Effect Volume", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.setEffectsVolume(80);
      expect(code, 0);
    });

    test("Get Audio Effect Volume", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.getEffectsVolume();
      expect(code, 80);
    });

    test("Play Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.playEffect(0, 5, 100);
      expect(code, 0);
    });

    test("Pause Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.pauseEffect(0);
      expect(code, 0);
    });

    test("Resume Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.resumeEffect(0);
      expect(code, 0);
    });

    test("Pause All Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.pauseAllEffects();
      expect(code, 0);
    });

    test("Resume All Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.resumeAllEffects();
      expect(code, 0);
    });

    test("Stop Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.stopEffect(0);
      expect(code, 0);
    });

    test("Unload Audio Effect", () async {
      RCRTCAudioEffectManager manager = await RCRTCEngine.getInstance().getAudioEffectManager();
      int code = await manager.unloadEffect(0);
      expect(code, 0);
    });

    test("UnPublish Normal Video Streams", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      int code = await RCRTCEngine.getInstance().getRoom().localUser.unPublishStream(stream);
      expect(code, 0);
    });

    test("Publish Normal Audio Streams", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      int code = await RCRTCEngine.getInstance().getRoom().localUser.publishStream(stream);
      expect(code, 0);
    });

    test("UnPublish Normal Audio Streams", () async {
      var stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      int code = await RCRTCEngine.getInstance().getRoom().localUser.unPublishStream(stream);
      expect(code, 0);
    });

    test("Set Attribute Value", () async {
      RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
      MessageContent message = MessageContent();
      int code = await user.setAttributeValue('Test', '1', message);
      expect(code, 0);
    });

    test("Get Attribute Value", () async {
      RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
      Map<String, String> map = await user.getAttributes(['Test']);
      expect(map.isNotEmpty, true);
    });

    test("Delete Attribute Value", () async {
      RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
      MessageContent message = MessageContent();
      int code = await user.deleteAttributes(['Test'], message);
      expect(code, 0);
    });

    test("Subscribe Remote User Streams", () {
      var room = RCRTCEngine.getInstance().getRoom();
      room.remoteUserList.forEach((user) async {
        int code = await room.localUser.subscribeStreams(user.streamList);
        expect(code, 0);
      });
    });

    test("Switch Tiny Remote User Streams", () {
      var room = RCRTCEngine.getInstance().getRoom();
      room.remoteUserList.forEach((user) async {
        user.switchToTinyStream();
      });
    });

    test("Switch Normal Remote User Streams", () {
      var room = RCRTCEngine.getInstance().getRoom();
      room.remoteUserList.forEach((user) async {
        user.switchToNormalStream();
      });
    });

    test("Unsubscribe Remote User Streams", () {
      var room = RCRTCEngine.getInstance().getRoom();
      room.remoteUserList.forEach((user) async {
        int code = await room.localUser.unsubscribeStreams(user.streamList);
        expect(code, 0);
      });
    });

    test("Leave Room", () async {
      int code = await RCRTCEngine.getInstance().leaveRoom();
      expect(code, 0);
    });

    test("UnInit Engine", () async {
      await RCRTCEngine.getInstance().unInit();
    });

    test("Disconnect IM", () async {
      RongIMClient.disconnect(false);
    });
  });

  group("Live Mode Testing", () {
    test("Connect IM", () async {
      RongIMClient.init(key);
      bool ok = await connectIM();
      expect(ok, true);
    });

    test("Init Engine", () async {
      await RCRTCEngine.getInstance().init(null);
    });

    test("Join Room", () async {
      RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
        roomId: "living",
        roomConfig: RCRTCRoomConfig(RCRTCRoomType.Live, RCRTCLiveType.AudioVideo, RCRTCLiveRoleType.Broadcaster),
      );
      expect(result.code, 0);
    });

    test("Set Room Attribute Value", () async {
      RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
      MessageContent message = MessageContent();
      int code = await room.setRoomAttributeValue('Test', '1', message);
      expect(code, 0);
    });

    test("Get Room Attribute Value", () async {
      RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
      var map = await room.getRoomAttributes(['Test']);
      expect(map.isNotEmpty, true);
    });

    test("Delete Room Attribute Value", () async {
      RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
      MessageContent message = MessageContent();
      int code = await room.deleteRoomAttributes(['Test'], message);
      expect(code, 0);
    });

    test("Send Message", () async {
      RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
      MessageContent message = MessageContent();
      Completer completer = Completer();
      room.sendMessage(message, (id) {
        completer.complete(true);
      }, (id, code) {
        completer.complete(false);
      });
      expect(await completer.future, true);
    });

    test("Open Camera", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.startCamera();
    });

    test("Switch Camera", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      bool front = await stream.switchCamera();
      expect(front, stream.isFrontCamera());
    });

    test("Set Camera Capture Orientation", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.setCameraCaptureOrientation(RCRTCCameraCaptureOrientation.LandscapeLeft);
    });

    test("Enable Tiny Stream", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.enableTinyStream(true);
    });

    test("Disable Tiny Stream", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.enableTinyStream(false);
    });

    test("Disable Microphone", () async {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      int code = await stream.setMicrophoneDisable(true);
      expect(code, 0);
    });

    test("Enable Microphone", () async {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      int code = await stream.setMicrophoneDisable(false);
      expect(code, 0);
    });

    test("Change Volume", () async {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      await stream.adjustRecordingVolume(80);
      int volume = await stream.getRecordingVolume();
      expect(volume, 80);
    });

    RCRTCLiveInfo _info;
    test("Publish Live Streams", () async {
      Completer completer = Completer();
      RCRTCEngine.getInstance().getRoom().localUser.publishDefaultLiveStreams((info) {
        _info = info;
        completer.complete(true);
      }, (code, message) {
        completer.complete(false);
      });
      expect(await completer.future, true);
    });

    test("Change Mix Config", () async {
      RCRTCMixConfig config = RCRTCMixConfig();
      RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
      config.mode = MixLayoutMode.ADAPTIVE;
      config.hostUserId = user.id;
      List<RCRTCOutputStream> streams = await user.getStreams();
      config.hostStreamId = streams.whereType<RCRTCVideoOutputStream>().first.streamId;
      int code = await _info.setMixConfig(config);
      expect(code, 0);
    });

    // test("Add Publish Url", () async {
    //   RCRTCCodeResult result = await _info.addPublishStreamUrl(add_url);
    //   expect(result.code, 0);
    // });
    //
    // test("Remove Publish Url", () async {
    //   RCRTCCodeResult result = await _info.removePublishStreamUrl(add_url);
    //   expect(result.code, 0);
    // });

    test("UnPublish Streams", () async {
      await RCRTCEngine.getInstance().getRoom().localUser.unPublishDefaultStreams();
    });

    test("Close Camera", () async {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      await stream.stopCamera();
    });

    test("UnInit Engine", () async {
      await RCRTCEngine.getInstance().unInit();
    });

    test("Disconnect IM", () async {
      RongIMClient.disconnect(false);
    });
  });

  group("Audience Mode Testing", () {
    test("Connect IM", () async {
      RongIMClient.init(key);
      bool ok = await connectIM();
      expect(ok, true);
    });

    test("Init Engine", () async {
      await RCRTCEngine.getInstance().init(null);
    });

    test("Subscribe Live Url", () async {
//      Completer completer = Completer();
//      RCRTCEngine.getInstance().subscribeLiveStream(
//        url: url,
//        streamType: AVStreamType.audio_video,
//        onSuccess: () => completer.complete(true),
//        onAudioStreamReceived: (stream) {},
//        onVideoStreamReceived: (stream) {},
//        onError: (code, message) => completer.complete(false),
//      );
//      expect(await completer.future, true);
    });

    test("Unsubscribe Live Url", () async {
//      int code = await RCRTCEngine.getInstance().unsubscribeLiveStream(url);
//      expect(code, 0);
    });

    test("UnInit Engine", () async {
      await RCRTCEngine.getInstance().unInit();
    });

    test("Disconnect IM", () async {
      RongIMClient.disconnect(false);
    });
  });
}

Future<dynamic> connectIM() {
  Completer completer = Completer();
  RongIMClient.connect(
    token,
    (code, userId) {
      completer.complete(code == RCRTCErrorCode.OK || code == RCRTCErrorCode.ALREADY_CONNECTED);
    },
  );
  return completer.future;
}
