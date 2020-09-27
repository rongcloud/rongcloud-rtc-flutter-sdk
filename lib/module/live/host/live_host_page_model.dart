import 'dart:convert';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/agent/view/rcrtc_video_view.dart';
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
    void onVideoViewReady(RCRTCVideoView videoView),
    void readyToPush(),
  ) {
    RCRTCEngine.getInstance().defaultVideoStream.then((stream) async {
      RCRTCVideoStreamConfig config = RCRTCVideoStreamConfig(
        300,
        1000,
        RCRTCFps.fps_30,
        RCRTCVideoResolution.RESOLUTION_720_1280,
      );
      stream.setVideoConfig(config);

      RCRTCVideoView videoView = RCRTCVideoView(
        onCreated: (videoView, id) {
          stream.setVideoView(videoView, id);
          stream.startCamera().then((value) => readyToPush());
        },
        viewType: RCRTCViewType.local,
      );

      onVideoViewReady(videoView);
    });
  }

  @override
  void push(
    void onSuccess(),
    void onError(String info),
  ) async {
    RCRTCEngine.getInstance().room.localUser.publishDefaultLiveStreams(
      (liveInfo) {
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
  void requestMemberList() async {
    String roomId = RCRTCEngine.getInstance().room.id;
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
    String roomId = RCRTCEngine.getInstance().room.id;
    _requestLeaveLiveRoom(roomId);
    RCRTCLocalUser localUser = RCRTCEngine.getInstance().room.localUser;
    int unPublishResult = await RCRTCEngine.getInstance().room.localUser.unPublishStreams(await localUser.getStreams());
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
    RCRTCEngine.getInstance().defaultAudioStream.then((stream) async {
      stream.mute(!stream.isMute()).then((value) => onMicrophoneStatusChanged(stream.isMute()));
    });
  }

  @override
  void switchCamera(void onCameraStatusChanged(bool isFront)) {
    RCRTCEngine.getInstance().defaultVideoStream.then((stream) async {
      stream.switchCamera().then((value) => onCameraStatusChanged(stream.isFrontCamera()));
    });
  }

  @override
  void setMirror(void onCameraMirrorChanged(bool state)) {
    // TODO 替换方法
  }
}
