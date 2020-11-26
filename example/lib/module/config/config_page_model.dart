import 'dart:async';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'config_page_contract.dart';

class ConfigPageModel extends AbstractModel implements Model {
  // @override
  // void loadLiveRoomList(
  //   bool reset,
  //   void Function(RoomList list) onLoaded,
  //   void Function(String info) onLoadError,
  // ) {
  //   if (reset) _page = 0;
  //   Http.get(
  //     GlobalConfig.host + '/live_room',
  //     null,
  //     (error, data) {
  //       List<Room> list = List();
  //       Map<String, dynamic> rooms = jsonDecode(data);
  //       rooms.forEach((key, value) {
  //         Room room = Room(key, value['user_id'], value['mcu_url']);
  //         list.add(room);
  //       });
  //       onLoaded(RoomList(list));
  //     },
  //     (error) {
  //       onLoadError("loadLiveRoomList error, error = $error");
  //     },
  //     tag,
  //   );
  // }

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
      onPreviewStarted(VideoStreamWidget(User.unknown("config"), stream));
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
    ConfigMode mode,
    String id,
    void Function(BuildContext context) onJoined,
    void Function(BuildContext context, String info) onJoinError,
  ) async {
    String roomId = (id == null || id.isEmpty) ? _generateRoomId() : id;
    RongIMClient.joinChatRoom(roomId, -1);
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: roomId,
      roomConfig: RCRTCRoomConfig(
        mode != ConfigMode.Live ? RCRTCRoomType.Normal : RCRTCRoomType.Live,
        mode != ConfigMode.Audio ? RCRTCLiveType.AudioVideo : RCRTCLiveType.Audio,
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

  // @override
  // void joinLiveRoom(
  //   BuildContext context,
  //   String roomId,
  //   void Function(BuildContext context) onJoined,
  //   void Function(BuildContext context, String info) onJoinError,
  // ) {
  //   RongIMClient.connect(
  //     DefaultData.user.token,
  //     (code, userId) async {
  //       if (code == RCRTCErrorCode.OK || code == RCRTCErrorCode.ALREADY_CONNECTED) {
  //         RongIMClient.joinChatRoom(roomId, -1);
  //
  //         onJoined(context);
  //       } else {
  //         onJoinError(context, 'requestJoinLiveRoom connect error, code = $code');
  //       }
  //     },
  //   );
  // }

  @override
  void exit() {
    RCRTCEngine.getInstance().unInit();
    RongIMClient.disconnect(false);
  }

// int _page = 0;
}
