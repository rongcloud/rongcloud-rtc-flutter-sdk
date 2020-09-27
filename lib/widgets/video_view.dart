import 'package:FlutterRTC/data/data.dart';
import 'package:rongcloud_rtc_plugin/agent/view/rcrtc_video_view.dart';

class VideoView {
  VideoView(this._user, this.view);

  User get user => _user;

  User _user;
  RCRTCVideoView view;
}
