import 'package:FlutterRTC/data/data.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class TextureView {
  TextureView(this._user, this.view);

  User get user => _user;

  User _user;
  RCRTCTextureView view;
}