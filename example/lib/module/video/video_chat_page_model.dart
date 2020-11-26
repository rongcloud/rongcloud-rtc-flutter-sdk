import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class VideoChatPageModel extends AbstractModel implements Model {
  @override
  void subscribe(
    void Function(VideoStreamWidget view) onViewCreated,
    void Function(String userId) onRemoveView,
    void Function() invalidate,
  ) {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      localUser.subscribeStreams(user.streamList);
      _remoteUsers[user.id] = RemoteUserStatus(user, true, true);
      user.streamList.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onViewCreated(VideoStreamWidget(User.unknown(user.id), stream));
      });
    }

    room.onRemoteUserJoined = (user) {
      RemoteUserStatus remoteUserStatus = RemoteUserStatus(user, false, false);
      _remoteUsers[user.id] = remoteUserStatus;
      invalidate();
    };

    room.onRemoteUserPublishResource = (user, streams) {
      RemoteUserStatus remoteUserStatus = _remoteUsers[user.id];

      List<RCRTCInputStream> subscribes = List();

      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onViewCreated(VideoStreamWidget(User.unknown(user.id), stream));

        subscribes.add(stream);
        remoteUserStatus?.videoStatus = true;
      });

      if (_subscribeAudioStreams) {
        subscribes.addAll(streams.whereType<RCRTCAudioInputStream>().toList());
        remoteUserStatus?.audioStatus = true;
      }

      localUser.subscribeStreams(subscribes);
    };

    room.onRemoteUserUnPublishResource = (user, streams) {
      RemoteUserStatus remoteUserStatus = _remoteUsers[user.id];
      localUser.unsubscribeStreams(streams);

      streams.whereType<RCRTCVideoInputStream>().forEach((stream) {
        onRemoveView(user.id);
        remoteUserStatus?.videoStatus = false;
      });

      streams.whereType<RCRTCAudioInputStream>().forEach((stream) {
        remoteUserStatus?.audioStatus = false;
      });
    };

    room.onRemoteUserLeft = (user) {
      _remoteUsers.remove(user.id);
      onRemoveView(user.id);
      invalidate();
    };

    invalidate();
  }

  @override
  Future<StatusCode> publish(
    Config config,
    void Function(VideoStreamWidget view) onViewCreated,
  ) async {
    List<RCRTCOutputStream> streams = List();

    if (config.camera) {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      stream.setVideoConfig(DefaultData.videoConfig);
      stream.startCamera();
      onViewCreated(VideoStreamWidget(User.unknown(RCRTCEngine.getInstance().getRoom().localUser.id), stream));
      streams.add(stream);
    }

    if (config.mic) {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      streams.add(stream);
    }

    int code = await RCRTCEngine.getInstance().getRoom().localUser.publishStreams(streams);
    if (code != 0)
      return StatusCode(Status.error, message: "code = $code", object: code);
    else
      return StatusCode(Status.ok);
  }

  @override
  Future<bool> switchCamera() async {
    RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    return stream.switchCamera();
  }

  @override
  Future<bool> changeAudioStreamState(Config config) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    bool enable = config.mic;
    enable = !enable;
    enable ? localUser.unPublishStreams([stream]) : localUser.publishStreams([stream]);
    return Future.value(enable);
  }

  @override
  Future<bool> changeVideoStreamState(
    Config config,
    void Function(VideoStreamWidget view) onVideoViewCreated,
    void Function(String userId) onRemoveVideoView,
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    bool enable = config.camera;
    enable = !enable;
    if (enable) {
      localUser.unPublishStreams([stream]);
      stream.stopCamera();
      onRemoveVideoView(localUser.id);
    } else {
      stream.setVideoConfig(DefaultData.videoConfig);
      stream.startCamera();
      localUser.publishStreams([stream]);
      onVideoViewCreated(VideoStreamWidget(User.unknown(localUser.id), stream));
    }
    return Future.value(enable);
  }

  @override
  void changeRemoteAudioSubscribeState(bool unsubscribe) {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    List<RCRTCRemoteUser> remoteUsers = RCRTCEngine.getInstance().getRoom().remoteUserList;
    remoteUsers.forEach((user) {
      List<RCRTCInputStream> streams = user.streamList.whereType<RCRTCAudioInputStream>().toList();
      if (unsubscribe)
        localUser.unsubscribeStreams(streams);
      else
        localUser.subscribeStreams(streams);
    });
  }

  @override
  Future<StatusCode> exit() async {
    int code = await RCRTCEngine.getInstance().leaveRoom();

    RCRTCEngine.getInstance().unInit();
    RongIMClient.disconnect(false);
    if (code != 0) {
      return StatusCode(Status.error, message: "code = $code", object: code);
    } else {
      return StatusCode(Status.ok);
    }
  }

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

  @override
  void setCameraCaptureOrientation(RCRTCCameraCaptureOrientation orientation) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async => {
          await stream.stopCamera(),
          await stream.setCameraCaptureOrientation(orientation),
          await stream.startCamera(),
        });
  }

  bool _subscribeAudioStreams = true;

  Map<String, RemoteUserStatus> _remoteUsers = Map<String, RemoteUserStatus>();
}
