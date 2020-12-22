import 'dart:async';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'audio_live_create_contract.dart';

class AudioLiveCreateModel extends AbstractModel implements Model {
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
  void exit() {
    RCRTCEngine.getInstance().unInit();
    RongIMClient.disconnect(false);
  }

  @override
  Future<void> joinRoom(
    BuildContext context,
    Mode mode,
    String id,
    void Function(BuildContext context) onJoined,
    void Function(BuildContext context, String info) onJoinError,
  ) async {
    String roomId = (id == null || id.isEmpty) ? _generateRoomId() : id;
    RongIMClient.joinChatRoom(roomId, -1);
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: roomId,
      roomConfig: RCRTCRoomConfig(
        RCRTCRoomType.Live,
        RCRTCLiveType.Audio,
      ),
    );
    if (result.code == 0) {
      onJoined(context);
    } else {
      onJoinError(context, 'requestCreateLiveRoom join room error, code = ${result.code}');
    }
  }

  String _generateRoomId() {
    int current = DateTime.now().millisecondsSinceEpoch % 999999;
    return "$current";
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
}
