import 'dart:convert';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../global_config.dart';
import 'home_page_contract.dart';

class LoginData {
  String token;

  LoginData(this.token);

  LoginData.fromJson(Map<String, dynamic> json) : token = json['token'];
}

class Room {
  String id;
  String uid;
  String url;

  Room(this.id, this.uid, this.url);
}

class RoomList {
  List<Room> list;

  RoomList(this.list);
}

class HomePageModel extends AbstractModel implements Model {
  @override
  void requestCurrentServerVersion(
    void onLoaded(String version),
  ) {
    Http.get(
      GlobalConfig.host + '/ver',
      null,
      (error, data) {
        onLoaded(data);
      },
      (error) {
        onLoaded('0');
      },
      tag,
    );
  }

  @override
  void login(
    void onLoginSuccess(),
    void onLoginError(String info),
  ) {
    Http.post(
      GlobalConfig.host + '/token/${DefaultData.user.id}',
      null,
      (error, data) {
        LoginData loginData = LoginData.fromJson(data);
        DefaultData.user.token = loginData.token;
        onLoginSuccess();
      },
      (error) {
        onLoginError('登陆失败');
      },
      tag,
    );
  }

  @override
  void initRCRTCEngine() {
    RCRTCEngine.getInstance().init(null); // 初始化引擎
  }

  @override
  void loadLiveRoomList(
    bool reset,
    void onLoaded(RoomList list),
    void onLoadError(String info),
  ) async {
    if (reset) page = 0;
    Http.get(
      GlobalConfig.host + '/live_room',
      null,
      (error, data) {
        List<Room> list = List();
        Map<String, dynamic> rooms = jsonDecode(data);
        rooms.forEach((key, value) {
          Room room = Room(key, value['user_id'], value['mcu_url']);
          list.add(room);
        });
        onLoaded(RoomList(list));
      },
      (error) {
        onLoadError("loadLiveRoomList error, error = $error");
      },
      tag,
    );
  }

  @override
  void requestJoinRoom(
    BuildContext context,
    String roomId,
    ChatType type,
    void onCreated(BuildContext context),
    void onCreateError(BuildContext context, String info),
  ) async {
    RongIMClient.connect(
      DefaultData.user.token,
      (code, userId) async {
        if (code == RCRTCErrorCode.OK) {
          RongIMClient.joinChatRoom(roomId, -1);

          RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
            roomId: roomId,
            roomConfig: RCRTCRoomConfig(
              type != ChatType.LiveChat ? RCRTCRoomType.Normal : RCRTCRoomType.Live,
              type != ChatType.AudioChat ? RCRTCLiveType.AudioVideo : RCRTCLiveType.Audio,
            ),
          );
          if (result.code == 0) {
            onCreated(context);
          } else {
            onCreateError(context, 'requestCreateLiveRoom join room error, code = ${result.code}');
          }
        } else if (code == RCRTCErrorCode.ALREADY_CONNECTED) {
          RongIMClient.disconnect(false);
          requestJoinRoom(context, roomId, type, onCreated, onCreateError);
        } else {
          onCreateError(context, 'requestCreateLiveRoom connect error, code = $code');
        }
      },
    );
  }

  @override
  void requestJoinLiveRoom(
    BuildContext context,
    String roomId,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  ) {
    RongIMClient.connect(
      DefaultData.user.token,
      (code, userId) async {
        if (code == RCRTCErrorCode.OK) {
          RongIMClient.joinChatRoom(roomId, -1);

          onJoined(context);
        } else if (code == RCRTCErrorCode.ALREADY_CONNECTED) {
          RongIMClient.disconnect(false);
          requestJoinLiveRoom(context, roomId, onJoined, onJoinError);
        } else {
          onJoinError(context, 'requestJoinLiveRoom connect error, code = $code');
        }
      },
    );
  }

  int page = 0;
}
