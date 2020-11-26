import 'dart:async';
import 'dart:ui';

import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/status_panel.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../colors.dart';
import 'live_host_page_contract.dart';
import 'live_host_page_presenter.dart';

class LiveHostPage extends AbstractView {
  @override
  _LiveHostPageState createState() => _LiveHostPageState();
}

class _LiveHostPageState extends AbstractViewState<Presenter, LiveHostPage> with WidgetsBindingObserver implements View {
  @override
  Presenter createPresenter() {
    return LiveHostPagePresenter();
  }

  @override
  void init(BuildContext context) {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _config = Config.fromJSON(arguments);
    presenter?.publish(_config);
    RCRTCEngine.getInstance().enableSpeaker(_config.speaker);
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
            _buildBottomView(context),
          ],
        ),
      ),
      onWillPop: () => _showConfirmExit(context),
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
      child: Row(
        children: [
          GestureDetector(
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
          Spacer(),
          GestureDetector(
            onTap: () => _exit(context),
            child: Icon(
              Icons.power_settings_new,
              color: Colors.white,
              size: 30.0.width,
            ),
          )
        ],
      ),
    );
  }

  String _generateRoomInfo() {
    String time = _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(_timeCount * 1000));
    return "直播中:($time)";
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

  Widget _buildBottomView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildMessageView(context),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildMessageView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 5.0.height,
        left: 15.0.width,
        right: 15.0.width,
      ),
      constraints: BoxConstraints(
        maxHeight: 200.height,
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
    );
  }

  Widget _buildMessage(BuildContext context, Message message) {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 10.0.height,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0.width),
                color: ColorConfig.blackAlpha33,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.0.width,
                  right: 10.0.width,
                  top: 5.0.width,
                  bottom: 5.0.width,
                ),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${message.user.name}:',
                        style: TextStyle(
                          fontSize: 13.0.sp,
                          color: Colors.lightBlueAccent,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      TextSpan(
                        text: message.message,
                        style: TextStyle(
                          fontSize: 13.0.sp,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 5.0.height,
        left: 15.0.width,
        right: 15.0.width,
      ),
      child: Row(
        children: [
          GestureDetector(
            child: FontAwesomeIcons.user.black54,
            onTap: () => _showMemberList(context),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmExit(BuildContext context) {
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

  void _showMemberList(BuildContext context) {
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
                          child: Icon(Icons.close),
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
                          return _buildMember(context, _members[index]);
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

  Widget _buildMember(BuildContext context, User user) {
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
          _buildMemberActionButton(context, user),
        ],
      ),
    );
  }

  Widget _buildMemberActionButton(BuildContext context, User user) {
    bool inChatting = _isMemberInvited(user);
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
      onTap: () => _onClickMemberAction(context, user, inChatting),
    );
  }

  bool _isMemberInvited(User user) {
    for (User _user in _invitedMembers) if (_user.id == user.id) return true;
    return false;
  }

  void _onClickMemberAction(BuildContext context, User user, bool inChatting) {
    _onCloseMemberList(context);
    if (inChatting) {
      _kickMember(context, user);
    } else {
      _inviteMember(context, user);
    }
  }

  void _kickMember(BuildContext context, User user) {
    // TODO 断开
  }

  void _inviteMember(BuildContext context, User user) {
    presenter?.inviteMember(user);
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
  void onReceiveMember(User user) {
    if (_memberListSetter != null)
      _memberListSetter(() {
        _members.add(user);
      });
  }

  @override
  void onMemberInvited(User user, bool agree) {
    if (!agree) return;
    _invitedMembers.add(user);
    if (_memberListSetter != null) _memberListSetter(() {});
  }

  @override
  void onMemberJoined(String userId) {
    // TODO: implement onMemberJoined
  }

  @override
  void onExit(BuildContext context) {
    Loading.dismiss(context);
    _doExit();
  }

  @override
  void onExitWithError(BuildContext context, String info) {
    Toast.show(context, info);
    onExit(context);
  }

  void _doExit() {
    Navigator.pop(context);
  }

  Config _config;

  VideoStreamWidget _mainView;
  List<VideoStreamWidget> _views = List();

  Timer _timer;
  int _timeCount = 0;
  DateFormat _timeFormat = DateFormat('mm:ss');

  List<Message> _messages = List();
  ScrollController _messageController = ScrollController();

  List<User> _members = List();
  StateSetter _memberListSetter;

  List<User> _invitedMembers = List();

  int _quattroCount = 0;
  int _noveCount = 0;
}
