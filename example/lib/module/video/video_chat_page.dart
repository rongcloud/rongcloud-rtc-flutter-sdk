import 'dart:ui';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/module/video/video_chat_page_presenter.dart';
import 'package:FlutterRTC/widgets/video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../colors.dart';

class VideoChatPage extends AbstractView {
  @override
  _VideoChatPageState createState() => _VideoChatPageState();
}

class _VideoChatPageState extends AbstractViewState<Presenter, VideoChatPage> with WidgetsBindingObserver implements View {
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
  Presenter createPresenter() {
    return VideoChatPagePresenter();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Card(
        child: Stack(
          children: [
            _buildMainView(context),
            _buildTopBar(context),
            _buildBottomViews(context),
            _buildPermissionGuild(context),
          ],
        ),
      ),
      onWillPop: () => _exit(context),
    );
  }

  Widget _buildMainView(BuildContext context) {
    return Container(
      child: _mainView?.view ?? Container(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 30.0,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 15.0,
            ),
            child: GestureDetector(
              onTap: () => presenter?.switchCamera(),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Icon(
                  FontAwesomeIcons.camera,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              left: 15.0,
            ),
            child: GestureDetector(
              onTap: () => _exit(context),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Image.asset("assets/images/close.png"),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomViews(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubViews(context),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildSubViews(BuildContext context) {
    return Container(
      child: GridView.count(
        shrinkWrap: true,
        reverse: true,
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
        children: _buildSubView(context),
      ),
    );
  }

  List<Widget> _buildSubView(BuildContext context) {
    List<Widget> widgets = List();
    _views.forEach((view) {
      widgets.add(Container(
        color: Colors.yellow,
        alignment: Alignment.center,
        child: view.view,
      ));
    });
    return widgets;
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 15.0,
            ),
            child: GestureDetector(
              onTap: () => _changeAudioStreamState(),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Icon(
                  _audioStreamStateIcon,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 15.0,
            ),
            child: GestureDetector(
              onTap: () => _changeVideoStreamState(),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Icon(
                  _videoStreamStateIcon,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 15.0,
            ),
            child: GestureDetector(
              onTap: () => _showVideoStreamLevelList(context),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Icon(
                  FontAwesomeIcons.sort,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              left: 15.0,
            ),
            child: GestureDetector(
              onTap: () => _showRemoteUserList(context),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Icon(
                  FontAwesomeIcons.user,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _changeAudioStreamState() async {
    bool closed = await presenter?.changeAudioStreamState();
    setState(() {
      _audioStreamStateIcon = closed ? FontAwesomeIcons.microphoneSlash : FontAwesomeIcons.microphone;
    });
  }

  void _changeVideoStreamState() async {
    bool closed = await presenter?.changeVideoStreamState();
    setState(() {
      _videoStreamStateIcon = closed ? FontAwesomeIcons.videoSlash : FontAwesomeIcons.video;
    });
  }

  void _showVideoStreamLevelList(BuildContext context) {
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
                          "选择分辨率",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Icon(FontAwesomeIcons.solidWindowClose),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      // shrinkWrap: true,
                      itemCount: videoStreamLevelList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 15.0,
                              ),
                              child: SizedBox(
                                width: 300.0,
                                height: 60.0,
                                child: TextButton(
                                  child: Text(
                                    videoStreamLevelList[index],
                                  ),
                                  onPressed: () {
                                    presenter.changeVideoResolution(videoStreamLevelList[index]);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            onWillPop: () {
              Navigator.pop(context);
              return Future.value(false);
            },
          );
        });
      },
    );
  }

  void _showRemoteUserList(BuildContext context) async {
    List<RemoteUserStatus> userList = presenter.getUserList();
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
                          "远端用户",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Icon(FontAwesomeIcons.solidWindowClose),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      // shrinkWrap: true,
                      itemCount: userList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            child: Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: Text(
                                  userList[index].user.id,
                                  style: TextStyle(
                                    color: Colors.green,
                                    // fontSize: 10.0,
                                  ),
                                )),
                            Spacer(),
                            Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: IconButton(
                                  // iconSize: 15,
                                  icon: Icon(
                                    userList[index].audioStatus ? FontAwesomeIcons.microphone : FontAwesomeIcons.microphoneSlash,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    presenter.changeRemoteAudioStreamState(userList[index]);
                                    setter(() {});
                                  },
                                )),
                            Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: IconButton(
                                  // iconSize: 15,
                                  icon: Icon(
                                    userList[index].videoStatus ? FontAwesomeIcons.video : FontAwesomeIcons.videoSlash,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () async {
                                    bool state = await presenter.changeRemoteVideoStreamState(userList[index]);
                                    setter(() {});
                                  },
                                ))
                          ],
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            onWillPop: () {
              Navigator.pop(context);
              return Future.value(false);
            },
          );
        });
      },
    );
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
    if (_permissionStatus != PermissionStatus.camera_denied && _permissionStatus != PermissionStatus.both_denied)
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
    if (_permissionStatus != PermissionStatus.mic_denied && _permissionStatus != PermissionStatus.both_denied)
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

  Future<bool> _exit(BuildContext context) async {
    Loading.show(context);
    StatusCode code = await presenter.exit();
    if (code.status != Status.ok) {
      Toast.show(context, "exit with error, ${code.message}");
    }
    Loading.dismiss(context);
    _doExit();
    return Future.value(false);
  }

  void _doExit() {
    Navigator.pop(context);
  }

  @override
  void onPermissionStatus(PermissionStatus status) {
    setState(() {
      _permissionStatus = status;
      _showPermissionGuide = _permissionStatus != PermissionStatus.granted;
      if (!_showPermissionGuide) presenter?.createVideoView();
    });
  }

  @override
  void onVideoViewCreated(VideoView view) {
    String uid = RCRTCEngine.getInstance().getRoom().localUser.id;
    setState(() {
      if (uid == view.user.id)
        _mainView = view;
      else
        _addSubView(view);
    });
  }

  void _addSubView(VideoView view) {
    _views.removeWhere((element) {
      return element.user.id == view.user.id;
    });
    _views.add(view);
  }

  @override
  void onPushed() {
    // TODO: implement onPushed
  }

  @override
  void onPushError(String info) {
    // TODO: implement onPushError
  }

  @override
  void onRemoveVideoView(String userId) {
    setState(() {
      _views.removeWhere((view) {
        return view.user.id == userId;
      });
      if (_mainView.user.id == userId) _mainView = null;
    });
  }

  bool _paused = false;

  bool _showPermissionGuide = true;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  VideoView _mainView;
  List<VideoView> _views = List();

  IconData _audioStreamStateIcon = FontAwesomeIcons.microphone;

  IconData _videoStreamStateIcon = FontAwesomeIcons.video;
}
