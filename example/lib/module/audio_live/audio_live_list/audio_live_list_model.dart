import 'dart:convert';

import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../global_config.dart';
import 'audio_live_list_contract.dart';

class AudioLiveListModel extends AbstractModel implements Model {
  int page = 0;

  @override
  void requestJoinLiveRoom(
    BuildContext context,
    String roomId,
    void onJoined(BuildContext context),
    void onJoinError(BuildContext context, String info),
  ) {
    //这个只是加入im聊天室
    RongIMClient.connect(DefaultData.user.token, (code, userId) async {
      if (code == RCRTCErrorCode.OK || code == RCRTCErrorCode.ALREADY_CONNECTED) {
        RongIMClient.joinChatRoom(roomId, -1);
        onJoined(context);
      } else {
        onJoinError(context, '加入房间错误:code = $code');
      }
    });
  }

  @override
  void getLiveRoomList(
    bool reset,
    void onLoaded(RoomList list),
    void onLoadError(String info),
  ) async {
    if (reset) page = 0;
    Http.get(
      GlobalConfig.host + '/audio_room',
      {'key': GlobalConfig.appKey},
      (error, data) {
        List<Room> list = List();
        Map<String, dynamic> rooms = jsonDecode(data);
        rooms.forEach((key, value) {
          Room room = Room(key, User.create(value['user_id'], value['user_name']), value['mcu_url']);
          list.add(room);
        });
        onLoaded(RoomList(list));
      },
      (error) {
        onLoadError("getLiveRoomList error, error = $error");
      },
      tag,
    );
  }
}
