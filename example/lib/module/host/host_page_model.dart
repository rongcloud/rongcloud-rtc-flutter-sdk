import 'dart:async';

import 'package:FlutterRTC/data/constants.dart' as Util;
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:FlutterRTC/widgets/ui.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'host_page_contract.dart';

class HostPageModel extends AbstractModel implements Model {
  Future<UserView> createLocalView() async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    UserView view = UserView(DefaultData.user);
    view.videoStream = stream;
    view.mirror = true;
    return view;
  }

  @override
  Future<bool> changeMic(bool open) async {
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    if (open) {
      PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        return false;
      }
    }
    await stream.setMicrophoneDisable(!open);
    return !stream.isMicrophoneDisable();
  }

  @override
  Future<bool> changeCamera(bool open) async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    if (open) {
      PermissionStatus status = await Permission.camera.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        return false;
      }
      await stream.startCamera();
      return true;
    } else {
      await stream.stopCamera();
      return false;
    }
  }

  Future<int> publishStream(
    dynamic stream,
    Util.Callback callback,
  ) async {
    RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
    Completer<int> completer = Completer();
    user.publishLiveStream(
      stream,
      (info) {
        callback(info);
        completer.complete(0);
      },
      (code, message) {
        completer.complete(code);
      },
    );
    return completer.future;
  }

  @override
  Future<bool> changeAudio(
    bool publish,
    Util.Callback callback,
  ) async {
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
    int code = publish ? await publishStream(stream, callback) : await user.unPublishStream(stream);
    if (code != RCRTCErrorCode.OK) 'Audio stream ${publish ? 'publish' : 'unPublish'} error, code = $code'.toast();
    return code == RCRTCErrorCode.OK ? publish : !publish;
  }

  @override
  Future<bool> changeVideo(
    bool publish,
    Util.Callback callback,
  ) async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
    int code = publish ? await publishStream(stream, callback) : await user.unPublishStream(stream);
    if (code != RCRTCErrorCode.OK) 'Video stream ${publish ? 'publish' : 'unPublish'} error, code = $code'.toast();
    return code == RCRTCErrorCode.OK ? publish : !publish;
  }

  @override
  Future<bool> changeFrontCamera(bool front) async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return await stream.switchCamera();
  }

  @override
  Future<bool> changeSpeaker(bool open) async {
    await RCRTCEngine.getInstance().enableSpeaker(open);
    return open;
  }

  @override
  Future<void> changeVideoConfig(RCRTCVideoStreamConfig config) async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    await stream.setVideoConfig(config);
  }

  @override
  Future<bool> changeTinyVideoConfig(RCRTCVideoStreamConfig config) async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return stream.setTinyVideoConfig(config);
  }

  @override
  void switchToNormalStream(String id) {
    RCRTCRemoteUser user = RCRTCEngine.getInstance().getRoom().remoteUserList.firstWhere((user) => user.id == id, orElse: () => null);
    user?.switchToNormalStream();
  }

  @override
  void switchToTinyStream(String id) {
    RCRTCRemoteUser user = RCRTCEngine.getInstance().getRoom().remoteUserList.firstWhere((user) => user.id == id, orElse: () => null);
    user?.switchToTinyStream();
  }

  @override
  Future<RCRTCAudioInputStream> changeRemoteAudioStatus(String id, bool subscribe) async {
    var room = RCRTCEngine.getInstance().getRoom();
    var user = room.localUser;
    var audios = room.remoteUserList
        .firstWhere(
          (element) => element.id == id,
          orElse: () => null,
        )
        ?.streamList
        ?.whereType<RCRTCAudioInputStream>();
    if (audios?.isEmpty ?? true) return null;
    var stream = audios.first;

    int code = subscribe ? await user.subscribeStream(stream) : await user.unsubscribeStream(stream);
    if (code != RCRTCErrorCode.OK)
      return subscribe ? null : stream;
    else
      return subscribe ? stream : null;
  }

  @override
  Future<RCRTCVideoInputStream> changeRemoteVideoStatus(String id, bool subscribe) async {
    var room = RCRTCEngine.getInstance().getRoom();
    var user = room.localUser;
    var videos = room.remoteUserList
        .firstWhere(
          (element) => element.id == id,
          orElse: () => null,
        )
        ?.streamList
        ?.whereType<RCRTCVideoInputStream>();
    if (videos?.isEmpty ?? true) return null;
    var stream = videos.first;
    int code = subscribe ? await user.subscribeStream(stream) : await user.unsubscribeStream(stream);
    if (code != RCRTCErrorCode.OK)
      return subscribe ? null : stream;
    else
      return subscribe ? stream : null;
  }

  @override
  Future<int> exit() async {
    _release();
    RCRTCEngine.getInstance().unRegisterStatusReportListener();
    int code = await RCRTCEngine.getInstance().leaveRoom();
    RCRTCEngine.getInstance().unInit();
    return code;
  }

  // void _create(String url) {
  //   String key = DefaultData.user.key;
  //   String uid = DefaultData.user.id;
  //   String rid = RCRTCEngine.getInstance().getRoom().id;
  //   Http.post(
  //     GlobalConfig.host + '/test_room/$rid',
  //     {'user_id': uid, 'user_name': 'Test', 'mcu_url': url, 'key': key},
  //     (error, data) {
  //       print("_create success, error = $error, data = $data");
  //     },
  //     (error) {
  //       print("_create error, error = $error");
  //     },
  //     tag,
  //   );
  // }

  void _release() {
    String key = DefaultData.user.key;
    String id = RCRTCEngine.getInstance().getRoom().id;
    Http.delete(
      GlobalConfig.host + '/test_room/$id',
      {'key': key},
      (error, data) {
        print("_release success, error = $error, data = $data");
      },
      (error) {
        print("_release error, error = $error");
      },
      tag,
    );
  }
}
