import 'dart:convert';

import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../global_config.dart';
import 'live_home_page_contract.dart';

class LiveHomePageModel extends AbstractModel implements Model {
  @override
  void loadLiveRoomList(
    bool reset,
    void onLoaded(RoomList list),
    void onLoadError(String info),
  ) async {
    if (reset) page = 0;
    Http.get(
      GlobalConfig.host + '/live_room',
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
        onLoadError("loadLiveRoomList error, error = $error");
      },
      tag,
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
        if (code == RCRTCErrorCode.OK || code == RCRTCErrorCode.ALREADY_CONNECTED) {
          RongIMClient.joinChatRoom(roomId, -1);

          onJoined(context);
        } else {
          onJoinError(context, 'requestJoinLiveRoom connect error, code = $code');
        }
      },
    );
  }

  int page = 0;
}
