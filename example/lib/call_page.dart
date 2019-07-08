import 'package:flutter/material.dart';

import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'video_session.dart';

class CallPage extends StatefulWidget {
  String roomId;

  CallPage(String roomId) {
    this.roomId = roomId;
  }

  @override
  State<StatefulWidget> createState() {
    return new _CallPageState(this.roomId);
  }
}

class _CallPageState extends State<CallPage> {

  List<VideoSession> _sessions = new List();

  bool muted = false;

  String roomId;

  _CallPageState(String roomId) {
    this.roomId = roomId;
  }

  @override
  void initState() {
    super.initState();
    onJoinRTCRoom();
  }

  onJoinRTCRoom() async {
    int code = await RongRtcEngine.joinRTCRoom(this.roomId);
    if(code == 0) {
      onPublishStream();
    }
    renderVideoView();
  }

  onPublishStream() {
    RongRtcEngine.publishAVStream();

    
  }

  renderVideoView() {
    String userId = "flutter_ios0";
    double x = 0.0;
    double y = 0.0;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    Widget videoView =  VideoPlayer.createPlatformView(userId,x,y,width,height);
    
    VideoSession vs = new VideoSession();
    vs.userId = userId;
    vs.videoView = videoView;
    _sessions.add(vs);

    RongRtcEngine.renderVideoView(userId);
  }

  onMute() {
    print("onMute");
  }

  onHangUp() {
    print("onHangUp");
  }

  onSwitchCamera() {
    print("onSwitchCamera");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RongCloud RTC"),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[_getLocalUserView(),_bottomToolbar()],
        ),
      ),
    );
  }

  Widget _getLocalUserView() {
    double x = 0.0;
    double y = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Container(
      width: width,
      height: height,
      child: VideoPlayer.createPlatformView("flutter_ios0",x,y,width,height),
    );
  }

  Widget _bottomToolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Row(
          children: <Widget>[__muteButton(),__hangUpButton(),__switchCameraButton()],
      ),
    );
  }

  Widget __muteButton() {
    return RawMaterialButton(
      onPressed: () => onMute(),
      child: new Icon(
        this.muted ? Icons.mic: Icons.mic_off,
        color: this.muted ? Colors.white: Colors.blue,
        size: 20,
      ),
      shape:  new CircleBorder(),
      elevation: 2/0,
      fillColor: this.muted ? Colors.blue: Colors.white,
      padding: EdgeInsets.all(12.0),
    );
  }

  Widget __hangUpButton() {
    return RawMaterialButton(
      onPressed: () => onHangUp(),
      child: new Icon(
        Icons.call_end,
        color: Colors.white,
        size: 35.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.redAccent,
      padding: const EdgeInsets.all(15.0),
    );
  }

  Widget __switchCameraButton() {
    return RawMaterialButton(
      onPressed: () => onSwitchCamera(),
      child: new Icon(
        Icons.switch_camera,
        color: Colors.blueAccent,
        size: 20.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(12.0),
    );
  }
}