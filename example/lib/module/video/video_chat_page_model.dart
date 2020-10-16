import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/widgets/video_view.dart';
import 'package:permission_handler/permission_handler.dart' as PermissionHandler;
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rcrtc_mix_config.dart';
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
      _remoteUsers[user.id] = RemoteUserStatus(user, true, true);
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
      RemoteUserStatus remoteUserStatus = RemoteUserStatus(user, false, false);

      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        RCRTCVideoView view = RCRTCVideoView(
          onCreated: (view, id) {
            stream.setVideoView(view, id);
          },
          viewType: RCRTCViewType.remote,
        );
        onVideoViewCreated(VideoView(User.unknown(user.id), view));
        remoteUserStatus?.videoStatus = true;
      });

      streams.whereType<RCRTCAudioInputStream>().forEach((stream) {
        remoteUserStatus?.audioStatus = true;
      });

      _remoteUsers[user.id] = remoteUserStatus;
    };

    room.onRemoteUserUnpublishResource = (user, streams) {
      RemoteUserStatus remoteUserStatus = _remoteUsers[user.id];
      localUser.unsubscribeStreams(streams);

      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onRemoveVideoView(user.id);
        remoteUserStatus?.videoStatus = false;
      });

      streams.whereType<RCRTCAudioInputStream>().forEach((stream) {
        remoteUserStatus?.audioStatus = false;
      });
    };

    room.onRemoteUserLeft = (user) {
      _remoteUsers.remove(user.id);
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

  @override
  List<RemoteUserStatus> getUserList() {
    var userList = List<RemoteUserStatus>();
    for (var key in _remoteUsers.keys) {
      userList.add(_remoteUsers[key]);
    }
    return userList;
  }

  @override
  Future<bool> changeRemoteAudioStreamState(RemoteUserStatus user) {
    if (user.audioStatus) {
      RCRTCEngine.getInstance().getRoom().localUser.unsubscribeStreams(user.user.streamList.whereType<RCRTCAudioInputStream>().toList());
      user.audioStatus = false;
    } else {
      RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(user.user.streamList.whereType<RCRTCAudioInputStream>().toList());
      user.audioStatus = true;
    }
    return Future.value(user.audioStatus);
  }

  @override
  Future<bool> changeRemoteVideoStreamState(RemoteUserStatus user) {
    if (user.videoStatus) {
      RCRTCEngine.getInstance().getRoom().localUser.unsubscribeStreams(user.user.streamList.whereType<RCRTCVideoInputStream>().toList());
      user.videoStatus = false;
    } else {
      RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(user.user.streamList.whereType<RCRTCVideoInputStream>().toList());
      user.videoStatus = true;
    }
    return Future.value(user.videoStatus);
  }

  Map<String, RemoteUserStatus> _remoteUsers = Map<String, RemoteUserStatus>();

  @override
  void changeVideoResolution(String level, void onVideoViewCreated(VideoView view), void onRemoveVideoView(String userId)) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();

    if (level == "超清") {
      _config = RCRTCVideoStreamConfig(
        300,
        1000,
        RCRTCFps.fps_30,
        RCRTCVideoResolution.RESOLUTION_720_1280,
      );
    } else if (level == "高清") {
      _config = RCRTCVideoStreamConfig(
        150,
        500,
        RCRTCFps.fps_30,
        RCRTCVideoResolution.RESOLUTION_360_640,
      );
    } else if (level == "标清") {
      _config = RCRTCVideoStreamConfig(
        70,
        210,
        RCRTCFps.fps_30,
        RCRTCVideoResolution.RESOLUTION_180_320,
      );
    }

    if (!_videoStreamState) {
      stream.stopCamera();
      localUser.unPublishStreams([stream]);
      onRemoveVideoView(localUser.id);

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
  }
}
