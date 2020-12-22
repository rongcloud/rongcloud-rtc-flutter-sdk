import 'dart:async';

import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/alert.dart';
import 'package:FlutterRTC/widgets/bottom_audio_effect_mix_settings_sheet.dart';
import 'package:FlutterRTC/widgets/bottom_audio_video_settings_sheet.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/status_panel.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:intl/intl.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
import 'package:wakelock/wakelock.dart';

import 'colors.dart';
import 'meeting_page_contract.dart';
import 'meeting_page_presenter.dart';

class MeetingPage extends AbstractView {
  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends AbstractViewState<Presenter, MeetingPage> with WidgetsBindingObserver implements View, IRCRTCStatusReportListener, BottomAudioVideoSettingsSheetCallback {
  @override
  Presenter createPresenter() {
    return MeetingPagePresenter();
  }

  @override
  void init(BuildContext context) {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _config = Config.fromJSON(arguments);
    presenter?.publish(_config);
    RCRTCEngine.getInstance().enableSpeaker(_config.speaker);

    RCRTCEngine.getInstance().registerStatusReportListener(this);

    Wakelock.enable();
  }

  @override
  void dispose() {
    RCRTCEngine.getInstance().unRegisterStatusReportListener();

    if (_timer != null) _timer.cancel();
    if (_timerSetter != null) _timerSetter = null;
    if (_memberListSetter != null) _memberListSetter = null;
    if (_statusPanelSetter != null) _statusPanelSetter = null;
    _signalStrengthSetters.clear();
    if (_multiMeetingPageSelectorSetter != null) _multiMeetingPageSelectorSetter = null;

    Wakelock.disable();

    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: ColorConfig.backgroundColor,
        body: Stack(
          children: [
            _buildMainView(context),
            Align(
              alignment: Alignment.topCenter,
              child: _buildTopBar(context),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomBar(context),
            ),
          ],
        ),
      ),
      onWillPop: () => _showExitAlert(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12.dp),
                child: (_config.speaker ? 'playback_speaker' : 'playback_phone').toPNGButton(
                  onPressed: () => _changeSpeakerState(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.dp),
                child: 'switch_camera'.toPNGButton(
                  onPressed: () => _switchCamera(),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 12.dp),
                child: TextButton(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 8.dp,
                      right: 8.dp,
                      top: 2.dp,
                      bottom: 3.dp,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.dp),
                      color: Colors.redAccent,
                    ),
                    child: Text(
                      '退出会议',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  onPressed: () => _showExitAlert(context),
                ),
              ),
            ],
          ),
          GestureDetector(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _id,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                StatefulBuilder(builder: (context, setter) {
                  this._timerSetter = setter;
                  return Text(
                    _time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  );
                }),
              ],
            ),
            onTap: () => _showStatusPanel(context),
          ),
        ],
      ),
    );
  }

  void _changeSpeakerState() async {
    _config.speaker = !_config.speaker;
    await RCRTCEngine.getInstance().enableSpeaker(_config.speaker);
    setState(() {});
  }

  void _switchCamera() async {
    _config.frontCamera = await presenter?.switchCamera();
    UserView view = _getSelfView();
    view?.mirror = _config.frontCamera;
    setState(() {});
  }

  UserView _getSelfView() {
    var views = _views.where((view) => view.self);
    if (views.isNotEmpty) return views.first;
    return null;
  }

  Future<bool> _showExitAlert(BuildContext context) {
    Alert.showAlert(
      title: '提示',
      message: '确定退出会议？',
      left: '取消',
      onPressedLeft: () {
        Navigator.pop(context);
      },
      right: '确定',
      onPressedRight: () {
        Navigator.pop(context);
        _exit(context);
      },
    );
    return Future.value(false);
  }

  void _exit(BuildContext context) async {
    Loading.show(context);
    StatusCode code = await presenter.exit();
    if (code.status != Status.ok) {
      'exit with error, ${code.message}'.toast();
    }
    Loading.dismiss(context);
    _doExit();
  }

  void _doExit() {
    Navigator.pop(context);
  }

  String get _id {
    String id = RCRTCEngine.getInstance().getRoom()?.id ?? "";
    id = id.replaceAllMapped(RegExp(r'(.{3})'), (match) => '${match[0]} ');
    return id;
  }

  String get _time {
    String time = _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(_timeCount * 1000));
    return time;
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

  Widget _buildMainView(BuildContext context) {
    int count = _views.length;
    if (count < 2) {
      return _buildSingleMeeting(context);
    } else if (count < 3) {
      return _buildCoupleMeeting(context);
    } else if (count <= 4) {
      return _buildQuattroMeeting(context);
    } else {
      return _buildMultiMeeting(context);
    }
  }

  Widget _buildView(
    BuildContext context,
    UserView view,
    EdgeInsets padding,
  ) {
    if (view == null) return Container();
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
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatefulBuilder(builder: (context, setter) {
                  _signalStrengthSetters[view.user.id] = setter;
                  return 'signal_strength_level_${_getSignalStrength(view)}'.png.image;
                }),
                Text(
                  view.user.id,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  List<UserView> _viewsWithoutMain() {
    if (_mainView == null) return _views;
    return _views.where((view) => view.user.id != _mainView.user.id).toList();
  }

  Widget _buildSingleMeeting(BuildContext context) {
    _multiMeetingSelectPage = null;
    _multiMeetingPageSelectorSetter = null;

    return _buildView(
      context,
      _mainView,
      EdgeInsets.only(
        left: 20.dp,
        bottom: 60.dp,
      ),
    );
  }

  Widget _buildCoupleMeeting(BuildContext context) {
    _multiMeetingSelectPage = null;
    _multiMeetingPageSelectorSetter = null;

    List<UserView> views = _viewsWithoutMain();
    UserView view = views.first;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(ContextHolder.currentContext).padding.top,
        bottom: 50.dp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: _buildView(
              context,
              _mainView,
              EdgeInsets.only(
                left: 8.dp,
                bottom: 8.dp,
              ),
            ),
          ),
          Divider(
            height: 8.dp,
          ),
          Expanded(
            flex: 1,
            child: _buildView(
              context,
              view,
              EdgeInsets.only(
                left: 8.dp,
                bottom: 8.dp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuattroMeeting(BuildContext context) {
    _multiMeetingSelectPage = null;
    _multiMeetingPageSelectorSetter = null;

    List<UserView> views = _viewsWithoutMain();
    views.insert(0, _mainView);
    return Container(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(ContextHolder.currentContext).padding.top,
        bottom: 50.dp,
      ),
      child: _buildQuattroMeetingWidget(context, views, false),
    );
  }

  Widget _buildMultiMeeting(BuildContext context) {
    if (_multiMeetingSelectPage == null) _multiMeetingSelectPage = 0;
    int total = (_views.length / 4).ceil();
    return Container(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        bottom: 50.dp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: total,
              onPageChanged: (page) {
                _multiMeetingSelectPage = page;
                if (_multiMeetingPageSelectorSetter != null) _multiMeetingPageSelectorSetter(() {});
              },
              itemBuilder: (context, index) {
                return _buildMultiMeetingPage(context, index);
              },
            ),
          ),
          Container(
            height: 14.dp,
            alignment: Alignment.center,
            child: StatefulBuilder(builder: (context, setter) {
              _multiMeetingPageSelectorSetter = setter;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildMultiMeetingPageIndicator(total),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildMultiMeetingPage(BuildContext context, int index) {
    int start = index * 4;
    int end = index * 4 + 4;
    if (end > _views.length) end = _views.length;
    List<UserView> views = _views.sublist(start, end);
    return _buildQuattroMeetingWidget(context, views, true);
  }

  Widget _buildQuattroMeetingWidget(BuildContext context, List<UserView> views, bool quattro) {
    List<Widget> column = List();
    for (int i = 0; i < 2; i++) {
      List<Widget> row = List();
      for (int j = 0; j < 2; j++) {
        int index = i * 2 + j;
        if (index < views.length)
          row.add(
            quattro || index < 2 || views.length % 2 == 0
                ? Expanded(
                    flex: 1,
                    child: _buildView(
                      context,
                      views[index],
                      EdgeInsets.only(
                        left: 8.dp,
                        bottom: 8.dp,
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width / 2 - 8.dp,
                    child: _buildView(
                      context,
                      views[index],
                      EdgeInsets.only(
                        left: 8.dp,
                        bottom: 8.dp,
                      ),
                    ),
                  ),
          );
        else if (quattro)
          row.add(
            Expanded(
              flex: 1,
              child: Container(),
            ),
          );
        if (j != 1 && index != views.length - 1)
          row.add(
            VerticalDivider(
              width: 8.dp,
            ),
          );
      }
      column.add(
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row,
          ),
        ),
      );
      if (i != 1)
        column.add(
          Divider(
            height: 8.dp,
          ),
        );
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: column,
      ),
    );
  }

  List<Widget> _buildMultiMeetingPageIndicator(int total) {
    List<Widget> indicator = List();
    for (int i = 0; i < total; i++) {
      indicator.add(
        Container(
          width: 10.dp,
          height: 2.dp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.5.dp),
            color: _multiMeetingSelectPage == i ? Colors.white : Colors.black.withOpacity(0.3),
          ),
        ),
      );
      if (i != total - 1)
        indicator.add(
          VerticalDivider(
            width: 4.dp,
          ),
        );
    }
    return indicator;
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 50.dp,
      color: Colors.black.withOpacity(0.3),
      child: Row(
        children: [
          Spacer(),
          (_config.mic ? 'microphone_off' : 'microphone_on').png.image.toButton(
                onPressed: () => _changeAudioStreamState(),
              ),
          Spacer(),
          (_config.camera ? 'camera_off' : 'camera_on').png.image.toButton(
                onPressed: () => _changeVideoStreamState(),
              ),
          Spacer(),
          'member_list'.png.image.toButton(
                onPressed: () => _showMemberList(context),
              ),
          Spacer(),
          'more'.png.image.toButton(
                onPressed: () => _showMoreSettingList(context),
              ),
          Spacer(),
        ],
      ),
    );
  }

  void _changeAudioStreamState() {
    presenter?.changeAudioStreamState(_config);
  }

  void _changeVideoStreamState() {
    presenter?.changeVideoStreamState(_config);
  }

  void _showMemberList(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setter) {
            _memberListSetter = setter;
            return WillPopScope(
              child: Scaffold(
                backgroundColor: ColorConfig.backgroundColor,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight + MediaQuery.of(ContextHolder.currentContext).padding.top),
                  child: Container(
                    color: ColorConfig.backgroundColor,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(ContextHolder.currentContext).padding.top),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 12.dp,
                              ),
                              child: 'navigator_back'.png.image.toButton(
                                onPressed: () {
                                  _memberListSetter = null;
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Text(
                            '成员列表',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: ListView.separated(
                  itemCount: _views.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      indent: 20.dp,
                      endIndent: 20.dp,
                      height: 1.dp,
                      color: ColorConfig.dividerColor,
                    );
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 20.dp,
                              top: 12.dp,
                              bottom: 12.dp,
                            ),
                            child: SizedBox(
                              width: 48.dp,
                              height: 48.dp,
                              child: _views[index].user.avatar.image,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12.dp),
                            child: Text(
                              _views[index].user.id,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 20.dp),
                            child: (_views[index].audio ? 'member_list_microphone_off' : 'member_list_microphone_on').png.image.toButton(
                                  onPressed: () => _changeMemberAudioStreamState(_views[index]),
                                ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.dp),
                            child: (_views[index].video ? 'member_list_camera_off' : 'member_list_camera_on').png.image.toButton(
                                  onPressed: () => _changeMemberVideoStreamState(_views[index]),
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                bottomNavigationBar: Container(
                  padding: EdgeInsets.all(20.dp),
                  child: Row(
                    children: [
                      Spacer(),
                      subscribeAudioStreams
                          ? '全体静音'.toRedLabelButton(
                              onPressed: () => _unsubscribeRemoteAudioStreams(),
                            )
                          : '解除全体静音'.toBlueLabelButton(
                              onPressed: () => _subscribeRemoteAudioStreams(),
                            ),
                      Spacer(),
                      subscribeVideoStreams
                          ? '全体禁画'.toRedLabelButton(
                              onPressed: () => _unsubscribeRemoteVideoStreams(),
                            )
                          : '解除全体禁画'.toBlueLabelButton(
                              onPressed: () => _subscribeRemoteVideoStreams(),
                            ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              onWillPop: () {
                _memberListSetter = null;
                Navigator.pop(context);
                return Future.value(false);
              },
            );
          },
        );
      },
    );
  }

  void _changeMemberAudioStreamState(UserView view) {
    if (view.self)
      _changeAudioStreamState();
    else
      presenter?.changeRemoteAudioStreamState(view);
  }

  void _changeMemberVideoStreamState(UserView view) {
    if (view.self)
      _changeVideoStreamState();
    else
      presenter?.changeRemoteVideoStreamState(view);
  }

  void _unsubscribeRemoteAudioStreams() {
    if (!subscribeAudioStreams) return;
    subscribeAudioStreams = false;
    presenter?.unsubscribeRemoteAudioStreams(_views);
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
    '全体静音'.toast(gravity: Gravity.center);
  }

  void _subscribeRemoteAudioStreams() {
    if (subscribeAudioStreams) return;
    subscribeAudioStreams = true;
    presenter?.subscribeRemoteAudioStreams(_views);
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
    '解除全体静音'.toast(gravity: Gravity.center);
  }

  void _unsubscribeRemoteVideoStreams() {
    if (!subscribeVideoStreams) return;
    subscribeVideoStreams = false;
    presenter?.unsubscribeRemoteVideoStreams(_views);
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
    '全体禁画'.toast(gravity: Gravity.center);
  }

  void _subscribeRemoteVideoStreams() {
    if (subscribeVideoStreams) return;
    subscribeVideoStreams = true;
    presenter?.subscribeRemoteVideoStreams(_views);
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
    '解除全体禁画'.toast(gravity: Gravity.center);
  }

  void _showMoreSettingList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: ColorConfig.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '更多',
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(20.dp),
                      child: 'pop_page_close'.png.image.toButton(
                            onPressed: () => Navigator.pop(context),
                          ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10.dp),
                constraints: BoxConstraints(
                  maxHeight: 200.dp,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisSpacing: 10.dp,
                  mainAxisSpacing: 10.dp,
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  children: [
                    bottomSheetStyleButton(
                      icon: 'pop_page_audio_setting',
                      title: '音效/混音',
                      onPressed: () {
                        Navigator.pop(context);
                        _showAudioSettingsPage(context);
                      },
                    ),
                    bottomSheetStyleButton(
                      icon: 'pop_page_setting',
                      title: '设置',
                      onPressed: () {
                        Navigator.pop(context);
                        _showSettingsPage(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAudioSettingsPage(BuildContext context) {
    BottomAudioEffectMixSettingsSheet.show();
  }

  void _showSettingsPage(BuildContext context) {
    BottomAudioVideoSettingsSheet.show(_config, callback: this);
  }

  void changedVideoFPS(RCRTCFps fps) {
    _config.fps = fps;
    presenter?.changeVideoStreamConfig(_config);
  }

  void changedVideoResolution(Resolution resolution) {
    _config.resolution = resolution;
    presenter?.changeVideoStreamConfig(_config);
  }

  void changedVideoLocalMirror(bool mirror) {
    UserView view = _getSelfView();
    view.mirror = mirror;
    setState(() {});
  }

  void changedAudioSpeakerState(bool speaker) {
    RCRTCEngine.getInstance().enableSpeaker(speaker);
    setState(() {});
  }

  @override
  void onUserJoined(UserView view) {
    if (view.self) {
      view.mirror = _config.frontCamera;
      _mainView = view;
    }
    _addSubView(view);
    _views.forEach((element) {
      element.invalidate();
    });
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
  }

  void _addSubView(UserView view) {
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
      if (_timerSetter != null)
        _timerSetter(() {
          _timeCount++;
        });
    });

    if (RCRTCEngine.getInstance().getRoom().remoteUserList.isEmpty)
      '创建会议成功'.toast(gravity: Gravity.center);
    else
      '加入会议成功'.toast(gravity: Gravity.center);
  }

  @override
  void onPublishError(String info) {
    // TODO: implement onPublishError
  }

  @override
  void onUserAudioStreamChanged(String uid, dynamic stream) {
    UserView view = _getUserView(uid);
    view.audioStream = stream;
    if (view.self) _config.mic = view.audio;
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
  }

  @override
  void onUserVideoStreamChanged(String uid, stream) {
    UserView view = _getUserView(uid);
    view.videoStream = stream;
    if (view.self) _config.camera = view.video;
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
  }

  UserView _getUserView(String uid) {
    var views = _views.where((view) => view.user.id == uid);
    if (views.isNotEmpty) return views.first;
    return null;
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
    setState(() {});
    if (_memberListSetter != null) _memberListSetter(() {});
  }

  @override
  void onConnectionStats(StatusReport report) {
    _statusReport = report;

    _signalStrengthSetters.values.forEach((setter) {
      setter(() {});
    });
    if (_statusPanelSetter != null) _statusPanelSetter(() {});
  }

  Config _config;

  Timer _timer;
  int _timeCount = 0;
  DateFormat _timeFormat = DateFormat('mm:ss');
  StateSetter _timerSetter;

  UserView _mainView;
  List<UserView> _views = List();

  bool subscribeAudioStreams = true;
  bool subscribeVideoStreams = true;

  StateSetter _memberListSetter;

  StatusReport _statusReport;

  StateSetter _statusPanelSetter;

  Map<String, StateSetter> _signalStrengthSetters = Map();

  int _multiMeetingSelectPage;
  StateSetter _multiMeetingPageSelectorSetter;
}
