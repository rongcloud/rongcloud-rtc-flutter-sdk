import 'package:flutter/material.dart';

import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'video_session.dart';
import 'user_data.dart';

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
  final _infoStrings = <String>[];

  bool muted = false;

  String roomId;

  _CallPageState(String roomId) {
    this.roomId = roomId;
  }

  @override
  void dispose() {
    super.dispose();
    _sessions.forEach((session) {
      RongRtcEngine.removeNativeView(session.viewId);
    });
    _sessions.clear();
    RongRtcEngine.leaveRTCRoom(this.roomId);
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() {
    if(AppKey.isEmpty) {
      setState(() {
        _infoStrings.add("没有设置 Appkey，请在 user_data.dart 中设置");
        _infoStrings.add("RongCloud RTC 未初始化");
      });
      return;
    }

    _onJoinRTCRoom();
    _addRTCEventHandlers();
    _renderLocalUser();
  }
  _renderLocalUser() {
    _addRenderView(CurrentUserId,(viewId) {
      RongRtcEngine.renderLocalVideo(viewId);
    });
  }

  _subscribeAndRenderRemoteUser(String userId) {
    RongRtcEngine.subscribeAVStream(userId);
    _addRenderView(userId, (viewId) {
      RongRtcEngine.renderRemoteVideo(viewId, userId);
    });
  }

  _unsubscribeAndRemoveRemoteUser(String userId) {
    RongRtcEngine.unsubscribeAVStream(userId);
    _removeRenderView(userId);
  }

  _onJoinRTCRoom() async {
    int code = await RongRtcEngine.joinRTCRoom(this.roomId);
    if(code == 0) {
      RongRtcEngine.publishAVStream();
      _renderExistedRemoterUsersIfNeed();
    }

    setState(() {
      _infoStrings.add("join room "+this.roomId);
    });
  }

  _renderExistedRemoterUsersIfNeed() async {
    List userIds = await RongRtcEngine.getRemoteUsers(this.roomId);
    if(userIds.length > 0) {
      for(String uid in userIds) {
        _subscribeAndRenderRemoteUser(uid);
      }
    }
  }

  _addRenderView(String userId,Function (int viewId) finished){
    Widget videoView =  RongRtcEngine.createPlatformView(userId,(viewId) {
        setState(() {
          _infoStrings.add("render video for user "+userId);
          _getVideoSession(userId).viewId = viewId;
          if (finished != null) {
            finished(viewId);
          }
        });
      }
    );
    VideoSession session = new VideoSession();
    session.userId = userId;
    session.view = videoView;
    _sessions.add(session);
  }

  _removeRenderView(String userId) {
    VideoSession session = _getVideoSession(userId);
    if(session != null) {
      _sessions.remove(session);
    }
  }

  onMute() {
    this.muted = !this.muted;
    RongRtcEngine.muteLocalAudio(this.muted);

    setState(() {
      String text = this.muted ? "mute" :"unmute";
      _infoStrings.add(text+" local user audio ");
    });
  }

  onHangUp() {
    print("onHangUp");
  }

  onSwitchCamera() {
    RongRtcEngine.switchCamera();
    
    setState(() {
      _infoStrings.add("switch local user camera");
    });
  }

  _addRTCEventHandlers() {
    RongRtcEngine.onUserJoined = (String userId) {
      setState(() {
        _infoStrings.add("user did join "+userId);
      });
    };

    RongRtcEngine.onUserLeaved = (String userId) {
      RongRtcEngine.unsubscribeAVStream(userId);
      setState(() {
        _infoStrings.add("user did leave "+userId);
        _infoStrings.add("unsubscribe stream of user "+userId);
        _unsubscribeAndRemoveRemoteUser(userId);
      });
    };

    RongRtcEngine.onOthersPublishStreams = (String userId) {
      setState(() {
        _infoStrings.add("user did publish stream "+userId);
        _infoStrings.add("subscribe stream of user "+userId);

        _subscribeAndRenderRemoteUser(userId);

      });
    };
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
          children: <Widget>[_viewRows(),_panel(),_bottomToolbar()],
        ),
      ),
    );
  }

  VideoSession _getVideoSession(String userId) {
    return _sessions.firstWhere((session) {
      return session.userId == userId;
    });
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    return _sessions.map((session) => session.view).toList();
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    List<Widget> wrappedViews =
        views.map((Widget view) => _videoView(view)).toList();
    return Expanded(
        child: Row(
      children: wrappedViews,
    ));
  }

  /// Video layout wrapper
  Widget _viewRows() {
    List<Widget> views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  Widget _panel() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: ListView.builder(
                  reverse: true,
                  itemCount: _infoStrings.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_infoStrings.length == 0) {
                      return null;
                    }
                    return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.yellowAccent,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(_infoStrings[index],
                                      style:
                                          TextStyle(color: Colors.blueGrey))))
                        ]));
                  })),
        ));
  }

  Widget _bottomToolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[__muteButton(),__hangUpButton(),__switchCameraButton()],
      ),
    );
  }

  Widget __muteButton() {
    return RawMaterialButton(
      onPressed: () => onMute(),
      child: new Icon(
        this.muted ? Icons.mic_off: Icons.mic,
        color: this.muted ? Colors.white: Colors.blue,
        size: 20,
      ),
      shape:  new CircleBorder(),
      elevation: 2.0,
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