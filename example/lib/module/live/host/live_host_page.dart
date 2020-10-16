import 'dart:ui';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/widgets/video_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rongcloud_rtc_plugin/agent/view/rcrtc_video_view.dart';

import '../../../colors.dart';
import 'live_host_page_contract.dart';
import 'live_host_page_presenter.dart';

class LiveHostPage extends AbstractView {
  @override
  _LiveHostPageState createState() => _LiveHostPageState();
}

class _LiveHostPageState extends AbstractViewState<Presenter, LiveHostPage> with WidgetsBindingObserver implements View {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !_paused) {
      _paused = true;
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      if (_showPermissionGuide) presenter?.requestPermission();
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 30.0,
              bottom: 50.0,
              left: 2.0,
              right: 2.0,
            ),
            child: _buildMainView(context),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0,
              left: 20.0,
              right: 20.0,
            ),
            child: _buildBottomBar(context),
          ),
          _buildPermissionGuild(context),
        ],
      ),
      onWillPop: () => _buildConfirmExit(context),
    );
  }

  Widget _buildMainView(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.lightBlue,
        child: Stack(
          children: [
            _buildVideoView(context),
            _buildInfoView(context),
            _buildBottomView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _videoView ?? Container(),
          Center(
            child: _buildPushViewByState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPushViewByState(BuildContext context) {
    switch (_pushState) {
      case 0:
        return _buildPushInitInfo(context);
      case 1:
        return _buildPushWaitInfo(context);
      case 3:
        return _buildPushErrorInfo(context);
    }
    return Container();
  }

  Widget _buildPushInitInfo(BuildContext context) {
    return Text(
      "初始化...",
      style: TextStyle(
        color: Colors.lightGreen,
        fontSize: 30.0,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildPushWaitInfo(BuildContext context) {
    return Text(
      "正在链接...",
      style: TextStyle(
        color: Colors.lightGreen,
        fontSize: 30.0,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildPushErrorInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _rePush(),
      child: Text(
        "推流失败，点击重试",
        style: TextStyle(
          color: Colors.lightGreen,
          fontSize: 30.0,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  void _rePush() {
    setState(() {
      _pushState = 1;
    });
    presenter.push();
  }

  Widget _buildInfoView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: [
          Stack(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: ColorConfig.blackAlpha66,
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: Image.asset("assets/images/default_user_icon.jpg"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.0,
                            right: 20.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                "本场点赞",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: Image.asset("assets/images/default_user_icon.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: Image.asset("assets/images/default_user_icon.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: Image.asset("assets/images/default_user_icon.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.0,
                      constraints: BoxConstraints(
                        minWidth: 40.0,
                      ),
                      padding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: ColorConfig.blackAlpha33,
                      ),
                      child: Text(
                        "0",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "网络状态",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomView(BuildContext context) {
    return Row(
      children: [
        _buildMessageView(context),
        _buildSideRemoteView(context),
      ],
    );
  }

  Widget _buildMessageView(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(
            bottom: 5.0,
            left: 15.0,
            right: 15.0,
          ),
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: 200,
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
                shrinkWrap: true,
                controller: _messageController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(context, _messages[index]);
                }),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Message message) {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: ColorConfig.blackAlpha33,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 5.0,
                  bottom: 5.0,
                ),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${message.user.name}:',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.lightBlueAccent,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      TextSpan(
                        text: message.message,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideRemoteView(BuildContext context) {
    if (_liveType == LiveType.normal) return Container();
    return Container(
      padding: EdgeInsets.only(
        right: 15.0,
        bottom: 10.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildSideRemoteViews(context),
      ),
    );
  }

  List<Widget> _buildSideRemoteViews(BuildContext context) {
    List<Widget> widgets = List();
    _remoteViews.forEach((view) {
      widgets.add(_buildRemoteView(context, view));
    });
    return widgets;
  }

  Widget _buildRemoteView(BuildContext context, VideoView view) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.0,
      ),
      child: Container(
        width: 90.0,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.yellow,
            alignment: Alignment.center,
            child: view.view,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => _buildPKDialog(context),
                  child: SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: Image.asset("assets/images/pk.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => _buildRoomDialog(context),
                  child: SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: Image.asset("assets/images/contact.png"),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => presenter.switchCamera(),
                  child: SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: Icon(
                      FontAwesomeIcons.video,
                      color: Colors.grey,
                      size: 22.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => presenter.muteMicrophone(),
                  child: SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: Icon(
                      _microphoneIcon,
                      color: Colors.grey,
                      size: 22.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => _buildConfirmExit(context),
                  child: SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: Image.asset("assets/images/close.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => _buildOptionsDialog(context),
                  child: SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: Image.asset("assets/images/options.png"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _buildPKDialog(BuildContext context) {
    // TODO pk
  }

  void _buildRoomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    "观众联线",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSingleModeButton(context),
                    _buildGroupModeButton(context),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _buildOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {
                        presenter.switchCamera();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.face),
                      onPressed: () {
                        presenter.setMirror();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleModeButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 20.0,
      ),
      child: GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset("assets/images/default_user_icon.jpg"),
            ),
            Text(
              "双人聊",
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          _buildMemberList(context, LiveType.single);
        },
      ),
    );
  }

  Widget _buildGroupModeButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
      ),
      child: GestureDetector(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset("assets/images/default_user_icon.jpg"),
              ),
              Text(
                "聊天室",
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            _buildMemberList(context, LiveType.group);
          }),
    );
  }

  void _buildMemberList(BuildContext context, LiveType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setter) {
          if (_memberListSetter == null) {
            _memberListSetter = setter;
            _members.clear();
            presenter?.requestMemberList();
          }
          return WillPopScope(
            child: Container(
              padding: EdgeInsets.only(
                top: 10.0,
                bottom: 20.0,
              ),
              constraints: BoxConstraints(
                maxHeight: 300,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10.0,
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "在线观众",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Icon(FontAwesomeIcons.solidWindowClose),
                          onTap: () => _onCloseMemberList(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          return _buildMember(context, _members[index], type);
                        }),
                  ),
                ],
              ),
            ),
            onWillPop: () {
              _onCloseMemberList(context);
              return Future.value(false);
            },
          );
        });
      },
    );
  }

  void _onCloseMemberList(BuildContext context) {
    Navigator.pop(context);
    _memberListSetter = null;
  }

  Widget _buildMember(BuildContext context, User user, LiveType type) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 10.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset("assets/images/default_user_icon.jpg"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.0,
            ),
            child: Text(
              user.name,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Spacer(),
          _buildMemberActionButton(context, user, type),
        ],
      ),
    );
  }

  Widget _buildMemberActionButton(BuildContext context, User user, LiveType type) {
    bool inChatting = _isMemberInChatting(user);
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: ColorConfig.defaultBlue,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 4.0,
            bottom: 4.0,
          ),
          child: Text(
            inChatting ? "断开" : "邀请",
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      onTap: () => _onClickMemberAction(context, user, inChatting, type),
    );
  }

  bool _isMemberInChatting(User user) {
    for (User _user in _chattingMembers) {
      if (_user.id == user.id) {
        return true;
      }
    }
    return false;
  }

  void _onClickMemberAction(BuildContext context, User user, bool inChatting, LiveType type) {
    _onCloseMemberList(context);
    if (inChatting) {
      _kickMember(context, user, type);
    } else {
      _inviteMember(context, user, type);
    }
  }

  void _kickMember(BuildContext context, User user, LiveType type) {
    // TODO 断开
  }

  void _inviteMember(BuildContext context, User user, LiveType type) {
    int max = type == LiveType.single ? 1 : 6;
    if (_chattingMembers.length >= max) {
      Toast.show(context, "已达最大邀请用户上限。");
      return;
    }
    presenter?.inviteMember(user, type);
  }

  Future<bool> _buildConfirmExit(BuildContext context) {
    showDialog(
        context: context,
        child: AlertDialog(
          content: Text(
            "确定退出吗？",
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("取消")),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _exit(context);
                },
                child: Text("确定")),
          ],
        ));
    return Future.value(false);
  }

  void _exit(BuildContext context) {
    Loading.show(context);
    presenter.exit(context);
  }

  Widget _buildPermissionGuild(BuildContext context) {
    if (_showPermissionGuide)
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: ColorConfig.blackAlpha66,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCameraPermissionGuild(context),
                Container(
                  height: 30.0,
                ),
                _buildMicPermissionGuild(context),
              ],
            ),
          ),
        ),
      );
    return Container();
  }

  Widget _buildCameraPermissionGuild(BuildContext context) {
    if (_hasCameraPermission)
      return Text(
        "已有摄像机权限",
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    return GestureDetector(
      onTap: () => presenter.requestCameraPermission(),
      child: Text(
        "允许使用摄像机",
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildMicPermissionGuild(BuildContext context) {
    if (_hasMicPermission)
      return Text(
        "已有麦克风权限",
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    return GestureDetector(
      onTap: () => presenter.requestMicPermission(),
      child: Text(
        "允许使用麦克风",
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  @override
  Presenter createPresenter() {
    return LiveHostPagePresenter();
  }

  @override
  void onPermissionGranted() {
    setState(() {
      _showPermissionGuide = false;
      presenter.initVideoView();
    });
  }

  @override
  void onPermissionDenied(bool camera, bool mic) {
    setState(() {
      _showPermissionGuide = true;
      _hasCameraPermission = camera;
      _hasMicPermission = mic;
    });
  }

  @override
  void onCameraPermissionGranted() {
    setState(() {
      if (_hasMicPermission) _showPermissionGuide = false;
      _hasCameraPermission = true;
      if (!_showPermissionGuide) presenter.initVideoView();
    });
  }

  @override
  void onCameraPermissionDenied() {
    setState(() {
      _hasCameraPermission = false;
    });
  }

  @override
  void onMicPermissionGranted() {
    setState(() {
      if (_hasCameraPermission) _showPermissionGuide = false;
      _hasMicPermission = true;
      if (!_showPermissionGuide) presenter.initVideoView();
    });
  }

  @override
  void onMicPermissionDenied() {
    setState(() {
      _hasMicPermission = false;
    });
  }

  @override
  void onVideoViewReady(RCRTCVideoView videoView) {
    setState(() {
      _pushState = 1;
      _videoView = videoView;
    });
  }

  @override
  void onPushed() {
    setState(() {
      _pushState = 2;
    });
  }

  @override
  void onPushError(String info) {
    print("onPushError info = $info");
    setState(() {
      _pushState = 3;
    });
  }

  @override
  void onReceiveMember(User user) {
    if (_memberListSetter != null)
      _memberListSetter(() {
        _members.add(user);
      });
  }

  @override
  void onMemberInvited(User user, bool agree, LiveType type) {
    if (agree) {
      if (_memberListSetter != null) {
        _memberListSetter(() {
          _chattingMembers.add(user);
        });
      } else {
        _chattingMembers.add(user);
      }
      setState(() {
        _liveType = type;
      });
    }
  }

  @override
  void onCreateRemoteView(String uid, RCRTCVideoView videoView) {
    VideoView view = _getVideoViewByUserId(uid);
    if (view != null) {
      view.view = videoView;
      _remoteViews.remove(view);
    } else {
      User user = _getChattingUserById(uid) ?? User.unknown(uid);
      view = VideoView(user, videoView);
    }
    setState(() {
      _remoteViews.add(view);
    });
  }

  User _getChattingUserById(String id) {
    for (User user in _chattingMembers) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  @override
  void onReleaseRemoteView(String uid) {
    User user = _getChattingUserById(uid);
    VideoView view = _getVideoViewByUserId(uid);
    if (_memberListSetter != null) {
      _memberListSetter(() {
        if (user != null) _chattingMembers.remove(user);
      });
    } else {
      if (user != null) _chattingMembers.remove(user);
    }
    setState(() {
      if (view != null) _remoteViews.remove(view);
    });
  }

  VideoView _getVideoViewByUserId(String uid) {
    for (VideoView view in _remoteViews) {
      if (view.user.id == uid) {
        return view;
      }
    }
    return null;
  }

  @override
  void onExit(BuildContext context) {
    Loading.dismiss(context);
    _doExit();
  }

  void _doExit() {
    Navigator.pop(context);
  }

  @override
  void onExitWithError(BuildContext context, String info) {
    Toast.show(context, info);
    onExit(context);
  }

  @override
  void onReceiveMessage(Message message) {
    setState(() {
      _messages.add(message);
      Future.delayed(Duration(milliseconds: 50)).then((value) {
        _messageController.jumpTo(_messageController.position.maxScrollExtent);

        // _messageController.animateTo(
        //   _messageController.position.maxScrollExtent,
        //   duration: Duration(milliseconds: 100),
        //   curve: Curves.easeOut,
        // );
      });
    });
  }

  @override
  void onMicrophoneStatusChanged(bool state) {
    setState(() {
      if (state) {
        _microphoneIcon = FontAwesomeIcons.microphoneSlash;
      } else {
        _microphoneIcon = FontAwesomeIcons.microphone;
      }
    });
  }

  @override
  void onCameraStatusChanged(bool isFront) {
    // TODO: implement onCameraStatusChanged
  }

  @override
  void onCameraMirrorChanged(bool state) {
    // TODO: implement onCameraMirrorChanged
  }

  ScrollController _messageController = ScrollController();

  List<Message> _messages = List();

  bool _showPermissionGuide = false;
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  LiveType _liveType = LiveType.normal;

  bool _paused = false;

  RCRTCVideoView _videoView;
  int _pushState = 0;

  List<User> _members = List();
  StateSetter _memberListSetter;

  List<User> _chattingMembers = List();

  List<VideoView> _remoteViews = List();

  IconData _microphoneIcon = FontAwesomeIcons.microphone;
}
