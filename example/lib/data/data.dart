import 'dart:convert';

import 'package:FlutterRTC/frame/utils/local_storage.dart';

import '../global_config.dart';
import 'constants.dart';

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
  static User _user;

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
}
