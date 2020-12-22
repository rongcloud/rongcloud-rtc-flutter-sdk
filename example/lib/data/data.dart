import 'dart:convert';

import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/frame/utils/local_storage.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../global_config.dart';
import 'constants.dart';

class Login {
  String token;

  Login(this.token);

  Login.fromJson(Map<String, dynamic> json) : token = json['token'];
}

class User {
  String id;
  String name;
  String avatar;
  String cover;
  String token;

  User.unknown(this.id) : name = 'Unknown' {
    avatar = _randomAvatar();
    cover = _randomCover();
  }

  User.create(
    this.id,
    this.name,
  ) {
    avatar = _randomAvatar();
    cover = _randomCover();
  }

  factory User() {
    String prefix = GlobalConfig.userIdPrefix;
    int current = DateTime.now().millisecondsSinceEpoch;
    User user = User.create('$prefix$current', '');
    return user;
  }

  String _randomAvatar() {
    return 'avatar/avatar_${this.id.toInt % 7}'.png;
  }

  String _randomCover() {
    return 'cover/cover_${this.id.toInt % 6}'.png;
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'cover': cover,
      };

  User.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        avatar = json['avatar'],
        cover = json['cover'];
}

class Config {
  bool mic;
  bool speaker;
  bool camera;
  bool frontCamera;
  bool enableTinyStream;
  RCRTCFps fps;
  Resolution resolution;
  bool mirror;

  Config.config()
      : mic = true,
        speaker = false,
        camera = true,
        frontCamera = true,
        enableTinyStream = true,
        fps = RCRTCFps.fps_30,
        resolution = Resolution.FHD,
        mirror = true;

  RCRTCVideoStreamConfig get videoConfig {
    _videoConfig.fps = fps;
    switch (resolution) {
      case Resolution.SD:
        _videoConfig.resolution = RCRTCVideoResolution.RESOLUTION_360_480;
        break;
      case Resolution.HD:
        _videoConfig.resolution = RCRTCVideoResolution.RESOLUTION_480_640;
        break;
      case Resolution.FHD:
        _videoConfig.resolution = RCRTCVideoResolution.RESOLUTION_720_1280;
        break;
    }
    return _videoConfig;
  }

  Map<String, dynamic> toJSON() => {
        'mic': mic,
        'speaker': speaker,
        'camera': camera,
        'frontCamera': frontCamera,
        'enableTinyStream': enableTinyStream,
        'fps': fps.index,
        'resolution': resolution.index,
        'mirror': mirror,
      };

  Config.fromJSON(Map<String, dynamic> json)
      : mic = json['mic'],
        speaker = json['speaker'],
        camera = json['camera'],
        frontCamera = json['frontCamera'],
        enableTinyStream = json['enableTinyStream'],
        fps = RCRTCFps.values[json['fps']],
        resolution = Resolution.values[json['resolution']],
        mirror = json['mirror'];

  final RCRTCVideoStreamConfig _videoConfig = RCRTCVideoStreamConfig(
    300,
    1000,
    RCRTCFps.fps_30,
    RCRTCVideoResolution.RESOLUTION_720_1280,
  );
}

class AudioMixConfig {}

class Message {
  User user;
  MessageType type;
  String message;

  Message(
    this.user,
    this.type,
    this.message,
  );

  Map<String, dynamic> toJSON() => {
        'user': user.toJSON(),
        'type': type.index,
        'message': message,
      };

  Message.fromJSON(Map<String, dynamic> json)
      : user = User.fromJSON(json['user']),
        type = MessageType.values[json['type']],
        message = json['message'];
}

class Room {
  String id;
  User user;
  String url;

  Room(this.id, this.user, this.url);

  Map<String, dynamic> toJSON() => {
        'id': id,
        'user': user.toJSON(),
        'url': url,
      };

  Room.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        user = User.fromJSON(json['user']),
        url = json['url'];
}

class RoomList {
  List<Room> list;

  RoomList(this.list);
}

class DefaultData {
  static User get user => getUser();

  static User getUser() {
    if (_user == null) {
      String json = LocalStorage.getString('user');
      if (json != null && json.isNotEmpty) {
        _user = User.fromJSON(jsonDecode(json));
      } else {
        _user = User();
        LocalStorage.setString('user', jsonEncode(_user.toJSON()));
      }
    }
    return _user;
  }

  static void setUserName(String name) {
    if (_user.name != name) {
      _user.name = name;
      LocalStorage.setString("user", jsonEncode(_user.toJSON()));
    }
  }

  static void logout() {
    _user = null;
    LocalStorage.setString('user', '');
  }

  static User _user;
}
