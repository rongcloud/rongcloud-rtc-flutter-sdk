import 'dart:convert';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart' as Data;
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'live_audience_page_contract.dart';

class LiveAudiencePageModel extends AbstractModel implements Model {
  @override
  void pull(
    String url,
    void onSuccess(RCRTCTextureView videoView),
    void onError(int code, String message),
  ) {
    RCRTCEngine.getInstance().subscribeLiveStream(
      url,
      AVStreamType.audio_video,
      (stream) {
        RCRTCTextureView videoView = RCRTCTextureView(
          (videoView, id) {
            stream.setTextureView(id);
          },
          viewType: RCRTCViewType.remote,
        );
        onSuccess(videoView);
      },
      (code, message) {
        onError(code, message);
      },
    );
  }

  void initVideoView(
    void onVideoViewReady(RCRTCTextureView videoView),
    void readyToPush(),
  ) {
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) async {
      RCRTCVideoStreamConfig config = RCRTCVideoStreamConfig(
        200,
        800,
        RCRTCFps.fps_15,
        RCRTCVideoResolution.RESOLUTION_360_480,
      );
      stream.setVideoConfig(config);

      RCRTCTextureView videoView = RCRTCTextureView(
        (videoView, id) {
          stream.setTextureView(id);
          stream.startCamera().then((value) => readyToPush());
        },
        viewType: RCRTCViewType.local,
      );

      onVideoViewReady(videoView);
    });
  }

  void push(
    void onPushed(),
    void onPushError(),
  ) async {
    RCRTCEngine.getInstance().getRoom().localUser.publishDefaultLiveStreams(
      (liveInfo) {
        onPushed();
      },
      (code, message) {
        onPushError();
      },
    );
  }

  @override
  void sendMessage(
    String roomId,
    String message,
    void onMessageSent(Message message),
  ) async {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.normal, message).toJSON());
    onMessageSent(await RongIMClient.sendMessage(RCConversationType.ChatRoom, roomId, textMessage));
  }

  @override
  void sendRequestListMessage(String uid) {
    TextMessage textMessage = TextMessage();
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.request_list, "").toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, uid, textMessage);
  }

  @override
  void refuseInvite(Data.User user, LiveType type) {
    _sendInviteMessage(false, user.id, type);
  }

  @override
  void agreeInvite(
    Data.User user,
    String roomId,
    String url,
    LiveType type,
    void onVideoViewReady(RCRTCTextureView videoView),
    void onRemoteVideoViewReady(String uid, RCRTCTextureView videoView),
    void onRemoteVideoViewClose(String uid),
  ) {
    _sendInviteMessage(true, user.id, type);
    _joinRoom(url, roomId, user.id, type, onVideoViewReady, onRemoteVideoViewReady, onRemoteVideoViewClose);
  }

  void _sendInviteMessage(bool agree, String uid, LiveType type) {
    TextMessage textMessage = TextMessage();
    Map<String, dynamic> data = {
      'agree': agree,
      'type': type.index,
    };
    textMessage.content = jsonEncode(Data.Message(Data.DefaultData.user, MessageType.invite, jsonEncode(data)).toJSON());
    RongIMClient.sendMessage(RCConversationType.Private, uid, textMessage);
  }

  void _joinRoom(
    String url,
    String roomId,
    String uid,
    LiveType type,
    void onVideoViewReady(RCRTCTextureView videoView),
    void onRemoteVideoViewReady(String uid, RCRTCTextureView videoView),
    void onRemoteVideoViewClose(String uid),
  ) async {
    bool hasPermission = await _requestPermission();
    if (hasPermission) {
      int unsubscribe = await RCRTCEngine.getInstance().unsubscribeLiveStream(url);
      if (unsubscribe == 0) {
        bool joined = await _doJoinRoom(roomId);
        if (joined) {
          _type = type;

          _subscribe(uid, onRemoteVideoViewReady, onRemoteVideoViewClose);

          initVideoView(
            (videoView) {
              onVideoViewReady(videoView);
            },
            () {
              push(
                () {
                  // TODO pushed
                },
                () {
                  // TODO push error
                },
              );
            },
          );
        } else {
          _sendErrorMessage(uid, MessageError.join_error);
        }
      } else {
        _sendErrorMessage(uid, MessageError.unsubscribe_error);
      }
    } else {
      _sendErrorMessage(uid, MessageError.no_permission);
    }
  }

  Future<bool> _requestPermission() async {
    bool camera = await Permission.camera.request().isGranted;
    bool mic = await Permission.microphone.request().isGranted;
    if (camera && mic) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _doJoinRoom(String roomId) async {
    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: roomId,
      roomConfig: RCRTCRoomConfig(RCRTCRoomType.Live, RCRTCLiveType.AudioVideo),
    );
    if (result.code == 0) {
      return true;
    } else {
      print("join room $roomId error, code = ${result.code}, reason = ${result.reason}");
      return false;
    }
  }

  void _subscribe(
    String uid,
    void onRemoteVideoViewReady(String uid, RCRTCTextureView videoView),
    void onRemoteVideoViewClose(String uid),
  ) {
    RCRTCEngine.getInstance().getRoom().remoteUserList.forEach((user) {
      List<RCRTCInputStream> streams = user.streamList;
      RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(streams);
      streams.forEach((stream) {
        if (stream.type == MediaType.video) {
          RCRTCTextureView videoView = RCRTCTextureView(
            (view, id) {
              (stream as RCRTCVideoInputStream).setTextureView(id);
            },
            viewType: RCRTCViewType.remote,
          );
          onRemoteVideoViewReady(user.id, videoView);
        }
      });
    });

    RCRTCEngine.getInstance().getRoom().onRemoteUserPublishResource = (_user, _streams) {
      RCRTCEngine.getInstance().getRoom().localUser.subscribeStreams(_streams);
      _streams.forEach((stream) {
        if (stream.type == MediaType.video) {
          RCRTCTextureView videoView = RCRTCTextureView(
            (view, id) {
              (stream as RCRTCVideoInputStream).setTextureView(id);
            },
            viewType: RCRTCViewType.remote,
          );
          onRemoteVideoViewReady(_user.id, videoView);
        }
      });
    };

    RCRTCEngine.getInstance().getRoom().onRemoteUserUnPublishResource = (_user, _streams) {
      onRemoteVideoViewClose(_user.id);
    };

    RCRTCEngine.getInstance().getRoom().onRemoteUserLeft = (_user) {
      onRemoteVideoViewClose(_user.id);
    };
  }

  void _sendErrorMessage(String uid, MessageError error) {}

  @override
  void exit(
    BuildContext context,
    String roomId,
    String url,
    void onSuccess(BuildContext context),
    void onError(BuildContext context, String info),
  ) async {
    int result = 0;
    if (_type != LiveType.normal) {
      RCRTCLocalUser localUser = RCRTCEngine.getInstance().getRoom().localUser;
      result += await RCRTCEngine.getInstance().getRoom().localUser.unPublishStreams(await localUser.getStreams());
      result += await RCRTCEngine.getInstance().leaveRoom();
    } else {
      result = await RCRTCEngine.getInstance().unsubscribeLiveStream(url);
    }
    RongIMClient.quitChatRoom(roomId);
    RongIMClient.disconnect(false);
    if (result > 0) {
      onError(context, "exit has some error");
    } else {
      onSuccess(context);
    }
  }

  LiveType _type = LiveType.normal;
}
