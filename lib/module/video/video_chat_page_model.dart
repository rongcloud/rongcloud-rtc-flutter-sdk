import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/widgets/video_view.dart';
import 'package:permission_handler/permission_handler.dart' as PermissionHandler;
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class VideoChatPageModel extends AbstractModel implements Model {
  @override
  Future<PermissionStatus> requestPermission() async {
    bool camera = await PermissionHandler.Permission.camera.request().isGranted;
    bool mic = await PermissionHandler.Permission.microphone.request().isGranted;
    int code = 0;
    if (!camera) code += 1;
    if (!mic) code += 2;
    return Future.value(PermissionStatus.values[code]);
  }

  @override
  Future<PermissionStatus> requestCameraPermission() async {
    if (await PermissionHandler.Permission.camera.request().isPermanentlyDenied) {
      PermissionHandler.openAppSettings();
      return Future.value(PermissionStatus.camera_denied);
    }
    bool camera = await PermissionHandler.Permission.camera.request().isGranted;
    bool mic = await PermissionHandler.Permission.microphone.isGranted;
    int code = 0;
    if (!camera) code += 1;
    if (!mic) code += 2;
    return Future.value(PermissionStatus.values[code]);
  }

  @override
  Future<PermissionStatus> requestMicPermission() async {
    if (await PermissionHandler.Permission.microphone.request().isPermanentlyDenied) {
      PermissionHandler.openAppSettings();
      return Future.value(PermissionStatus.mic_denied);
    }
    bool camera = await PermissionHandler.Permission.camera.isGranted;
    bool mic = await PermissionHandler.Permission.microphone.request().isGranted;
    int code = 0;
    if (!camera) code += 1;
    if (!mic) code += 2;
    return Future.value(PermissionStatus.values[code]);
  }

  @override
  void createVideoView(void Function(VideoView view) onVideoViewCreated, void Function() readyToPush) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      stream.setVideoConfig(_config);

      RCRTCVideoView videoView = RCRTCVideoView(
        onCreated: (videoView, id) {
          stream.setVideoView(videoView, id);
          stream.startCamera().then((value) => readyToPush());
        },
        viewType: RCRTCViewType.local,
      );

      onVideoViewCreated(VideoView(User.unknown(RCRTCEngine.getInstance().getRoom().localUser.id), videoView));
    });
  }

  @override
  Future<StatusCode> push() async {
    int code = await RCRTCEngine.getInstance().getRoom().localUser.publishDefaultStreams();
    if (code != 0) {
      return StatusCode(Status.error, message: "code = $code", object: code);
    } else {
      return StatusCode(Status.ok);
    }
  }

  @override
  void pull(void Function(VideoView view) onVideoViewCreated, void Function(String userId) onRemoveVideoView) {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      localUser.subscribeStreams(user.streamList);
      user.streamList.whereType<RCRTCVideoInputStream>().forEach((stream) {
        RCRTCVideoView view = RCRTCVideoView(
          onCreated: (view, id) {
            stream.setVideoView(view, id);
          },
          viewType: RCRTCViewType.remote,
        );
        onVideoViewCreated(VideoView(User.unknown(user.id), view));
      });
    }

    room.onRemoteUserPublishResource = (user, streams) {
      localUser.subscribeStreams(streams);
      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        RCRTCVideoView view = RCRTCVideoView(
          onCreated: (view, id) {
            stream.setVideoView(view, id);
          },
          viewType: RCRTCViewType.remote,
        );
        onVideoViewCreated(VideoView(User.unknown(user.id), view));
      });
    };

    room.onRemoteUserUnpublishResource = (user, streams) {
      localUser.unsubscribeStreams(streams);
      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onRemoveVideoView(user.id);
      });
    };

    room.onRemoteUserLeft = (user) {
      onRemoveVideoView(user.id);
    };
  }

  @override
  void switchCamera() {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      stream.switchCamera();
    });
  }

  @override
  Future<bool> changeAudioStreamState() async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    _audioStreamState = !_audioStreamState;
    _audioStreamState ? localUser.unPublishStreams([stream]) : localUser.publishStreams([stream]);
    return Future.value(_audioStreamState);
  }

  @override
  Future<bool> changeVideoStreamState(void Function(VideoView view) onVideoViewCreated, void Function(String userId) onRemoveVideoView) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    _videoStreamState = !_videoStreamState;
    if (_videoStreamState) {
      stream.stopCamera();
      localUser.unPublishStreams([stream]);
      onRemoveVideoView(localUser.id);
    } else {
      stream.setVideoConfig(_config);

      RCRTCVideoView view = RCRTCVideoView(
        onCreated: (view, id) {
          stream.setVideoView(view, id);
          stream.startCamera().then((value) {
            localUser.publishStreams([stream]);
          });
        },
        viewType: RCRTCViewType.local,
      );
      onVideoViewCreated(VideoView(User.unknown(localUser.id), view));
    }
    return Future.value(_videoStreamState);
  }

  @override
  Future<StatusCode> exit() async {
    int code = await RCRTCEngine.getInstance().leaveRoom();
    RongIMClient.disconnect(false);
    if (code != 0) {
      return StatusCode(Status.error, message: "code = $code", object: code);
    } else {
      return StatusCode(Status.ok);
    }
  }

  RCRTCVideoStreamConfig _config = RCRTCVideoStreamConfig(
    300,
    1000,
    RCRTCFps.fps_30,
    RCRTCVideoResolution.RESOLUTION_720_1280,
  );

  bool _audioStreamState = false;
  bool _videoStreamState = false;
}
