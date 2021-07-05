import 'package:collection/collection.dart' show IterableExtension;
import 'package:handy_toast/handy_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rc_rtc_flutter_example/widgets/ui.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'meeting_page_contract.dart';

class MeetingPageModel extends AbstractModel implements Model {
  Future<UserView> createLocalView() async {
    RCRTCCameraOutputStream? stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    UserView view = UserView(DefaultData.user!);
    view.videoStream = stream;
    view.mirror = true;
    return view;
  }

  @override
  Future<bool> changeMic(bool open) async {
    RCRTCMicOutputStream? stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    if (open) {
      PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        // if (Platform.isAndroid && status.isPermanentlyDenied) {
        //   openAppSettings();
        // }
        // if (Platform.isIOS && status.isRestricted) {
        //   openAppSettings();
        // }
        return false;
      }
    }
    if (stream == null) return false;
    await stream.setMicrophoneDisable(!open);
    return !stream.isMicrophoneDisable();
  }

  @override
  Future<bool> changeCamera(bool open) async {
    RCRTCCameraOutputStream? stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    if (open) {
      PermissionStatus status = await Permission.camera.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        // if (Platform.isAndroid && status.isPermanentlyDenied) {
        //   openAppSettings();
        // }
        // if (Platform.isIOS && status.isRestricted) {
        //   openAppSettings();
        // }
        return false;
      }
      await stream?.startCamera();
      return true;
    } else {
      await stream?.stopCamera();
      return false;
    }
  }

  @override
  Future<bool> changeAudio(bool publish) async {
    RCRTCMicOutputStream? stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    RCRTCLocalUser? user = RCRTCEngine.getInstance().getRoom()?.localUser;
    int code = publish ? ((await user?.publishStream(stream)) ?? -1) : ((await user?.unPublishStream(stream)) ?? -1);
    if (code != RCRTCErrorCode.OK) 'Audio stream ${publish ? 'publish' : 'unPublish'} error, code = $code'.toast();
    return code == RCRTCErrorCode.OK ? publish : !publish;
  }

  @override
  Future<bool> changeVideo(bool publish) async {
    RCRTCCameraOutputStream? stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    RCRTCLocalUser? user = RCRTCEngine.getInstance().getRoom()?.localUser;
    int code = publish ? ((await user?.publishStream(stream)) ?? -1) : ((await user?.unPublishStream(stream)) ?? -1);
    if (code != RCRTCErrorCode.OK) 'Video stream ${publish ? 'publish' : 'unPublish'} error, code = $code'.toast();
    return code == RCRTCErrorCode.OK ? publish : !publish;
  }

  @override
  Future<bool> changeFrontCamera(bool front) async {
    RCRTCCameraOutputStream? stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return (await stream?.switchCamera()) ?? front;
  }

  @override
  Future<bool> changeSpeaker(bool open) async {
    await RCRTCEngine.getInstance().enableSpeaker(open);
    return open;
  }

  @override
  Future<void> changeVideoConfig(RCRTCVideoStreamConfig config) async {
    RCRTCCameraOutputStream? stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    await stream?.setVideoConfig(config);
  }

  @override
  Future<bool> changeTinyVideoConfig(RCRTCVideoStreamConfig config) async {
    RCRTCCameraOutputStream? stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return (await stream?.setTinyVideoConfig(config)) ?? false;
  }

  @override
  void switchToNormalStream(String id) {
    RCRTCRemoteUser? user = RCRTCEngine.getInstance().getRoom()?.remoteUserList.firstWhereOrNull((user) => user.id == id);
    user?.switchToNormalStream();
  }

  @override
  void switchToTinyStream(String id) {
    RCRTCRemoteUser? user = RCRTCEngine.getInstance().getRoom()?.remoteUserList.firstWhereOrNull((user) => user.id == id);
    user?.switchToTinyStream();
  }

  @override
  Future<RCRTCAudioInputStream?> changeRemoteAudioStatus(String id, bool subscribe) async {
    RCRTCRoom? room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser? user = room?.localUser;
    var audios = room?.remoteUserList
        .firstWhereOrNull(
          (element) => element.id == id,
        )
        ?.streamList
        .whereType<RCRTCAudioInputStream>();
    if (audios?.isEmpty ?? true) return null;
    var stream = audios!.first;
    int code = subscribe ? ((await user?.subscribeStream(stream)) ?? -1) : ((await user?.unsubscribeStream(stream)) ?? -1);
    if (code != RCRTCErrorCode.OK)
      return subscribe ? null : stream;
    else
      return subscribe ? stream : null;
  }

  @override
  Future<RCRTCVideoInputStream?> changeRemoteVideoStatus(String id, bool subscribe) async {
    RCRTCRoom? room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser? user = room?.localUser;
    var videos = room?.remoteUserList
        .firstWhereOrNull(
          (element) => element.id == id,
        )
        ?.streamList
        .whereType<RCRTCVideoInputStream>();
    if (videos?.isEmpty ?? true) return null;
    var stream = videos!.first;
    int code = subscribe ? ((await user?.subscribeStream(stream)) ?? -1) : ((await user?.unsubscribeStream(stream)) ?? -1);
    if (code != RCRTCErrorCode.OK)
      return subscribe ? null : stream;
    else
      return subscribe ? stream : null;
  }

  @override
  Future<int> exit() async {
    RCRTCEngine.getInstance().unRegisterStatusReportListener();
    int code = await RCRTCEngine.getInstance().leaveRoom();
    RCRTCEngine.getInstance().unInit();
    return code;
  }
}
