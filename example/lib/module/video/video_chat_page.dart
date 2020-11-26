import 'dart:async';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/module/video/video_chat_page_contract.dart';
import 'package:FlutterRTC/module/video/video_chat_page_presenter.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/status_panel.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class VideoChatPage extends AbstractView {
  @override
  _VideoChatPageState createState() => _VideoChatPageState();
}

class _VideoChatPageState extends AbstractViewState<Presenter, VideoChatPage> with WidgetsBindingObserver implements View {
  @override
  Presenter createPresenter() {
    return VideoChatPagePresenter();
  }

  @override
  void init(BuildContext context) {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _config = Config.fromJSON(arguments);
    presenter?.publish(_config);
    RCRTCEngine.getInstance().enableSpeaker(_config.speaker);

    Size size = MediaQuery.of(context).size;

    double quattroWidth = size.width / 2;
    _quattroCount = (size.height / quattroWidth).floor() * 2;

    double noveWidth = size.width / 3;
    _noveCount = (size.height / noveWidth).floor() * 3;
  }

  @override
  Size designSize() {
    return const Size(375, 667);
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: [
            _buildMainView(context),
            _buildTopBar(context),
            _buildBottomDrawer(context),
          ],
        ),
      ),
      onWillPop: () => _exit(context),
    );
  }

  Widget _buildMainView(BuildContext context) {
    int count = _views.length;
    if (count < 3) {
      return _buildSingleMeeting(context);
    } else if (count <= _quattroCount) {
      return _buildQuattroMeeting(context);
    } else if (count <= _noveCount) {
      return _buildNoveMeeting(context);
    } else {
      return _buildMultiMeeting(context);
    }
  }

  Widget _buildSingleMeeting(BuildContext context) {
    var views = viewsWithOutMain();
    return Stack(
      alignment: Alignment.topRight,
      children: [
        _mainView?.widget ?? Container(),
        views.isNotEmpty
            ? GestureDetector(
                child: Container(
                  width: 90.0.width,
                  height: 160.0.height,
                  padding: EdgeInsets.only(
                    top: 60.0.height,
                    right: 15.0.width,
                  ),
                  child: views.first.widget,
                ),
                onTap: () => _switchMainView(views.first),
              )
            : Container(),
      ],
    );
  }

  void _switchMainView(VideoStreamWidget view) {
    _mainView.invalidate();
    view.invalidate();
    _mainView = view;
    setState(() {});
  }

  List<VideoStreamWidget> viewsWithOutMain() {
    if (_mainView == null) return _views;
    return _views.where((view) => view.user.id != _mainView.user.id).toList();
  }

  Widget _buildQuattroMeeting(BuildContext context) {
    return Container(
      color: Colors.black,
      child: GridView.count(
        crossAxisSpacing: 10.0.width,
        mainAxisSpacing: 10.0.width,
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        children: _buildViews(context),
      ),
    );
  }

  Widget _buildNoveMeeting(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(10.0.width),
      child: GridView.count(
        crossAxisSpacing: 10.0.width,
        mainAxisSpacing: 10.0.width,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        children: _buildViews(context),
      ),
    );
  }

  List<Widget> _buildViews(BuildContext context) {
    List<Widget> widgets = List();
    _views.forEach((view) {
      widgets.add(view.widget);
    });
    return widgets;
  }

  Widget _buildMultiMeeting(BuildContext context) {
    return Container(
      color: Colors.black,
      child: PageView.builder(
        itemCount: (_views.length / _noveCount).ceil(),
        itemBuilder: (context, index) {
          return _buildMultiMeetingPage(context, index);
        },
      ),
    );
  }

  Widget _buildMultiMeetingPage(BuildContext context, int index) {
    int start = index * _noveCount;
    int end = index * _noveCount + _noveCount;
    if (end > _views.length) end = _views.length;
    List<VideoStreamWidget> views = _views.sublist(start, end);
    List<Widget> widgets = List();
    views.forEach((view) {
      widgets.add(view.widget);
    });
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(10.0.width),
      child: GridView.count(
        crossAxisSpacing: 10.0.width,
        mainAxisSpacing: 10.0.width,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        children: widgets,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 15.0.width,
        right: 15.0.width,
        top: 28.0.height,
      ),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              child: Text(
                _generateRoomInfo(),
                style: TextStyle(
                  fontSize: 15.0.sp,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              onTap: () => _showStatusPanel(context),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => _switchCamera(),
              child: Icon(
                Icons.flip_camera_ios_outlined,
                color: Colors.white,
                size: 30.0.width,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black12,
          insetPadding: EdgeInsets.only(
            top: 45.0.height,
            bottom: 100.0.height,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              child: StatusPanel(),
            ),
            onTap: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  void _switchCamera() async {
    _config.frontCamera = await presenter?.switchCamera();
    VideoStreamWidget view = getUserView();
    view?.mirror = _config.frontCamera;
    setState(() {});
  }

  VideoStreamWidget getUserView() {
    String id = RCRTCEngine.getInstance().getRoom().localUser.id;
    var views = _views.where((view) => view.user.id == id);
    if (views.isNotEmpty) return views.first;
    return null;
  }

  String _generateRoomInfo() {
    String id = RCRTCEngine.getInstance().getRoom()?.id ?? "";
    id = id.replaceAllMapped(RegExp(r'(.{3})'), (match) => '${match[0]} ');
    String time = _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(_timeCount * 1000));
    return "会议ID: $id ($time)";
  }

  Widget _buildBottomDrawer(BuildContext context) {
    return BottomDrawer(
      header: _buildBottomDrawerHead(context),
      body: _buildBottomDrawerBody(context),
      headerHeight: 90.0.height,
      drawerHeight: 180.0.height,
      cornerRadius: 30.0.width,
      color: Colors.black,
    );
  }

  Widget _buildBottomDrawerHead(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: 10.0.height,
        left: 25.0.width,
        right: 25.0.width,
      ),
      child: Column(
        children: [
          Container(
            width: 40.0.width,
            height: 4.0.height,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(2.0.height)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0.height,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _config.mic ? FontAwesomeIcons.microphoneSlash.selected : FontAwesomeIcons.microphone.unselected,
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6.0.height,
                        bottom: 10.0.height,
                      ),
                      child: Text(
                        "音频流",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _changeAudioStreamState(),
              ),
              Spacer(),
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _config.speaker ? Icons.volume_off.selected : Icons.volume_up.unselected,
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6.0.height,
                        bottom: 10.0.height,
                      ),
                      child: Text(
                        "扬声器",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _changeSpeakerState(),
              ),
              Spacer(),
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icons.call_end.red,
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6.0.height,
                        bottom: 10.0.height,
                      ),
                      child: Text(
                        "挂断",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _exit(context),
              ),
              Spacer(),
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _config.camera ? FontAwesomeIcons.videoSlash.selected : FontAwesomeIcons.video.unselected,
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6.0.height,
                        bottom: 10.0.height,
                      ),
                      child: Text(
                        "视频流",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _changeVideoStreamState(),
              ),
              Spacer(),
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FontAwesomeIcons.user.withBadge(_getRemoteUserCountBadge()),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6.0.height,
                        bottom: 10.0.height,
                      ),
                      child: Text(
                        "成员管理",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _showRemoteUserList(context),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0.height,
            ),
          ),
          Divider(
            height: 1.0.height,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _changeAudioStreamState() async {
    _config.mic = await presenter?.changeAudioStreamState(_config);
    setState(() {});
  }

  void _changeSpeakerState() async {
    _config.speaker = !_config.speaker;
    await RCRTCEngine.getInstance().enableSpeaker(_config.speaker);
    setState(() {});
  }

  void _changeVideoStreamState() async {
    _config.camera = await presenter?.changeVideoStreamState(_config);
    setState(() {});
  }

  String _getRemoteUserCountBadge() {
    int count = presenter?.getUserList()?.length ?? 0;
    if (count < 1) return null;
    if (count > 99) return '...';
    return '$count';
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
          return Container(
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
                                  await presenter.changeRemoteVideoStreamState(userList[index]);
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
          );
        });
      },
    );
  }

  Widget _buildBottomDrawerBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 45.0.width,
          right: 45.0.width,
          top: 20.0.height,
          bottom: 20.0.height,
        ),
        child: Column(
          children: [
            GestureDetector(
              child: _unsubscribeRemoteAudio ? "全员解除静音".button : "全员静音".button,
              onTap: () => _changeRemoteAudioSubscribeState(),
            ),
            // "全员静音".button,
            // "全员静音".button,
            // "全员静音".button,
            // "全员静音".button,
            // "全员静音".button,
            // "全员静音".button,
            // "全员静音".button,
            // "全员静音".button,
          ],
        ),
      ),
    );
  }

  void _changeRemoteAudioSubscribeState() {
    _unsubscribeRemoteAudio = !_unsubscribeRemoteAudio;
    presenter?.changeRemoteAudioSubscribeState(_unsubscribeRemoteAudio);
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

  void invalidate() {
    setState(() {});
  }

  @override
  void onViewCreated(VideoStreamWidget view) {
    String uid = RCRTCEngine.getInstance().getRoom().localUser.id;
    if (uid == view.user.id) {
      view.mirror = _config.frontCamera;
      _mainView = view;
    }
    _addSubView(view);
    _views.forEach((element) {
      element.invalidate();
    });
    setState(() {});
  }

  void _addSubView(VideoStreamWidget view) {
    _views.removeWhere((element) {
      return element.user.id == view.user.id;
    });
    _views.add(view);
  }

  @override
  void onPublished() {
    if (_timer != null) _timer.cancel();

    _timeCount = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeCount++;
      });
    });
  }

  @override
  void onPublishError(String info) {
    // TODO: implement onPublishError
  }

  @override
  void onRemoveView(String userId) {
    _views.removeWhere((view) {
      return view.user.id == userId;
    });
    if (_mainView.user.id == userId) _mainView = _views.isNotEmpty ? _views.first : null;
    _views.forEach((element) {
      element.invalidate();
    });
    setState(() {});
  }

  Config _config;

  Timer _timer;
  int _timeCount = 0;
  DateFormat _timeFormat = DateFormat('mm:ss');

  VideoStreamWidget _mainView;
  List<VideoStreamWidget> _views = List();

  int _quattroCount = 0;
  int _noveCount = 0;

  bool _unsubscribeRemoteAudio = false;
}
