import 'dart:async';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'connect_page_contract.dart';

class ConnectPageModel extends AbstractModel implements Model {
  @override
  void clear() {
    DefaultData.clear();
  }

  @override
  void load() {
    DefaultData.loadUsers();
  }

  @override
  Future<Result> token(String key) {
    if (key.isEmpty) key = GlobalConfig.appKey;
    int current = DateTime.now().millisecondsSinceEpoch;
    String id = '${GlobalConfig.prefix}$current';
    Completer<Result> completer = Completer();
    Http.post(
      GlobalConfig.host + '/token/$id',
      {'key': key},
      (error, data) {
        String token = data['token'];
        completer.complete(Result(0, token));
      },
      (error) {
        completer.complete(Result(-1, 'Get token error.'));
      },
      tag,
    );
    return completer.future;
  }

  @override
  void connect(
    String key,
    String navigate,
    String file,
    String media,
    String token,
    StateCallback callback,
  ) {
    if (key.isEmpty) key = GlobalConfig.appKey;
    if (navigate.isEmpty) navigate = GlobalConfig.navServer;
    if (file.isEmpty) file = GlobalConfig.fileServer;
    if (media.isEmpty) media = GlobalConfig.mediaServer;

    RongIMClient.setServerInfo(navigate, file);
    RongIMClient.init(key);

    if (media.isNotEmpty) {
      RCRTCEngine.getInstance().setMediaServerUrl(media);
    }

    RongIMClient.connect(token, (code, id) {
      if (code == RCRTCErrorCode.OK) {
        User user = User.create(
          id,
          key,
          navigate,
          file,
          media,
          token ?? '',
        );
        DefaultData.user = user;
      }
      callback(code, id);
    });
  }

  @override
  Future<void> login(
    String name,
    StateCallback callback,
  ) async {
    String key = GlobalConfig.appKey;

    User user = DefaultData.users.firstWhere((user) => user.name == name, orElse: () => null);
    String _token;
    if (user != null) {
      _token = user.token;
    } else {
      Result result = await token(key);
      if (result.code != 0) return;
      _token = result.content;
    }

    RongIMClient.init(key);

    RongIMClient.connect(_token, (code, id) {
      if (code == RCRTCErrorCode.OK) {
        if (user == null) {
          user = User.create(
            id,
            GlobalConfig.appKey,
            GlobalConfig.navServer,
            GlobalConfig.fileServer,
            GlobalConfig.mediaServer,
            _token ?? '',
          );
          user.name = name;
        }
        DefaultData.user = user;
      }
      callback(code, id);
    });
  }

  @override
  void disconnect() {
    RongIMClient.disconnect(false);
  }

  @override
  Future<void> action(
    String info,
    Mode mode,
    RCRTCLiveType type,
    StateCallback callback,
  ) async {
    await RCRTCEngine.getInstance().init(null);

    RCRTCCodeResult result = await RCRTCEngine.getInstance().joinRoom(
      roomId: info,
      roomConfig: RCRTCRoomConfig(
        mode == Mode.Meeting ? RCRTCRoomType.Normal : RCRTCRoomType.Live,
        RCRTCLiveType.AudioVideo,
        mode != Mode.Audience ? RCRTCLiveRoleType.Broadcaster : RCRTCLiveRoleType.Audience,
      ),
    );

    callback(result.code, result.reason);
  }
}
