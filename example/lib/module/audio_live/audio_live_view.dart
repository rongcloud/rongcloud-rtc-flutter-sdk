import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class AudioStreamView {
  AudioStreamView(
    this._user, {
    this.name = false,
  });

  Widget get widget {
    if (_build) {
      _build = false;
      _widget = Container(
        padding: EdgeInsets.all(16.dp),
        decoration: BoxDecoration(
          color: Color(0xFF102032),
          borderRadius: BorderRadius.circular(4.dp),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  width: 80.dp,
                  height: 80.dp,
                  child: user.avatar.fullImage,
                ),
                Offstage(
                  offstage: !_speak,
                  child: 'audio_avatar_icon'.png.image,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 3.dp),
              child: Text(
                '${name ? user.name : user.id}',
                softWrap: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return _widget;
  }

  bool get self {
    return user.id == DefaultData.user.id;
  }

  User get user => _user;

  bool get audio => _audio;

  set audioStream(dynamic stream) {
    assert(stream == null || stream is RCRTCAudioInputStream || stream is RCRTCAudioOutputStream, 'unsupported stream type ${stream.runtimeType}!');
    _stream = stream;
    invalidate();
  }

  dynamic get stream => _stream;

  set speak(bool speak) {
    _speak = speak;
    invalidate();
  }

  void invalidate() {
    _build = true;
  }

  bool _build = true;

  User _user;

  final bool name;

  dynamic _stream;
  bool _audio = false;

  bool _speak = false;

  Widget _widget;
}
