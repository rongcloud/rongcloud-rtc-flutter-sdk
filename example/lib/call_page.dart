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
  ///大窗口的 session
  VideoSession mainSession ;
  ///小窗口的 session 列表
  List<VideoSession> _sessions = new List();

  ///提示信息
  List<String> _infos = new List();

  bool muted = false;

  ///默认小窗口视频的宽高
  double videoWidth = 100;
  double videoHeight = 150;

  ///屏幕宽高
  double screenWidth;
  double screenHeight;

  ///当前的房间 id
  String roomId;

  _CallPageState(String roomId) {
    this.roomId = roomId;
  }

  @override
  void dispose() {
    super.dispose();
    _sessions.forEach((session) {
      RongRTCEngine.removePlatformView(session.viewId);
    });
    _sessions.clear();
    RongRTCEngine.leaveRTCRoom(this.roomId,null);
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

    ///配置默认的参数
    RongRTCEngine.config(RongRTCConfig.defaultConfig());

    _onJoinRTCRoom();
    _addRTCEventHandlers();
  }

  /// 加入 RTC 房间
  _onJoinRTCRoom() async {
    RongRTCEngine.joinRTCRoom(this.roomId,(int code) {
      if(code == 0) {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

        /// 渲染当前用户的视频
        _renderLocalUser();

        /// 渲染已经存在的远端用户视频
        _renderExistedRemoterUsersIfNeed();

        setState(() {
          _addInfoString("join room "+this.roomId);
        });
      }
    });
    

  }

  /// 渲染已经存在的远端用户视频
  _renderExistedRemoterUsersIfNeed() async {
    List userIds = await RongRTCEngine.getRemoteUsers(this.roomId);
    if(userIds.length > 0) {
      for(String uid in userIds) {
        /// 渲染单个远端用户 id
        _subscribeAndRenderRemoteUser(uid);
      }
    }
  }

  ///设置 RTC 事件监听
  _addRTCEventHandlers() {

    /// 由用户加入
    RongRTCEngine.onUserJoined = (String userId) {
      setState(() {
        _addInfoString("user did join:"+userId);
      });
    };

    ///有用户离开
    RongRTCEngine.onUserLeaved = (String userId) {
      ///取消已经订阅的音视频流
      RongRTCEngine.unsubscribeAVStream(userId,(int code) {
        setState(() {
          _addInfoString("user did leave:"+userId);
          _addInfoString("unsubscribe stream of user:"+userId);
          _unsubscribeAndRemoveRemoteUser(userId);
        });
      });
    };

    ///有用户发布流
    RongRTCEngine.onUserStreamPublished = (String userId) {
      ///订阅并渲染用户的流
      _subscribeAndRenderRemoteUser(userId);
      setState(() {
        _addInfoString("user did publish stream:"+userId);
        _addInfoString("subscribe stream of user:"+userId);
      });
    };

    ///有用户取消发布流
    RongRTCEngine.onUserStreamUnpublished = (String userId) {
      setState(() {
        _addInfoString("user did unpublish stream:"+userId);
      });
    };

    /// IM 连接状态变更
    RongcloudImPlugin.onConnectionStatusChange = (int connectionStatus) {
      if(RCConnectionStatus.KickedByOtherClient == connectionStatus) {
        print("该账号在其他设备登录，当前账号已离线");
        onHangUp();
      }
    };
  }

  _subscribeAndRenderRemoteUser(String userId) {
    ///订阅远端用户的流
    RongRTCEngine.subscribeAVStream(userId,(int code) {
      if(code == RongRTCCode.Success) {
          /// 创建 platform view
          Widget videoView = RongRTCEngine.createPlatformView(userId,videoWidth.toInt(),videoHeight.toInt(),(viewId) {
            setState(() {
              _addInfoString("render remote video for user:"+userId);
              _getVideoSession(userId).viewId = viewId;
              RongRTCEngine.renderRemoteVideo(userId, viewId);
            });
          }
        );
        ///相关数据加入 session 中
        VideoSession session = new VideoSession();
        session.userId = userId;
        session.view = videoView;
        _sessions.add(session);
      } 
    });
    
  }

  ///渲染本地用户视频流
  _renderLocalUser() {
    Widget videoView =  RongRTCEngine.createPlatformView(CurrentUserId,screenWidth.toInt(),screenHeight.toInt(),(viewId) {
        setState(() {
          mainSession.viewId = viewId;
          _addInfoString("render local video for user:"+CurrentUserId);
          RongRTCEngine.renderLocalVideo(viewId);
          RongRTCEngine.publishAVStream((int code) {
            setState(() {
              _addInfoString("local user publish av stream:"+code.toString());
            });
          });
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

  ///取消订阅并移除远端用户视频流
  _unsubscribeAndRemoveRemoteUser(String userId) {
    RongRTCEngine.unsubscribeAVStream(userId,(int code) {
      if(code == RongRTCCode.Success) {
        VideoSession session = _getVideoSession(userId);
        if(session != null) {
          _sessions.remove(session);
        }
      }
    });
    
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
    RongRTCEngine.switchCamera();
    
    setState(() {
      _addInfoString("switch local user camera");
    });
  }

  onMute() {
    this.muted = !this.muted;
    RongRTCEngine.muteLocalAudio(this.muted);

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

  ///点击小窗口，进行大小窗口视频切换
  onTapSmallVideoView(int index) {
    String tmpUserId = mainSession.userId;
    mainSession.userId = _sessions[index].userId;
    _sessions[index].userId = tmpUserId;

    RongRTCEngine.exchangeVideo(mainSession.viewId, _sessions[index].viewId);
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
