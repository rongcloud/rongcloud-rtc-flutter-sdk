import 'dart:convert';

import 'package:FlutterRTC/frame/utils/local_storage.dart';
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
  String token;

  User.unknown(this.id) : name = 'unknown';

  User._create(
    this.id,
    this.name,
    this.avatar,
  );

  factory User() {
    String prefix = GlobalConfig.userIdPrefix;
    int current = DateTime.now().millisecondsSinceEpoch;
    User user = User._create('$prefix$current', '', 'assets/images/user_avatar/user_avatar_0.png');
    return user;
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'avatar': avatar,
      };

  User.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        avatar = json['avatar'];
}

class Config {
  bool mic;
  bool speaker;
  bool camera;
  bool frontCamera;

  Config.config()
      : mic = true,
        speaker = false,
        camera = true,
        frontCamera = true;

  Map<String, dynamic> toJSON() => {
        'mic': mic,
        'speaker': speaker,
        'camera': camera,
        'frontCamera': frontCamera,
      };

  Config.fromJSON(Map<String, dynamic> json)
      : mic = json['mic'],
        speaker = json['speaker'],
        camera = json['camera'],
        frontCamera = json['frontCamera'];
}

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

class DefaultData {
  static User get user => getUser();

  static User getUser() {
    if (_user == null) {
      String userJson = LocalStorage.getString("user");
      if (userJson != null) {
        _user = User.fromJSON(jsonDecode(userJson));
      } else {
        _user = User();
        LocalStorage.setString("user", jsonEncode(_user.toJSON()));
      }
    }
    return _user;
  }

  static void setUserName(String userName) {
    if (_user.name != userName) {
      _user.name = userName;
      LocalStorage.setString("user", jsonEncode(_user.toJSON()));
    }
  }

  static void setUserAvatar(String iconPath) {
    if (_user.avatar != iconPath) {
      _user.avatar = iconPath;
      LocalStorage.setString("user", jsonEncode(_user.toJSON()));
    }
  }

  static RCRTCVideoStreamConfig get videoConfig => _videoConfig;

  static set videoMinRate(int rate) {
    _videoConfig.minRate = rate;
  }

  static set videoMaxRate(int rate) {
    _videoConfig.maxRate = rate;
  }

  static set videoFPS(RCRTCFps fps) {
    _videoConfig.fps = fps;
  }

  static set videoResolution(RCRTCVideoResolution resolution) {
    _videoConfig.resolution = resolution;
  }

  static RCRTCVideoStreamConfig _videoConfig = RCRTCVideoStreamConfig(
    300,
    1000,
    RCRTCFps.fps_30,
    RCRTCVideoResolution.RESOLUTION_720_1280,
  );

  static bool enableTinyStream = true;

  static User _user;
}
