import 'dart:async';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/alert.dart';
import 'package:FlutterRTC/widgets/bottom_audio_effect_mix_settings_sheet.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/status_panel.dart';
import 'package:flutter/material.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
import 'package:wakelock/wakelock.dart';

import '../audio_live_view.dart';
import 'audio_live_audience_contract.dart';
import 'audio_live_audience_presenter.dart';
import 'colors.dart';

class AudioLiveAudiencePage extends AbstractView {
  @override
  _AudioLiveAudiencePage createState() => _AudioLiveAudiencePage();
}

class _AudioLiveAudiencePage extends AbstractViewState<Presenter, AudioLiveAudiencePage> with WidgetsBindingObserver implements View, IRCRTCStatusReportListener {
  @override
  Presenter createPresenter() {
    return AudioLiveAudiencePresenter();
  }

  @override
  void init(BuildContext context) {
    super.init(context);

    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _room = Room.fromJSON(arguments);

    RCRTCEngine.getInstance().enableSpeaker(_config.speaker);

    _maxSubListHeight = MediaQuery.of(context).size.height - 64.dp - 104.dp;
    _maxSubListShown = ((_maxSubListHeight - 28.dp) / 140.dp).floor();

    _messageViewPadding = defaultMessageViewPadding.dp;

    Wakelock.enable();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (_mainViewSetter != null) _mainViewSetter = null;
    if (_statusPanelSetter != null) _statusPanelSetter = null;
    if (_messageSetter != null) _messageSetter = null;
    if (_bottomBarSetter != null) _bottomBarSetter = null;

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
      onWillPop: () => _dealPopAction(context),
    );
  }

  Widget _buildMainView(BuildContext context) {
    return StatefulBuilder(builder: (context, setter) {
      _mainViewSetter = setter;
      return Stack(
        children: [
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
                  _views.length > _maxSubListShown
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
                              '连麦人数 ${_views.length}',
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
                        itemCount: _views.length,
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 4.dp,
                            color: Colors.transparent,
                          );
                        },
                        itemBuilder: (context, index) {
                          return _views[index].widget;
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.dp,
        right: 12.dp,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Row(
        children: [
          _buildRoomInfo(context),
          Spacer(),
          'module_close'.png.image.toButton(
                onPressed: () => _dealPopAction(context),
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
            child: _room.user.avatar.fullImage,
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
                  _room.id,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  _room.user.name,
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
      child: StatefulBuilder(
        builder: (context, setter) {
          _bottomBarSetter = setter;
          return !_linking
              ? Row(
                  children: [
                    'link'.png.image.toButton(
                          onPressed: () => _requestLink(context),
                        ),
                    Spacer(),
                    'message'.png.image.toButton(
                          onPressed: () => _showInputMessageKeyboard(context),
                        ),
                  ],
                )
              : Row(
                  children: [
                    Spacer(),
                    'message'.png.image.toButton(
                          onPressed: () => _showInputMessageKeyboard(context),
                        ),
                    VerticalDivider(
                      width: 12.dp,
                    ),
                    'audio_effect'.png.image.toButton(
                          onPressed: () => BottomAudioEffectMixSettingsSheet.show(),
                        ),
                  ],
                );
        },
      ),
    );
  }

  void _requestLink(BuildContext context) {
    if (_requesting) return;
    _requesting = true;
    presenter?.requestLink();
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
        });
  }

  Future<bool> _dealPopAction(BuildContext context) {
    if (_linking)
      _showLeaveLinkAlert(context);
    else
      _exit(context);
    return Future.value(false);
  }

  Future<bool> _showLeaveLinkAlert(BuildContext context) {
    Alert.showAlert(
      title: '提示',
      message: '当前正在连麦，是否断开？',
      left: '取消',
      onPressedLeft: () {
        Navigator.pop(context);
      },
      right: '确定',
      onPressedRight: () {
        Navigator.pop(context);
        _leaveLink();
      },
    );
    return Future.value(false);
  }

  void _leaveLink() async {
    bool result = await presenter?.leaveLink();
    if (!result) '断开失败'.toast();
    presenter?.subscribe();
    _removeSubviews();
    _linking = !result;
    _inviting = false;
    _requesting = false;
    _leaving = false;

    RCRTCEngine.getInstance().unRegisterStatusReportListener();

    if (_bottomBarSetter != null) _bottomBarSetter(() {});
  }

  void _removeSubviews() {
    _views.removeWhere((view) => view.user.id != _room.user.id);
    if (_mainViewSetter != null) _mainViewSetter(() {});
  }

  void _exit(BuildContext context) {
    Loading.show(context);
    presenter.exit(context);
  }

  @override
  void onConnectionStats(StatusReport report) {
    _statusReport = report;

    _matchVoiceState();

    if (_statusPanelSetter != null) _statusPanelSetter(() {});
  }

  void _matchVoiceState() {
    if (_statusReport != null) {
      _views.forEach((view) {
        StatusBean bean;
        if (view.self)
          bean = _statusReport.statusAudioSends[view.stream.streamId];
        else
          bean = _statusReport.statusAudioRcvs[view.stream.streamId];
        view.speak = (bean?.audioOutputLevel?.toInt ?? 0) > 0;
      });
      if (_mainViewSetter != null) _mainViewSetter(() {});
    }
  }

  @override
  void onReceiveMessage(Message message) {
    _messages.add(message);
    _messageViewScrollToBottom();
  }

  @override
  void onReceiveInviteMessage() async {
    if (_inviting) return;
    _inviting = true;
    _showInviteAlert();
  }

  void _showInviteAlert() {
    Alert.showAlert(
      title: '提示',
      message: '主播邀请你连麦，是否加入？',
      left: '取消',
      onPressedLeft: () {
        Navigator.pop(context);
        _refuseInvite();
      },
      right: '加入',
      onPressedRight: () {
        Navigator.pop(context);
        _agreeInvite();
      },
    );
  }

  void _refuseInvite() {
    _inviting = false;
    presenter?.refuseInvite();
  }

  void _agreeInvite() {
    if (_linking) return;
    presenter?.agreeInvite(_config);
  }

  @override
  void onReceiveKickMessage() {
    if (_linking && !_leaving) {
      _leaving = true;
      '您已被主播强制断开连麦～'.toast(duration: Toast.LONG);
      _leaveLink();
    }
  }

  @override
  void onRequestLinkResult(bool agree) {
    if (agree) {
      '上麦成功'.toast(duration: Toast.LONG);
      _agreeInvite();
    } else {
      _requesting = false;
      '主播拒绝了你的连麦申请'.toast(duration: Toast.LONG);
    }
  }

  @override
  void onSubscribeUrlError(int code, String message) {
    // TODO 订阅失败
  }

  @override
  void onJoined() {
    _linking = true;

    RCRTCEngine.getInstance().registerStatusReportListener(this);

    if (_bottomBarSetter != null) _bottomBarSetter(() {});
  }

  @override
  void onJoinError() {
    '连麦失败'.toast();
    _inviting = false;
  }

  @override
  void onUserJoined(AudioStreamView view) {
    if (_room.user.id == view.user.id) return;

    _addSubView(view);
    _views.forEach((element) {
      element.invalidate();
    });

    if (_mainViewSetter != null) _mainViewSetter(() {});

    _updateMessageView();
  }

  void _addSubView(AudioStreamView view) {
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
    _views.forEach((view) {
      view.invalidate();
    });

    if (_mainViewSetter != null) _mainViewSetter(() {});

    _updateMessageView();
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
    AudioStreamView view = _getUserView(uid);
    if (view != null) {
      view.audioStream = stream;
      if (view.self) _config.mic = view.audio;
      if (_mainViewSetter != null) _mainViewSetter(() {});
    }
  }

  AudioStreamView _getUserView(String uid) {
    var views = _views.where((view) => view.user.id == uid);
    if (views.isNotEmpty) return views.first;
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
    info.toast();
    onExit(context);
  }

  Room _room;
  Config _config = Config.config();

  bool _inviting = false;
  bool _requesting = false;
  bool _linking = false;
  bool _leaving = false;

  List<AudioStreamView> _views = List();

  double _maxSubListHeight;
  int _maxSubListShown;

  double _messageViewPadding;
  final int defaultMessageViewPadding = 50;
  final int messageViewPaddingWithSubviews = 132;

  List<Message> _messages = List();

  StatusReport _statusReport;

  ScrollController _messageController = ScrollController();
  bool _inputMessageVisible = false;
  FocusNode _inputMessageFocusNode = FocusNode();
  TextEditingController _inputMessageController = TextEditingController();

  StateSetter _mainViewSetter;
  StateSetter _statusPanelSetter;
  StateSetter _messageSetter;
  StateSetter _bottomBarSetter;
}
