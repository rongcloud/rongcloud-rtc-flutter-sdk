import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  final String roomId;

  const CallPage({Key key,this.roomId}) : super(key:key);

  @override
  State<StatefulWidget> createState() {
    return new _CallPageState();
  }
}

class _CallPageState extends State<CallPage> {

  bool muted = false;

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
          children: <Widget>[_bottomToolbar()],
        ),
      ),
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