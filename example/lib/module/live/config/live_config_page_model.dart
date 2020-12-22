import 'dart:async';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'live_config_page_contract.dart';

class LiveConfigPageModel extends AbstractModel implements Model {
  @override
  Future<dynamic> connectIM() async {
    Completer completer = Completer();
    await RCRTCEngine.getInstance().init(null);
    RongIMClient.connect(DefaultData.user.token, (code, userId) {
      if (code == RCRTCErrorCode.OK || code == RCRTCErrorCode.ALREADY_CONNECTED) {
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  @override
  Future<void> requestPermission(
    void Function() onGranted,
    void Function(bool camera, bool mic) onDenied,
  ) async {
    bool camera = await Permission.camera.request().isGranted;
    bool mic = await Permission.microphone.request().isGranted;
    if (camera && mic) {
      onGranted();
    } else {
      onDenied(camera, mic);
    }
  }

  @override
  Future<void> requestCameraPermission(
    void Function() onGranted,
    void Function() onDenied,
  ) async {
    if (await Permission.camera.request().isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    if (await Permission.camera.request().isGranted)
      onGranted();
    else
      onDenied();
  }

  @override
  Future<void> requestMicPermission(
    void Function() onGranted,
    void Function() onDenied,
  ) async {
    if (await Permission.microphone.request().isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    if (await Permission.microphone.request().isGranted)
      onGranted();
    else
      onDenied();
  }

  @override
  void startPreview(
    void Function(VideoStreamWidget view) onPreviewStarted,
  ) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      RCRTCVideoStreamConfig config = RCRTCVideoStreamConfig(
        300,
        1000,
        RCRTCFps.fps_30,
        RCRTCVideoResolution.RESOLUTION_720_1280,
      );
      stream.setVideoConfig(config);
      stream.startCamera();
      onPreviewStarted(VideoStreamWidget(DefaultData.user, stream));
    });
  }

  @override
  void stopPreview(
    void Function() onPreviewStopped,
  ) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      stream.stopCamera();
      onPreviewStopped();
    });
  }

  @override
  Future<dynamic> switchCamera() {
    Completer completer = Completer();
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      bool front = await stream.switchCamera();
      completer.complete(front);
    });
    return completer.future;
  }

  @override
  Future<void> joinRoom(
    BuildContext context,
    Mode mode,
    String id,
    void Function(BuildContext context) onJoined,
    void Function(BuildContext context, String info) onJoinError,
  ) async {
    if (id == null || id.isEmpty) {
      onJoinError(context, '房间名不能为空');
      return;
    }
    String roomId = id;
    RongIMClient.joinChatRoom(roomId, -1);
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: roomId,
      roomConfig: RCRTCRoomConfig(
        mode != Mode.Live ? RCRTCRoomType.Normal : RCRTCRoomType.Live,
        mode != Mode.Audio ? RCRTCLiveType.AudioVideo : RCRTCLiveType.Audio,
      ),
    );
    if (result.code == 0) {
      onJoined(context);
    } else {
      onJoinError(context, 'requestCreateLiveRoom join room error, code = ${result.code}');
    }
  }

  @override
  void exit() {
    RCRTCEngine.getInstance().unInit();
    RongIMClient.disconnect(false);
  }
}
