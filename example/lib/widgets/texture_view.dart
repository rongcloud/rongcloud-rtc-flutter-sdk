import 'package:FlutterRTC/data/data.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class UserView {
  UserView(this._user);

  Widget get widget {
    if (_build) {
      _build = false;
      _widget = _videoStream != null
          ? RCRTCTextureView(
              (videoView, id) {
                _videoStream.setTextureView(id);
              },
              fit: _fit,
              mirror: _mirror,
            )
          : null;
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
    _audioStream = stream;
    if (stream != null && stream is RCRTCAudioInputStream) _remoteAudioStream = stream;
    _audio = _audioStream != null;
    invalidate();
  }

  RCRTCAudioInputStream get audioStream => _remoteAudioStream;

  bool get video => _video;

  set videoStream(dynamic stream) {
    assert(stream == null || stream is RCRTCVideoInputStream || stream is RCRTCVideoOutputStream, 'unsupported stream type ${stream.runtimeType}!');
    _videoStream = stream;
    if (stream != null && stream is RCRTCVideoInputStream) _remoteVideoStream = stream;
    _video = _videoStream != null;
    invalidate();
  }

  RCRTCVideoInputStream get videoStream => _remoteVideoStream;

  get fit => _fit;

  set fit(BoxFit fit) {
    _fit = fit;
    invalidate();
  }

  get mirror => _mirror;

  set mirror(bool mirror) {
    _mirror = mirror;
    invalidate();
  }

  void invalidate() {
    _build = true;
  }

  bool _build = true;

  BoxFit _fit = BoxFit.cover;
  bool _mirror = true;

  User _user;

  dynamic _audioStream;
  RCRTCAudioInputStream _remoteAudioStream;
  bool _audio = false;

  dynamic _videoStream;
  RCRTCVideoInputStream _remoteVideoStream;
  bool _video = false;

  Widget _widget;
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
