import 'dart:convert';

import 'package:rc_rtc_flutter_example/frame/utils/local_storage.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'constants.dart';

class Result {
  final int code;
  final String? content;

  Result(this.code, this.content);
}

class User {
  String id;
  String name;
  String? key;
  String? navigate;
  String? file;
  String? media;
  String? token;
  bool audio;
  bool video;

  User.remote(
    this.id,
  )   : this.name = 'Unknown',
        this.audio = false,
        this.video = false;

  User.create(
    this.id,
    this.key,
    this.navigate,
    this.file,
    this.media,
    this.token,
  )   : this.name = 'Unknown',
        this.audio = false,
        this.video = false;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        key = json['key'],
        navigate = json['navigate'],
        file = json['file'],
        media = json['media'],
        token = json['token'],
        this.audio = false,
        this.video = false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'key': key,
        'navigate': navigate,
        'file': file,
        'media': media,
        'token': token,
      };
}

class Config {
  bool enableTinyStream;
  bool mirror;
  bool mic;
  bool camera;
  bool audio;
  bool video;
  bool frontCamera;
  bool speaker;
  int minVideoKbps;
  int maxVideoKbps;
  RCRTCFps fps;
  RCRTCVideoResolution resolution;

  Config.config()
      : enableTinyStream = true,
        mirror = true,
        mic = false,
        camera = false,
        audio = false,
        video = false,
        frontCamera = true,
        speaker = false,
        minVideoKbps = 3,
        maxVideoKbps = 2,
        fps = RCRTCFps.fps_30,
        resolution = RCRTCVideoResolution.RESOLUTION_720_1280;

  RCRTCVideoStreamConfig get videoConfig {
    _videoConfig.minRate = MinVideoKbps[minVideoKbps];
    _videoConfig.maxRate = MaxVideoKbps[maxVideoKbps];
    _videoConfig.fps = fps;
    _videoConfig.resolution = resolution;
    return _videoConfig;
  }

  Map<String, dynamic> toJson() => {
        'enableTinyStream': enableTinyStream,
        'mirror': mirror,
        'mic': mic,
        'camera': camera,
        'audio': audio,
        'video': video,
        'frontCamera': frontCamera,
        'speaker': speaker,
        'minVideoKbps': minVideoKbps,
        'maxVideoKbps': maxVideoKbps,
        'fps': fps.index,
        'resolution': resolution.index,
      };

  Config.fromJson(Map<String, dynamic> json)
      : enableTinyStream = json['enableTinyStream'],
        mirror = json['mirror'],
        mic = json['mic'],
        camera = json['camera'],
        audio = json['audio'],
        video = json['video'],
        frontCamera = json['frontCamera'],
        speaker = json['speaker'],
        minVideoKbps = json['minVideoKbps'],
        maxVideoKbps = json['maxVideoKbps'],
        fps = RCRTCFps.values[json['fps']],
        resolution = RCRTCVideoResolution.values[json['resolution']];

  final RCRTCVideoStreamConfig _videoConfig = RCRTCVideoStreamConfig(
    300,
    1000,
    RCRTCFps.fps_30,
    RCRTCVideoResolution.RESOLUTION_720_1280,
  );
}

class CDN {
  CDN(
    this.id,
    this.name,
  );

  final String id;
  final String name;
}

class CDNInfo {
  CDNInfo.fromJons(Map<String, dynamic> json)
      : push = json['push'],
        rtmp = json['rtmp'],
        hls = json['hls'],
        flv = json['flv'];

  final String push;
  final String rtmp;
  final String hls;
  final String flv;
}

class Stream {
  Stream(
    this.user,
    this.stream,
  );

  final String user;
  final String stream;
}

class DefaultData {
  static void loadUsers() {
    String? json = LocalStorage.getString('users');
    if (json != null && json.isNotEmpty) {
      var list = jsonDecode(json);
      for (var user in list) _users.add(User.fromJson(user));
    }
  }

  static void clear() {
    _users.clear();
    String json = jsonEncode(_users);
    LocalStorage.setString("users", json);
  }

  static set user(User? user) {
    if (user == null) return;
    _user = user;
    _users.removeWhere((element) => "${user.id}${user.name}${user.key}" == "${element.id}${element.name}${element.key}");
    _users.add(user);
    String json = jsonEncode(_users);
    LocalStorage.setString("users", json);
  }

  static User? get user => _user;

  static List<User> get users => _users;

  static User? _user;
  static List<User> _users = [];
}
