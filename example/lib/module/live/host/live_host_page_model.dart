import 'dart:convert';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rcrtc_mix_config.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../global_config.dart';
import 'live_host_page_contract.dart';

class LiveHostPageModel extends AbstractModel implements Model {
  @override
  void requestPermission(
    void onGranted(),
    void onDenied(bool camera, bool mic),
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
  void requestCameraPermission(void onGranted(), void onDenied()) async {
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
  void requestMicPermission(void onGranted(), void onDenied()) async {
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
  void initVideoView(
    void onVideoViewReady(TextureView videoView),
    void readyToPush(),
  ) {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      RCRTCVideoStreamConfig config = RCRTCVideoStreamConfig(
        300,
        1000,
        RCRTCFps.fps_30,
        RCRTCVideoResolution.RESOLUTION_720_1280,
      );
      stream.setVideoConfig(config);

      RCRTCTextureView videoView = RCRTCTextureView(
        (videoView, id) {
          stream.setTextureView(id);
          stream.startCamera().then((value) => readyToPush());
        },
        viewType: RCRTCViewType.local,
        mirror: true,
      );

      onVideoViewReady(TextureView(User.unknown(localUser.id), videoView));
    });
  }

  @override
  void push(
    void onSuccess(),
    void onError(String info),
  ) async {
    RCRTCEngine.getInstance().getRoom().localUser.publishDefaultLiveStreams(
      (liveInfo) {
        this.liveInfo = liveInfo;
        _requestCreateLiveRoom(liveInfo.userId, liveInfo.roomId, liveInfo.liveUrl);
        onSuccess();
      },
      (code, message) {
        onError("publishDefaultStreams error, code = $code, message = $message");
      },
    );
  }

  void _requestCreateLiveRoom(String userId, String roomId, String url) {
    print("_requestCreateLiveRoom uid = $userId, rid = $roomId, url = $url");
    Http.post(
      GlobalConfig.host + '/live_room/$roomId',
      {'user_id': userId, 'mcu_url': url},
      (error, data) {
        print("_requestCreateLiveRoom success, error = $error, data = $data");
      },
      (error) {
        print("_requestCreateLiveRoom error, error = $error");
      },
      tag,
    );
  }

  @override
  Future<void> setMixConfig(MixLayoutMode mode) async {
    RCRTCMixConfig config = new RCRTCMixConfig();
    MediaConfig mediaConfig = new MediaConfig();

    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();

    List<CustomLayout> list = new List();

    CustomLayout customLayout = new CustomLayout();
    customLayout.x = 0;
    customLayout.y = 0;
    customLayout.width = 400;
    customLayout.height = 400;
    customLayout.userId = room.localUser.id;

    List<RCRTCOutputStream> streams = await room.localUser.getStreams();
    streams.whereType<RCRTCVideoOutputStream>().forEach((stream) {
      customLayout.streamId = stream.streamId;
    });
    list.add(customLayout);

    for (RCRTCRemoteUser user in room.remoteUserList) {
      user.streamList.whereType<RCRTCVideoInputStream>().forEach((stream) {
        CustomLayout customLayout = new CustomLayout();
        customLayout.x = 160;
        customLayout.y = 100;
        customLayout.width = 200;
        customLayout.height = 200;
        customLayout.userId = user.id;
        customLayout.streamId = stream.streamId;
        list.add(customLayout);
      });
    }

    CustomLayoutList layoutList = new CustomLayoutList(list);

    var t = jsonEncode(layoutList);
    print('custom layout $t');

    VideoLayout videoLayout = new VideoLayout();
    videoLayout.bitrate = 256;
    videoLayout.width = 480;
    videoLayout.height = 960;
    videoLayout.fps = 15;
    VideoConfig videoConfig = new VideoConfig();
    videoConfig.videoLayout = videoLayout;

    AudioConfig audioConfig = new AudioConfig();
    audioConfig.bitrate = 128;

    mediaConfig.audioConfig = audioConfig;
    mediaConfig.videoConfig = videoConfig;

    config.mode = mode;
    if (config.mode == MixLayoutMode.CUSTOM) {
      config.customLayoutList = layoutList;
    }

    config.mediaConfig = mediaConfig;
    t = jsonEncode(mediaConfig);

    config.hostUserId = RCRTCEngine.getInstance().getRoom().localUser.id;
    streams.whereType<RCRTCVideoOutputStream>().forEach((stream) {
      config.hostStreamId = stream.streamId;
    });
    t = jsonEncode(config);
    print('mix config $t');
    liveInfo.setMixConfig(config);
  }

  @override
  void requestMemberList() async {
    String roomId = RCRTCEngine.getInstance().getRoom().id;
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.request_list, "").toJSON());
    RongIMClient.sendMessage(RCConversationType.ChatRoom, roomId, textMessage);
  }

  @override
  void inviteMember(Data.User user, LiveType type) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {
      'type': type.index,
    };
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.invite, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, user.id, textMessage);
  }

  @override
  void exit(
    BuildContext context,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  ) async {
    String roomId = RCRTCEngine.getInstance().getRoom().id;
    _requestLeaveLiveRoom(roomId);
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    int unPublishResult = await RCRTCEngine.getInstance().getRoom().localUser.unPublishStreams(await localUser.getStreams());
    int leaveResult = await RCRTCEngine.getInstance().leaveRoom();
    RongIMClient.quitChatRoom(roomId);
    RongIMClient.disconnect(false);
    if (unPublishResult == 0 && leaveResult == 0) {
      onSuccess(context);
    } else {
      onError(context, "exit error, unPublish code = $unPublishResult, leave code = $leaveResult");
    }
  }

  void _requestLeaveLiveRoom(String roomId) {
    print("_requestLeaveLiveRoom rid = $roomId");
    Http.delete(
      GlobalConfig.host + '/live_room/$roomId',
      null,
      (error, data) {
        print("_requestLeaveLiveRoom success, error = $error, data = $data");
      },
      (error) {
        print("_requestLeaveLiveRoom error, error = $error");
      },
      tag,
    );
  }

  @override
  void muteMicrophone(void onMicrophoneStatusChanged(bool state)) {
    RCRTCEngine.getInstance().getDefaultAudioStream().then((stream) async {
      stream.mute(!stream.isMute()).then((value) => onMicrophoneStatusChanged(stream.isMute()));
    });
  }

  @override
  void switchCamera(void onCameraStatusChanged(bool isFront)) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      stream.switchCamera().then((value) => onCameraStatusChanged(stream.isFrontCamera()));
    });
  }

  @override
  void setMirror(void onCameraMirrorChanged(bool state)) {
    // TODO 替换方法
  }

  @override
  Future<bool> changeVideoStreamState(void Function(TextureView view) onVideoViewCreated, void Function(String userId) onRemoveVideoView) async {
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
    var stream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    _videoStreamState = !_videoStreamState;
    if (_videoStreamState) {
      stream.stopCamera();
      localUser.unPublishStreams([stream]);
      onRemoveVideoView(localUser.id);
    } else {
      stream.setVideoConfig(_config);

      RCRTCTextureView view = RCRTCTextureView(
        (view, id) {
          stream.setTextureView(id);
          stream.startCamera().then((value) {
            localUser.publishStreams([stream]);
          });
        },
        viewType: RCRTCViewType.local,
        mirror: true,
      );
      onVideoViewCreated(TextureView(User.unknown(localUser.id), view));
    }
    return Future.value(_videoStreamState);
  }

  RCRTCLiveInfo liveInfo;
  bool _videoStreamState = false;
  RCRTCVideoStreamConfig _config = RCRTCVideoStreamConfig(
    300,
    1000,
    RCRTCFps.fps_30,
    RCRTCVideoResolution.RESOLUTION_720_1280,
  );
}
