import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class MemberItemView extends StatefulWidget {
  final RCRTCUser user;

  MemberItemView(this.user);

  @override
  _MemberItemViewState createState() => _MemberItemViewState();
}

class _MemberItemViewState extends State<MemberItemView> {
  static const _tag = "_MemberItemViewState";
  @override
  Widget build(BuildContext context) {
    return Container(
//        color: Colors.lightGreen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(6)),
            child: Row(children: [
              Icon(Icons.account_box,
                  size: ScreenUtil().setWidth(40),
                  color: widget.user is RCRTCLocalUser ? Colors.red[700] : Colors.lightBlue[700]),
              Container(width: ScreenUtil().setWidth(5)),
              Text(widget.user.id, style: TextStyle(fontSize: 18)),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: IconButton(
                    icon: Icon(Icons.videocam),
                    iconSize: ScreenUtil().setWidth(30),
                    onPressed: () => _handlerVideoMute(),
                    color: _isVideoEnable() ? Colors.lightGreen[700] : Colors.grey[500]),
              ),
              Container(width: ScreenUtil().setWidth(5)),
              GestureDetector(
                onTap: () {},
                child: IconButton(
                    icon: Icon(Icons.mic),
                    iconSize: ScreenUtil().setWidth(30),
                    onPressed: () => _handlerAudioMute(),
                    color: _isAudioEnable() ? Colors.lightGreen[700] : Colors.grey[500]),
              ),
            ]),
          ),
          Container(
            height: ScreenUtil().setHeight(0.5),
            color: Colors.black38,
          ),
        ],
      ),
    );

//    );
  }

  _handlerAudioMute() async {
    if (widget.user is RCRTCLocalUser) {
      RCRTCLocalUser localUser = widget.user as RCRTCLocalUser;
      List<RCRTCOutputStream> streamList = await localUser.getStreams();
      var micStreams = streamList.where((element) => element.type == MediaType.audio);
      if (micStreams.length > 0) {
        RCRTCMicOutputStream audioOutputStream = micStreams.elementAt(0) as RCRTCMicOutputStream;
        audioOutputStream.mute(!audioOutputStream.isMute());
      }
    } else {
      RCRTCRemoteUser remoteUser = widget.user as RCRTCRemoteUser;
      List<RCRTCInputStream> streamList = remoteUser.streamList;
      var audioSteams = streamList.where((element) => element.type == MediaType.audio);
      if (audioSteams.length > 0) {
        RCRTCAudioInputStream audioInputStream = audioSteams.elementAt(0);
        RCRTCLog.d(_tag, "_handlerAudioMute set remote audio mute ${!audioInputStream.isMute()}");
        audioInputStream.mute(!audioInputStream.isMute());
      }
    }
    setState(() {});
  }

  _handlerVideoMute() async {
    if (widget.user is RCRTCLocalUser) {
      RCRTCLocalUser localUser = widget.user as RCRTCLocalUser;
      List<RCRTCOutputStream> streamList = await localUser.getStreams();
      var videoStreams = streamList.where((element) => element.type == MediaType.video);
      if (videoStreams.length > 0) {
        // TODO: (wangjingbiao):多条视频流？
        RCRTCCameraOutputStream cameraOutputStream = videoStreams.elementAt(0) as RCRTCCameraOutputStream;
        cameraOutputStream.mute(!cameraOutputStream.isMute());
      }
    } else {
      RCRTCRemoteUser remoteUser = widget.user as RCRTCRemoteUser;
      List<RCRTCInputStream> streamList = remoteUser.streamList;
      var videoStreams = streamList.where((element) => element.type == MediaType.video);
      if (videoStreams.length > 0) {
        RCRTCVideoInputStream videoInputStream = videoStreams.elementAt(0);
        RCRTCLog.d(_tag, "_handlerVideoMute set remote view mute: ${!videoInputStream.isMute()}");
        videoInputStream.mute(!videoInputStream.isMute());
      }
    }
    setState(() {});
  }

  bool _isAudioEnable() {
    if (widget.user is RCRTCLocalUser) {
      RCRTCLocalUser localUser = widget.user as RCRTCLocalUser;
      List<RCRTCOutputStream> streamList = localUser.getStreams();
      var micStreams = streamList.where((element) => element.type == MediaType.audio);
      if (micStreams.length > 0) {
        RCRTCMicOutputStream audioOutputStream = micStreams.elementAt(0) as RCRTCMicOutputStream;
        print('is local audio mute ? = ${audioOutputStream.isMute()}');
        return !audioOutputStream.isMute();
      }
    } else {
      RCRTCRemoteUser remoteUser = widget.user as RCRTCRemoteUser;
      List<RCRTCInputStream> streamList = remoteUser.streamList;
      var audioSteams = streamList.where((element) => element.type == MediaType.audio);
      if (audioSteams.length > 0) {
        RCRTCAudioInputStream audioInputStream = audioSteams.elementAt(0);
        print('is remote audio mute ? = ${audioInputStream.isMute()}');
        return !audioInputStream.isMute();
      }
    }
    return false;
  }

  bool _isVideoEnable() {
    if (widget.user is RCRTCLocalUser) {
      RCRTCLocalUser localUser = widget.user as RCRTCLocalUser;
      List<RCRTCOutputStream> streamList = localUser.getStreams();
      var videoStreams = streamList.where((element) => element.type == MediaType.video);
      if (videoStreams.length > 0) {
        // TODO: (wangjingbiao):多条视频流？
        RCRTCCameraOutputStream cameraOutputStream = videoStreams.elementAt(0) as RCRTCCameraOutputStream;
        print('is video mute ? = ${cameraOutputStream.isMute()}');
        return !cameraOutputStream.isMute();
      }
    } else {
      RCRTCRemoteUser remoteUser = widget.user as RCRTCRemoteUser;
      List<RCRTCInputStream> streamList = remoteUser.streamList;
      var videoStreams = streamList.where((element) => element.type == MediaType.video);
      if (videoStreams.length > 0) {
        RCRTCVideoInputStream videoInputStream = videoStreams.elementAt(0) as RCRTCVideoInputStream;
        print('is remote video mute ? = ${videoInputStream.isMute()}');
        return !videoInputStream.isMute();
      }
    }
    return true;
  }
}
