import 'dart:async';
import 'dart:ui';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/alert.dart';
import 'package:FlutterRTC/widgets/bottom_audio_effect_mix_settings_sheet.dart';
import 'package:FlutterRTC/widgets/bottom_mix_config_sheet.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/status_panel.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:intl/intl.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
import 'package:wakelock/wakelock.dart';

import 'colors.dart';
import 'live_host_page_contract.dart';
import 'live_host_page_presenter.dart';

class LiveHostPage extends AbstractView {
  @override
  _LiveHostPageState createState() => _LiveHostPageState();
}

class _LiveHostPageState extends AbstractViewState<Presenter, LiveHostPage> with WidgetsBindingObserver implements View, IRCRTCStatusReportListener {
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

    RCRTCEngine.getInstance().registerStatusReportListener(this);

    _maxSubListHeight = MediaQuery.of(context).size.height - 64.dp - 104.dp;
    _maxSubListShown = ((_maxSubListHeight - 28.dp) / 140.dp).floor();

    _messageViewPadding = defaultMessageViewPadding.dp;

    Wakelock.enable();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    RCRTCEngine.getInstance().unRegisterStatusReportListener();

    if (_timer != null) _timer.cancel();
    if (_mainViewSetter != null) _mainViewSetter = null;
    if (_audienceInfoSetter != null) _audienceInfoSetter = null;
    if (_liveTimeInfoSetter != null) _liveTimeInfoSetter = null;
    if (_audienceListSetter != null) _audienceListSetter = null;
    if (_messageSetter != null) _messageSetter = null;
    if (_statusPanelSetter != null) _statusPanelSetter = null;
    _signalStrengthSetters.clear();

    Wakelock.disable();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_inputMessageVisible && _inputMessageFocusNode.hasFocus) {
        _inputMessageVisible = false;
        Navigator.pop(context);
        return;
      } else {
        _inputMessageVisible = _inputMessageFocusNode.hasFocus;
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorConfig.backgroundColor,
        body: Stack(
          children: [
            _buildMainView(context),
            _buildTopBar(context),
            _buildBottomView(context),
          ],
        ),
      ),
      onWillPop: () => _showExitAlert(context),
    );
  }

  Widget _buildMainView(BuildContext context) {
    return StatefulBuilder(builder: (context, setter) {
      _mainViewSetter = setter;
      List<UserView> views = _viewsWithoutMain();
      return Stack(
        children: [
          _buildUserView(context, _mainView),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 112.dp,
              margin: EdgeInsets.only(
                right: 8.dp,
                bottom: 64.dp,
              ),
              constraints: BoxConstraints(
                maxHeight: _maxSubListHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  views.length > _maxSubListShown
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 8.dp),
                          child: Container(
                            height: 20.dp,
                            padding: EdgeInsets.symmetric(horizontal: 8.5.dp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.dp),
                              color: Colors.black.withOpacity(0.24),
                            ),
                            child: Text(
                              '连麦人数 ${views.length}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: views.length,
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 4.dp,
                            color: Colors.transparent,
                          );
                        },
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 112.dp,
                            height: 140.dp,
                            child: _buildUserView(context, views[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildUserView(BuildContext context, UserView view) {
    if (view == null)
      return Container(
        color: ColorConfig.viewBackgroundColor,
      );
    return Stack(
      children: [
        view.widget ??
            Container(
              color: ColorConfig.viewBackgroundColor,
              alignment: Alignment.center,
              child: SizedBox(
                width: 80.dp,
                height: 80.dp,
                child: view.user.avatar.fullImage,
              ),
            ),
        view.self
            ? Container()
            : Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.dp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        view.user.name,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      StatefulBuilder(builder: (context, setter) {
                        _signalStrengthSetters[view.user.id] = setter;
                        return 'signal_strength_level_${_getSignalStrength(view)}'.png.image;
                      }),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  List<UserView> _viewsWithoutMain() {
    if (_mainView == null) return _views;
    return _views.where((view) => view.user.id != _mainView.user.id).toList();
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.dp,
        right: 12.dp,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildRoomInfo(context),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 8.dp),
                child: _buildAudienceInfo(context),
              ),
              'module_close'.png.image.toButton(
                    onPressed: () => _showExitAlert(context),
                  ),
            ],
          ),
          Divider(
            height: 8.dp,
            color: Colors.transparent,
          ),
          Row(
            children: [
              _buildLiveTimeInfo(context),
              Spacer(),
              _buildLiveSignalStrength(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.dp),
        color: Colors.black.withOpacity(0.24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 36.dp,
            height: 36.dp,
            child: DefaultData.user.avatar.fullImage,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 5.dp,
              right: 12.dp,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RCRTCEngine.getInstance().getRoom().id,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  DefaultData.user.name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).toButton(
      onPressed: () => _showStatusPanel(context),
    );
  }

  Widget _buildAudienceInfo(BuildContext context) {
    return Container(
      height: 28.dp,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        left: 10.dp,
        right: 10.dp,
        bottom: 2.dp,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.dp),
        color: Colors.black.withOpacity(0.24),
      ),
      child: StatefulBuilder(
        builder: (context, setter) {
          _audienceInfoSetter = setter;
          return Text(
            '在线 ${_audiences.length}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showExitAlert(BuildContext context) {
    Alert.showAlert(
      title: '提示',
      message: '当前正在直播，是否退出直播？',
      left: '取消',
      onPressedLeft: () {
        Navigator.pop(context);
      },
      right: '确定',
      onPressedRight: () {
        Navigator.pop(context);
        _showLiveInfo(context);
      },
    );
    return Future.value(false);
  }

  void _showLiveInfo(BuildContext context) {
    Alert.showAlert(
      title: '直播结束啦！',
      message: '直播时长\n${_time ?? '00:00:00'}',
      left: '返回',
      onPressedLeft: () {
        Navigator.pop(context);
        _exit(context);
      },
    );
  }

  void _exit(BuildContext context) {
    Loading.show(context);
    presenter.exit(context);
  }

  Widget _buildLiveTimeInfo(BuildContext context) {
    return Container(
      height: 20.dp,
      padding: EdgeInsets.symmetric(horizontal: 8.dp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.dp),
        color: Colors.black.withOpacity(0.24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 5.dp,
            height: 5.dp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.5.dp),
              color: ColorConfig.live_time_info_red_dot_color,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 3.5.dp),
            child: StatefulBuilder(builder: (context, setter) {
              _liveTimeInfoSetter = setter;
              return Text(
                _time ?? '00:00:00',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSignalStrength(BuildContext context) {
    return StatefulBuilder(builder: (context, setter) {
      _signalStrengthSetters[_mainView.user.id] = setter;
      return 'signal_strength_level_${_getSignalStrength(_mainView)}'.png.image;
    });
  }

  int _getSignalStrength(UserView view) {
    if (_statusReport == null) return 0;
    String packetLostRate;
    if (view.self) {
      if (view.video && _statusReport.statusVideoSends.values.isNotEmpty)
        packetLostRate = _statusReport.statusVideoSends.values.first.packetLostRate;
      else if (view.audio && _statusReport.statusAudioSends.values.isNotEmpty)
        packetLostRate = _statusReport.statusAudioSends.values.first.packetLostRate;
      else
        packetLostRate = '0';
    } else {
      if (view.video)
        packetLostRate = _statusReport.statusVideoRcvs[view.videoStream.streamId]?.packetLostRate ?? '0';
      else if (view.audio)
        packetLostRate = _statusReport.statusAudioRcvs[view.audioStream.streamId]?.packetLostRate ?? '0';
      else
        packetLostRate = '0';
    }
    double strength = (packetLostRate ?? '100').toDouble;
    if (strength < 10)
      return 2;
    else if (strength < 50)
      return 1;
    else
      return 0;
  }

  void _showStatusPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setter) {
          _statusPanelSetter = setter;
          return WillPopScope(
              child: Dialog(
                backgroundColor: Colors.black12,
                insetPadding: EdgeInsets.only(
                  top: 50.dp,
                  bottom: 50.dp,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    child: StatusPanel(
                      report: _statusReport,
                    ),
                  ),
                  onTap: () {
                    _statusPanelSetter = null;
                    Navigator.pop(context);
                  },
                ),
              ),
              onWillPop: () {
                _statusPanelSetter = null;
                Navigator.pop(context);
                return Future.value(false);
              });
        });
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
    return StatefulBuilder(
      builder: (context, setter) {
        _messageSetter = setter;
        return Container(
          padding: EdgeInsets.only(
            left: 12.dp,
            bottom: 12.dp,
            right: _messageViewPadding,
          ),
          constraints: BoxConstraints(
            maxHeight: 238.dp,
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              shrinkWrap: true,
              controller: _messageController,
              itemCount: _messages.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 4.dp,
                  color: Colors.transparent,
                );
              },
              itemBuilder: (context, index) {
                return _buildMessage(context, _messages[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage(BuildContext context, Message message) {
    return Row(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.5.dp),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.dp,
                vertical: 3.dp,
              ),
              child: message.type == MessageType.normal
                  ? RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: '${message.user.name}${message.user.id == DefaultData.user.id ? '（我）' : ''}：',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: ColorConfig.message_user_color,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextSpan(
                            text: message.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      '${message.user.name} ${message.type == MessageType.join ? '进入了直播间' : '离开了直播间'}',
                      style: TextStyle(
                        color: ColorConfig.message_user_color,
                        fontSize: 14.sp,
                        decoration: TextDecoration.none,
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
        bottom: 12.dp,
        left: 12.dp,
        right: 12.dp,
      ),
      child: Row(
        children: [
          'pk'.png.image.toButton(
                onPressed: () => '敬请期待'.toast(),
              ),
          VerticalDivider(
            width: 12.dp,
          ),
          'link'.png.image.toButton(
                onPressed: () => _showAudienceList(context),
              ),
          Spacer(),
          'message'.png.image.toButton(
                onPressed: () => _showInputMessageKeyboard(context),
              ),
          VerticalDivider(
            width: 12.dp,
          ),
          'live_switch_camera'.png.image.toButton(
                onPressed: () => _switchCamera(),
              ),
          VerticalDivider(
            width: 12.dp,
          ),
          'audio_effect'.png.image.toButton(
                onPressed: () => BottomAudioEffectMixSettingsSheet.show(),
              ),
          VerticalDivider(
            width: 12.dp,
          ),
          'live_mix_config'.png.image.toButton(
                onPressed: () => _changeMixConfig(context),
              ),
        ],
      ),
    );
  }

  void _showAudienceList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: ColorConfig.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setter) {
          _audienceListSetter = setter;
          return WillPopScope(
            child: Container(
              padding: EdgeInsets.all(20.dp),
              constraints: BoxConstraints(
                maxHeight: 397.dp,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '邀请连麦',
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: 'pop_page_close'.png.image.toButton(
                              onPressed: () => _closeAudienceList(context),
                            ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20.dp,
                    color: Colors.transparent,
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _audiences.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 20.dp,
                          color: Colors.transparent,
                        );
                      },
                      itemBuilder: (context, index) {
                        return _buildAudience(context, _audiences[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            onWillPop: () {
              _closeAudienceList(context);
              return Future.value(false);
            },
          );
        });
      },
    );
  }

  void _closeAudienceList(BuildContext context) {
    Navigator.pop(context);
    _audienceListSetter = null;
  }

  Widget _buildAudience(BuildContext context, User user) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: 48.dp,
              height: 48.dp,
              child: user.avatar.fullImage,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 12.dp,
            ),
            child: Text(
              user.name,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
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
          borderRadius: BorderRadius.circular(2.dp),
          color: ColorConfig.audienceListActionButtonBackgroundColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.dp,
            vertical: 5.dp,
          ),
          child: Text(
            inChatting ? "断开" : "邀请",
            style: TextStyle(
              fontSize: 13.sp,
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
    for (User _user in _invitedAudiences) if (_user.id == user.id) return true;
    return false;
  }

  void _onClickMemberAction(BuildContext context, User user, bool inChatting) {
    _closeAudienceList(context);
    if (inChatting) {
      _kickMember(context, user);
    } else {
      _inviteMember(context, user);
    }
  }

  void _kickMember(BuildContext context, User user) {
    presenter?.kickMember(user);
  }

  void _inviteMember(BuildContext context, User user) {
    presenter?.inviteMember(user);
  }

  void _showInputMessageKeyboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WillPopScope(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              color: Colors.transparent,
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50.dp,
                color: Colors.white,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.dp),
                child: TextField(
                  autofocus: true,
                  focusNode: _inputMessageFocusNode,
                  controller: _inputMessageController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  maxLines: 1,
                  maxLength: 32,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: "说点什么...",
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: ColorConfig.input_message_hint_color,
                    ),
                  ),
                  onEditingComplete: () {
                    String message = _inputMessageController.text;
                    _inputMessageController.text = '';
                    presenter?.sendMessage(message);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          onWillPop: () {
            Navigator.pop(context);
            return Future.value(false);
          },
        );
      },
    );
  }

  void _switchCamera() async {
    _config.frontCamera = await presenter?.switchCamera();
    UserView view = _getSelfView();
    view?.mirror = _config.frontCamera;
    _mainViewSetter(() {});
  }

  UserView _getSelfView() {
    var views = _views.where((view) => view.self);
    if (views.isNotEmpty) return views.first;
    return null;
  }

  void _changeMixConfig(BuildContext context) {
    BottomMixConfigSheet.show(
      context,
      selected: (config) {
        presenter?.changeMixConfig(config);
      },
    );
  }

  @override
  void onConnectionStats(StatusReport report) {
    _statusReport = report;

    _signalStrengthSetters.values.forEach((setter) {
      setter(() {});
    });
    if (_statusPanelSetter != null) _statusPanelSetter(() {});
  }

  @override
  void onPublished() {
    if (_timer != null) _timer.cancel();

    _timeCount = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeCount++;
      _time = _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(
        _timeCount * 1000,
        isUtc: true,
      ));
      if (_liveTimeInfoSetter != null) _liveTimeInfoSetter(() {});
    });
  }

  @override
  void onPublishError(String info) {
    // TODO: implement onPublishError
  }

  @override
  void onReceiveMessage(Message message) {
    _messages.add(message);
    _messageViewScrollToBottom();
  }

  @override
  void onAudienceJoined(User user) {
    _audiences.removeWhere((element) => element.id == user.id);
    _audiences.add(user);
    if (_audienceInfoSetter != null) _audienceInfoSetter(() {});
    if (_audienceListSetter != null) _audienceListSetter(() {});
  }

  @override
  void onAudienceLeft(User user) {
    _audiences.removeWhere((element) => element.id == user.id);
    if (_audienceInfoSetter != null) _audienceInfoSetter(() {});
    if (_audienceListSetter != null) _audienceListSetter(() {});
  }

  @override
  void onMemberInvited(User user, bool agree) {
    if (!agree) return;
    _invitedAudiences.add(user);
    if (_audienceListSetter != null) _audienceListSetter(() {});
  }

  @override
  void onUserJoined(UserView view) {
    if (view.self) {
      view.mirror = _config.frontCamera;
      _mainView = view;
    } else {
      view.user.name = view.user.name = _getAudienceName(view.user.id) ?? _getAudienceNameDeep(view.user.id) ?? view.user.name;
    }
    _addSubView(view);
    _views.forEach((element) {
      element.invalidate();
    });

    if (_mainViewSetter != null) _mainViewSetter(() {});
    if (_audienceListSetter != null) _audienceListSetter(() {});

    _updateMessageView();
  }

  String _getAudienceName(String uid) {
    var users = _invitedAudiences.where((user) => user.id == uid);
    if (users.isNotEmpty) return users.first.name;
    return null;
  }

  String _getAudienceNameDeep(String uid) {
    var users = _audiences.where((user) => user.id == uid);
    if (users.isNotEmpty) return users.first.name;
    return null;
  }

  void _addSubView(UserView view) {
    _views.removeWhere((element) {
      return element.user.id == view.user.id;
    });
    _views.add(view);
  }

  @override
  void onUserLeaved(String uid) {
    _views.removeWhere((view) {
      return view.user.id == uid;
    });
    if (_mainView.user.id == uid) _mainView = _views.isNotEmpty ? _views.first : null;
    _views.forEach((view) {
      view.invalidate();
    });

    if (_mainViewSetter != null) _mainViewSetter(() {});
    if (_audienceListSetter != null) _audienceListSetter(() {});

    _updateMessageView();

    _invitedAudiences.removeWhere((user) => user.id == uid);
  }

  void _updateMessageView() {
    if (_messageViewPadding == null) _messageViewPadding = defaultMessageViewPadding.dp;

    if (_views.length > 1 && _messageViewPadding < messageViewPaddingWithSubviews.dp) {
      _messageViewPadding = messageViewPaddingWithSubviews.dp;
      _messageViewScrollToBottom();
    } else if (_views.length < 2 && _messageViewPadding > defaultMessageViewPadding.dp) {
      _messageViewPadding = defaultMessageViewPadding.dp;
      _messageViewScrollToBottom();
    }
  }

  void _messageViewScrollToBottom() {
    if (_messageSetter != null)
      _messageSetter(() {
        Future.delayed(Duration(milliseconds: 50)).then((value) {
          _messageController.animateTo(
            _messageController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      });
  }

  @override
  void onUserAudioStreamChanged(String uid, stream) {
    UserView view = _getUserView(uid);
    view.audioStream = stream;
    if (view.self) _config.mic = view.audio;
    if (_mainViewSetter != null) _mainViewSetter(() {});
  }

  @override
  void onUserVideoStreamChanged(String uid, stream) {
    UserView view = _getUserView(uid);
    view.videoStream = stream;
    if (view.self) _config.camera = view.video;
    if (_mainViewSetter != null) _mainViewSetter(() {});
  }

  UserView _getUserView(String uid) {
    var views = _views.where((view) => view.user.id == uid);
    if (views.isNotEmpty) return views.first;
    return null;
  }

  @override
  void onExit(BuildContext context) {
    Loading.dismiss(context);
    _doExit();
  }

  @override
  void onExitWithError(BuildContext context, String info) {
    info.toast();
    onExit(context);
  }

  void _doExit() {
    Navigator.pop(context);
  }

  Config _config;

  Timer _timer;
  int _timeCount = 0;
  String _time;
  DateFormat _timeFormat = DateFormat('HH:mm:ss');

  UserView _mainView;
  List<UserView> _views = List();

  double _maxSubListHeight;
  int _maxSubListShown;

  double _messageViewPadding;
  final int defaultMessageViewPadding = 50;
  final int messageViewPaddingWithSubviews = 132;

  List<Message> _messages = List();

  List<User> _audiences = List();
  List<User> _invitedAudiences = List();

  StatusReport _statusReport;

  ScrollController _messageController = ScrollController();
  bool _inputMessageVisible = false;
  FocusNode _inputMessageFocusNode = FocusNode();
  TextEditingController _inputMessageController = TextEditingController();

  StateSetter _mainViewSetter;
  StateSetter _audienceInfoSetter;
  StateSetter _liveTimeInfoSetter;
  StateSetter _messageSetter;
  StateSetter _audienceListSetter;
  StateSetter _statusPanelSetter;
  Map<String, StateSetter> _signalStrengthSetters = Map();
}
