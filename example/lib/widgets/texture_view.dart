import 'package:FlutterRTC/data/data.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class TextureView {
  TextureView(this._user, this.view);

  User get user => _user;

  User _user;
  RCRTCTextureView view;
}

class VideoStreamWidget {
  VideoStreamWidget(this._user, this._stream);

  Widget get widget {
    if (_build) {
      _build = false;
      _widget = RCRTCTextureView(
        (videoView, id) {
          if (_stream is RCRTCVideoInputStream || _stream is RCRTCVideoOutputStream) _stream.setTextureView(id);
        },
        fit: _fit,
        mirror: _mirror,
      );
    }
    return _widget;
  }

  User get user => _user;

  get fit => _fit;

  set fit(BoxFit fit) {
    _fit = fit;
    _build = true;
  }

  get mirror => _mirror;

  set mirror(bool mirror) {
    _mirror = mirror;
    _build = true;
  }

  void invalidate() {
    _build = true;
  }

  bool _build = true;

  BoxFit _fit = BoxFit.cover;
  bool _mirror = true;

  User _user;
  dynamic _stream;

  RCRTCTextureView _widget;
}
