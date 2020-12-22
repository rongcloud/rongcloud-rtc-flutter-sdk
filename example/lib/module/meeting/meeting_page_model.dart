import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'meeting_page_contract.dart';

class MeetingPageModel extends AbstractModel implements Model {
  @override
  Future<void> subscribe(
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
    void onUserLeaved(String uid),
  ) async {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      UserView view = UserView(User.unknown(user.id));
      List<RCRTCInputStream> subscribes = List();

      if (_subscribeAudioStreams) {
        var streams = user.streamList.whereType<RCRTCAudioInputStream>();
        if (streams.isNotEmpty) {
          var stream = streams.first;
          subscribes.add(stream);
          view.audioStream = stream;
        }
      }

      if (_subscribeVideoStreams) {
        var streams = user.streamList.whereType<RCRTCVideoInputStream>();
        if (streams.isNotEmpty) {
          var stream = streams.first;
          subscribes.add(stream);
          view.videoStream = stream;
        }
      }

      localUser.subscribeStreams(subscribes);
      onUserJoined(view);
    }

    room.onRemoteUserJoined = (user) {
      UserView view = UserView(User.unknown(user.id));
      onUserJoined(view);
    };

    room.onRemoteUserPublishResource = (user, streams) {
      List<RCRTCInputStream> subscribes = List();

      if (_subscribeAudioStreams) {
        var audios = streams.whereType<RCRTCAudioInputStream>();
        if (audios.isNotEmpty) {
          var stream = audios.first;
          subscribes.add(stream);
          onUserAudioStreamChanged(user.id, stream);
        }
      }

      if (_subscribeVideoStreams) {
        var videos = streams.whereType<RCRTCVideoInputStream>();
        if (videos.isNotEmpty) {
          var stream = videos.first;
          subscribes.add(stream);
          onUserVideoStreamChanged(user.id, stream);
        }
      }

      localUser.subscribeStreams(subscribes);
    };

    room.onRemoteUserUnPublishResource = (user, streams) {
      if (streams.whereType<RCRTCAudioInputStream>().isNotEmpty) {
        onUserAudioStreamChanged(user.id, null);
      }

      if (streams.whereType<RCRTCVideoInputStream>().isNotEmpty) {
        onUserVideoStreamChanged(user.id, null);
      }
    };

    room.onRemoteUserLeft = (user) {
      onUserLeaved(user.id);
    };
  }

  @override
  Future<StatusCode> publish(
    Config config,
    void onUserJoined(UserView view),
    void onUserAudioStreamChanged(String uid, dynamic stream),
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) async {
    List<RCRTCOutputStream> streams = List();
    String uid = RCRTCEngine.getInstance().getRoom().localUser.id;

    onUserJoined(UserView(User.unknown(uid)));

    if (config.mic) {
      RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
      streams.add(stream);
      onUserAudioStreamChanged(uid, stream);
    }

    if (config.camera) {
      RCRTCCameraOutputStream stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
      stream.setVideoConfig(config.videoConfig);
      stream.startCamera();
      streams.add(stream);
      onUserVideoStreamChanged(uid, stream);
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
  void changeAudioStreamState(
    Config config,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    RCRTCMicOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    bool enable = config.mic;
    enable = !enable;
    enable ? localUser.publishStreams([stream]) : localUser.unPublishStreams([stream]);
    onUserAudioStreamChanged(localUser.id, enable ? stream : null);
  }

  @override
  void changeVideoStreamState(
    Config config,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    bool enable = config.camera;
    enable = !enable;
    if (enable) {
      stream.setVideoConfig(config.videoConfig);
      stream.startCamera();
      localUser.publishStream(stream);
      onUserVideoStreamChanged(localUser.id, stream);
    } else {
      localUser.unPublishStream(stream);
      stream.stopCamera();
      onUserVideoStreamChanged(localUser.id, null);
    }
  }

  @override
  void changeRemoteAudioStreamState(
    UserView view,
    void onUserAudioStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    if (view.audio) {
      await localUser.unsubscribeStream(view.audioStream);
      onUserAudioStreamChanged(view.user.id, null);
    } else {
      await localUser.subscribeStream(view.audioStream);
      onUserAudioStreamChanged(view.user.id, view.audioStream);
    }
  }

  @override
  void changeRemoteVideoStreamState(
    UserView view,
    void onUserVideoStreamChanged(String uid, dynamic stream),
  ) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    if (view.video) {
      await localUser.unsubscribeStream(view.videoStream);
      onUserVideoStreamChanged(view.user.id, null);
    } else {
      await localUser.subscribeStream(view.videoStream);
      onUserVideoStreamChanged(view.user.id, view.videoStream);
    }
  }

  void unsubscribeRemoteAudioStreams(List<UserView> views) {
    if (!_subscribeAudioStreams) return;
    _subscribeAudioStreams = false;

    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    List<RCRTCAudioInputStream> streams = List();
    views.forEach((view) {
      if (!view.self) {
        streams.add(view.audioStream);
        view.audioStream = null;
      }
    });
    localUser.unsubscribeStreams(streams);
  }

  void subscribeRemoteAudioStreams(List<UserView> views) {
    if (_subscribeAudioStreams) return;
    _subscribeAudioStreams = true;

    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    List<RCRTCAudioInputStream> streams = List();
    views.forEach((view) {
      if (!view.self) {
        streams.add(view.audioStream);
        view.audioStream = view.audioStream;
      }
    });
    localUser.subscribeStreams(streams);
  }

  void unsubscribeRemoteVideoStreams(List<UserView> views) {
    if (!_subscribeVideoStreams) return;
    _subscribeVideoStreams = false;

    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    List<RCRTCVideoInputStream> streams = List();
    views.forEach((view) {
      if (!view.self) {
        streams.add(view.videoStream);
        view.videoStream = null;
      }
    });
    localUser.unsubscribeStreams(streams);
  }

  void subscribeRemoteVideoStreams(List<UserView> views) {
    if (_subscribeVideoStreams) return;
    _subscribeVideoStreams = true;

    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    List<RCRTCVideoInputStream> streams = List();
    views.forEach((view) {
      if (!view.self) {
        streams.add(view.videoStream);
        view.videoStream = view.videoStream;
      }
    });
    localUser.subscribeStreams(streams);
  }

  @override
  void changeAudioStreamConfig(Config config) {}

  @override
  void changeVideoStreamConfig(Config config) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) {
      stream.stopCamera();
      stream.setVideoConfig(config.videoConfig);
      stream.startCamera();
    });
  }

  @override
  Future<StatusCode> exit() async {
    int code = await RCRTCEngine.getInstance().leaveRoom();
    if (code != 0) {
      return StatusCode(Status.error, message: "code = $code", object: code);
    } else {
      return StatusCode(Status.ok);
    }
  }

  bool _subscribeAudioStreams = true;
  bool _subscribeVideoStreams = true;
}
