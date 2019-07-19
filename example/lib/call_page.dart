import 'package:flutter/material.dart';

import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

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
  List<String> _infos = new List();
  VideoSession mainSession ;
  bool muted = false;

  double videoWidth = 100;
  double videoHeight = 150;

  double screenWidth;
  double screenHeight;

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
        _addInfoString("没有设置 Appkey，请在 user_data.dart 中设置");
        _addInfoString("RongCloud RTC 未初始化");
      });
      return;
    }

    RongRtcEngine.config(RongRtcConfig.defaultConfig());

    _onJoinRTCRoom();
    _addRTCEventHandlers();
  }

  _onJoinRTCRoom() async {
    int code = await RongRtcEngine.joinRTCRoom(this.roomId);
    if(code == 0) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

      _renderLocalUser();

      _renderExistedRemoterUsersIfNeed();
    }

    setState(() {
      _addInfoString("join room "+this.roomId);
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

  _addRTCEventHandlers() {
    RongRtcEngine.onUserJoined = (String userId) {
      setState(() {
        _addInfoString("user did join:"+userId);
      });
    };

    RongRtcEngine.onUserLeaved = (String userId) {
      RongRtcEngine.unsubscribeAVStream(userId);
      setState(() {
        _addInfoString("user did leave:"+userId);
        _addInfoString("unsubscribe stream of user:"+userId);
        _unsubscribeAndRemoveRemoteUser(userId);
      });
    };

    RongRtcEngine.onRemoteUserPublishStreams = (String userId) {
      _subscribeAndRenderRemoteUser(userId);
      setState(() {
        _addInfoString("user did publish stream:"+userId);
        _addInfoString("subscribe stream of user:"+userId);
      });
    };

    RongRtcEngine.onRemoteUserUnpublishStreams = (String userId) {
      setState(() {
        _addInfoString("user did unpublish stream:"+userId);
      });
    };

    RongcloudImPlugin.onConnectionStatusChange = (int connectionStatus) {
      if(RCConnectionStatus.KickedByOtherClient == connectionStatus) {
        print("该账号在其他设备登录，当前账号已离线");
        onHangUp();
      }
    };
  }

  _subscribeAndRenderRemoteUser(String userId) {
    RongRtcEngine.subscribeAVStream(userId);
    Widget videoView =  RongRtcEngine.createPlatformView(userId,videoWidth.toInt(),videoHeight.toInt(),(viewId) {
        setState(() {
          _addInfoString("render remote video for user:"+userId);
          _getVideoSession(userId).viewId = viewId;
          RongRtcEngine.renderRemoteVideo(viewId, userId);
        });
      }
    );
    VideoSession session = new VideoSession();
    session.userId = userId;
    session.view = videoView;
    _sessions.add(session);
  }

  _renderLocalUser() {
    Widget videoView =  RongRtcEngine.createPlatformView(CurrentUserId,screenWidth.toInt(),screenHeight.toInt(),(viewId) {
        setState(() {
          mainSession.viewId = viewId;
          _addInfoString("render local video for user:"+CurrentUserId);
          RongRtcEngine.renderLocalVideo(viewId);
          RongRtcEngine.publishAVStream();
        });
      }
    );
    VideoSession session = new VideoSession();
    session.userId = CurrentUserId;
    session.view = videoView;
    mainSession = session;
    mainSession.width = screenWidth;
    mainSession.height = screenHeight;
  }

  _unsubscribeAndRemoveRemoteUser(String userId) {
    RongRtcEngine.unsubscribeAVStream(userId);
    VideoSession session = _getVideoSession(userId);
    if(session != null) {
      _sessions.remove(session);
    }
  }

  VideoSession _getVideoSession(String userId) {
    for(VideoSession sess in _sessions) {
      if(sess.userId == userId) {
        return sess;
      }
    }
    return null;
  }

  onSwitchCamera() {
    RongRtcEngine.switchCamera();
    
    setState(() {
      _addInfoString("switch local user camera");
    });
  }

  onMute() {
    this.muted = !this.muted;
    RongRtcEngine.muteLocalAudio(this.muted);

    setState(() {
      String text = this.muted ? "mute" :"unmute";
      _addInfoString(text+" local user audio ");
    });
  }

  onHangUp() {
    Navigator.pop(context);
  }

  void _addInfoString(String info) {
    _infos.add(info);
    print(info);
  }

  onTapSmallVideoView(int index) {
    RongRtcEngine.exchangeVideo(mainSession.viewId, _sessions[index].viewId);
    String tmpUserId = mainSession.userId;
    mainSession.userId = _sessions[index].userId;
    _sessions[index].userId = tmpUserId;
    print("GestureDetector onTap");
  }

  Widget _getVideoContainer(int index) {
    VideoSession session = _sessions[index];

    if(session.view == null) {
      return Container(
        width: session.width,
        height: session.height,
        color: Colors.blue,
      );
    }

    GestureDetector ges = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTapSmallVideoView(index);
      },
    );

    return Container(
      width: session.width,
      height: session.height,
      color: Colors.blue,
      child: Stack(
        children: <Widget>[
          session.view,ges
        ],
      ),
    ); 
  }

  Widget _getListView() {
    return Container(
        height: videoHeight,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _sessions.length,
          itemBuilder: (BuildContext context,int index) {
            if(_sessions.length == 0) {
              return null;
            }
            _sessions[index].width = videoWidth;
            _sessions[index].height = videoHeight;
            return _getVideoContainer(index);
          },
        ),
      );
  }

  Widget _getMainVideoView(){
    double width = 0;
    double height = 0;
    if(mainSession != null) {
      width = mainSession.width;
      height = mainSession.height;
    }else {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    }

    if(mainSession == null || mainSession.view == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.blue,
      );
    }

    return Container(
      width: width,
      height: height,
      color: Colors.blue,
      child: mainSession.view,
    );
  }

  Widget _getInfoListView() {
    return Container(
      width: 500,
      height: 500,
      padding: EdgeInsets.fromLTRB(10, 300, 200, 50),
      alignment: Alignment.bottomCenter,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
          itemCount: _infos.length,
          itemBuilder: (BuildContext context,int index) {
            if(_infos.length == 0) {
              return null;
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow
                      ),
                      child: Text(_infos[index],style: TextStyle(color: Colors.black)),
                    ),
                  )
                ],
              ),
            );
          },
      ),
    );
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
          children: <Widget>[_getMainVideoView(),_getListView(),_getInfoListView(),_getBottomToolbar()],
        ),
      ),
    );
  }

  Widget _getBottomToolbar() {
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
