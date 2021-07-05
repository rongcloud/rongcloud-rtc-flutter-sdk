import 'package:rc_rtc_flutter_example/data/constants.dart';
import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/view.dart';
import 'package:rc_rtc_flutter_example/frame/ui/loading.dart';
import 'package:rc_rtc_flutter_example/frame/utils/extension.dart';
import 'package:rc_rtc_flutter_example/widgets/ui.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'host_page_contract.dart';
import 'host_page_presenter.dart';

class HostPage extends AbstractView {
  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends AbstractViewState<HostPagePresenter, HostPage> implements View, IRCRTCStatusReportListener {
  @override
  HostPagePresenter createPresenter() {
    return HostPagePresenter();
  }

  @override
  void init(BuildContext context) {
    super.init(context);

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _config = Config.fromJson(arguments);

    _tinyConfig = RCRTCVideoStreamConfig(
      100,
      500,
      RCRTCFps.fps_15,
      RCRTCVideoResolution.RESOLUTION_180_320,
    );

    RCRTCEngine.getInstance().registerStatusReportListener(this);
  }

  @override
  void dispose() {
    _localReportSetter = null;
    _remoteReportSetter.clear();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('房间号: ${RCRTCEngine.getInstance().getRoom()?.id}'),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.link,
            //   ),
            //   onPressed: _info != null ? () => _showLink(context) : null,
            // ),
            IconButton(
              icon: Icon(
                Icons.alt_route,
              ),
              onPressed: _info != null ? () => _showCDNInfo(context) : null,
            ),
            IconButton(
              icon: Icon(
                Icons.picture_in_picture,
              ),
              onPressed: _info != null ? () => _showMixInfo(context) : null,
            ),
            IconButton(
              icon: Icon(
                Icons.message,
              ),
              onPressed: () => _showMessagePanel(context),
            ),
          ],
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200.dp,
                          height: 160.dp,
                          color: Colors.blue,
                          child: Stack(
                            children: [
                              _local?.widget ?? Container(),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 5.dp,
                                    top: 5.dp,
                                  ),
                                  child: Text(
                                    '${DefaultData.user?.id}',
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 5.dp,
                                    top: 15.dp,
                                  ),
                                  child: BoxFitChooser(
                                    fit: _local?.fit ?? BoxFit.contain,
                                    onSelected: (fit) {
                                      setState(() {
                                        _local?.fit = fit;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Row(
                              children: [
                                CheckBoxes(
                                  '采集音频',
                                  checked: _config.mic,
                                  onChanged: (checked) => _changeMic(checked),
                                ),
                                CheckBoxes(
                                  '采集视频',
                                  checked: _config.camera,
                                  onChanged: (checked) => _changeCamera(checked),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CheckBoxes(
                                  '发布音频',
                                  checked: _config.audio,
                                  onChanged: (checked) => _changeAudio(checked),
                                ),
                                CheckBoxes(
                                  '发布视频',
                                  checked: _config.video,
                                  onChanged: (checked) => _changeVideo(checked),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CheckBoxes(
                                  '前置摄像',
                                  checked: _config.frontCamera,
                                  onChanged: (checked) => _changeFrontCamera(checked),
                                ),
                                CheckBoxes(
                                  '本地镜像',
                                  checked: _config.mirror,
                                  onChanged: (checked) => _changeMirror(checked),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Button(
                                  _config.speaker ? '扬声器' : '听筒',
                                  size: 15.sp,
                                  callback: () => _changeSpeaker(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isDense: true,
                                    value: _config.fps,
                                    items: _buildFpsItems(),
                                    onChanged: (dynamic fps) => _changeFps(fps),
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isDense: true,
                                    value: _config.resolution,
                                    items: _buildResolutionItems(),
                                    onChanged: (dynamic resolution) => _changeResolution(resolution),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '码率下限:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.sp,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isDense: true,
                                    value: _config.minVideoKbps,
                                    items: _buildMinVideoKbpsItems(),
                                    onChanged: (dynamic kbps) => _changeMinVideoKbps(kbps),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '码率上限:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.sp,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isDense: true,
                                    value: _config.maxVideoKbps,
                                    items: _buildMaxVideoKbpsItems(),
                                    onChanged: (dynamic kbps) => _changeMaxVideoKbps(kbps),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.dp),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Spacer(),
                            Text(
                              "小流设置",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    // DropdownButtonHideUnderline(
                                    //   child: DropdownButton(
                                    //     isDense: true,
                                    //     value: _tinyConfig.fps,
                                    //     items: _buildFpsItems(),
                                    //     onChanged: (fps) => _changeTinyFps(fps),
                                    //   ),
                                    // ),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isDense: true,
                                        value: _tinyConfig.resolution,
                                        items: _buildResolutionItems(),
                                        onChanged: (dynamic resolution) => _changeTinyResolution(resolution),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '下限:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.sp,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isDense: true,
                                        value: MinVideoKbps.indexOf(_tinyConfig.minRate),
                                        items: _buildMinVideoKbpsItems(),
                                        onChanged: (dynamic kbps) => _changeTinyMinVideoKbps(kbps),
                                      ),
                                    ),
                                    Text(
                                      '上限:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.sp,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isDense: true,
                                        value: MaxVideoKbps.indexOf(_tinyConfig.maxRate),
                                        items: _buildMaxVideoKbpsItems(),
                                        onChanged: (dynamic kbps) => _changeTinyMaxVideoKbps(kbps),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    StatefulBuilder(builder: (context, setter) {
                      _localReportSetter = setter;
                      return StatusTable(
                        _report,
                        role: Role.Local,
                      );
                    }),
                  ],
                ),
              ),
              Divider(
                height: 10.dp,
                color: Colors.black,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _remotes.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 5.dp,
                      color: Colors.transparent,
                    );
                  },
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200.dp,
                          height: 160.dp,
                          color: Colors.blue,
                          child: Stack(
                            children: [
                              _remotes[index].widget ?? Container(),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 5.dp,
                                    top: 5.dp,
                                  ),
                                  child: Text(
                                    '${_remotes[index].user.id}',
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 5.dp,
                                    bottom: 5.dp,
                                  ),
                                  child: Offstage(
                                    offstage: !_remotes[index].video,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        '切大流'.onClick(() {
                                          _switchToNormalStream(_remotes[index].user.id);
                                        }),
                                        VerticalDivider(
                                          width: 10.dp,
                                          color: Colors.transparent,
                                        ),
                                        '切小流'.onClick(() {
                                          _switchToTinyStream(_remotes[index].user.id);
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 5.dp,
                                    top: 15.dp,
                                  ),
                                  child: BoxFitChooser(
                                    fit: _remotes[index].fit,
                                    onSelected: (fit) {
                                      setState(() {
                                        _remotes[index].fit = fit;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 2.dp,
                          color: Colors.transparent,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  CheckBoxes(
                                    '订阅音频',
                                    enable: _remotes[index].user.audio,
                                    checked: _remotes[index].audio,
                                    onChanged: (subscribe) => _changeRemoteAudio(index, subscribe),
                                  ),
                                  CheckBoxes(
                                    '订阅视频',
                                    enable: _remotes[index].user.video,
                                    checked: _remotes[index].video,
                                    onChanged: (subscribe) => _changeRemoteVideo(index, subscribe),
                                  ),
                                ],
                              ),
                              StatefulBuilder(builder: (context, setter) {
                                _remoteReportSetter[_remotes[index].user.id] = setter;
                                return StatusTable(
                                  _report,
                                  role: Role.Remote,
                                  audio: _remotes[index].audioStream?.streamId,
                                  video: _remotes[index].videoStream?.streamId,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () => _exit(),
    );
  }

  // void _showLink(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('直播地址'),
  //         content: SelectableText(
  //           _info.liveUrl,
  //         ),
  //         actions: [
  //           FlatButton(
  //             child: Text('Ok'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showCDNInfo(BuildContext context) async {
    Loading.show(context);
    final String? id = await RCRTCEngine.getInstance().getRoom()?.getSessionId();
    if (id?.isEmpty ?? true) return "Session Id is NULL!!".toast();
    Loading.dismiss(context);
    showDialog(
      context: context,
      builder: (context) {
        return CDNConfig(
          id: id!,
          info: _info!,
          cdnList: _cdnList,
          // callback: (list) {
          //   _cdnList = list;
          //   Navigator.pop(context);
          // },
        );
      },
    );
  }

  void _showMixInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MixConfig(
          callback: (config) {
            _info?.setMixConfig(config);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showMessagePanel(BuildContext context) {
    String? id = RCRTCEngine.getInstance().getRoom()?.id;
    if (id?.isEmpty ?? true) return "Room Id is NULL!!".toast();
    showDialog(
      context: context,
      builder: (context) {
        return MessagePanel(id!, true);
      },
    );
  }

  void _changeMic(bool open) async {
    bool result = await presenter.changeMic(open);
    setState(() {
      _config.mic = result;
    });
  }

  void _changeCamera(bool open) async {
    bool result = await presenter.changeCamera(open);
    setState(() {
      if (!result) _local?.invalidate();
      _config.camera = result;
    });
  }

  void _changeAudio(bool publish) async {
    Loading.show(context);
    bool result = await presenter.changeAudio(publish);
    setState(() {
      _config.audio = result;
    });
    Loading.dismiss(context);
  }

  void _changeVideo(bool publish) async {
    Loading.show(context);
    bool result = await presenter.changeVideo(publish);
    setState(() {
      _config.video = result;
    });
    Loading.dismiss(context);
  }

  void _changeFrontCamera(bool front) async {
    bool result = await presenter.changeFrontCamera(front);
    setState(() {
      _config.frontCamera = result;
    });
  }

  void _changeMirror(bool mirror) {
    setState(() {
      _config.mirror = mirror;
      _local?.mirror = mirror;
    });
  }

  void _changeSpeaker() async {
    bool result = await presenter.changeSpeaker(!_config.speaker);
    setState(() {
      _config.speaker = result;
    });
  }

  List<DropdownMenuItem<RCRTCFps>> _buildFpsItems() {
    List<DropdownMenuItem<RCRTCFps>> items = [];
    RCRTCFps.values.forEach((fps) {
      items.add(DropdownMenuItem(
        value: fps,
        child: Text(
          '${FPSStrings[fps.index]}FPS',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ));
    });
    return items;
  }

  void _changeFps(RCRTCFps fps) {
    _config.fps = fps;
    presenter.changeVideoConfig(_config.videoConfig);
    setState(() {});
  }

  List<DropdownMenuItem<RCRTCVideoResolution>> _buildResolutionItems() {
    List<DropdownMenuItem<RCRTCVideoResolution>> items = [];
    RCRTCVideoResolution.values.forEach((resolution) {
      items.add(DropdownMenuItem(
        value: resolution,
        child: Text(
          '${ResolutionStrings[resolution.index]}',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ));
    });
    return items;
  }

  void _changeResolution(RCRTCVideoResolution resolution) async {
    _config.resolution = resolution;
    await presenter.changeVideoConfig(_config.videoConfig);
    setState(() {});
  }

  List<DropdownMenuItem<int>> _buildMinVideoKbpsItems() {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 0; i < MinVideoKbps.length; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(
          '${MinVideoKbps[i]}kbps',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ));
    }
    return items;
  }

  void _changeMinVideoKbps(int kbps) {
    _config.minVideoKbps = kbps;
    presenter.changeVideoConfig(_config.videoConfig);
    setState(() {});
  }

  List<DropdownMenuItem<int>> _buildMaxVideoKbpsItems() {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 0; i < MaxVideoKbps.length; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(
          '${MaxVideoKbps[i]}kbps',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ));
    }
    return items;
  }

  void _changeMaxVideoKbps(int kbps) {
    _config.maxVideoKbps = kbps;
    presenter.changeVideoConfig(_config.videoConfig);
    setState(() {});
  }

  void _changeTinyFps(RCRTCFps fps) async {
    _tinyConfig.fps = fps;
    setState(() {});
    bool ret = await presenter.changeTinyVideoConfig(_tinyConfig);
    (ret ? '设置成功' : '设置失败').toast();
  }

  void _changeTinyResolution(RCRTCVideoResolution resolution) async {
    _tinyConfig.resolution = resolution;
    setState(() {});
    bool ret = await presenter.changeTinyVideoConfig(_tinyConfig);
    (ret ? '设置成功' : '设置失败').toast();
  }

  void _changeTinyMinVideoKbps(int kbps) async {
    _tinyConfig.minRate = MinVideoKbps[kbps];
    setState(() {});
    bool ret = await presenter.changeTinyVideoConfig(_tinyConfig);
    (ret ? '设置成功' : '设置失败').toast();
  }

  void _changeTinyMaxVideoKbps(int kbps) async {
    _tinyConfig.maxRate = MaxVideoKbps[kbps];
    setState(() {});
    bool ret = await presenter.changeTinyVideoConfig(_tinyConfig);
    (ret ? '设置成功' : '设置失败').toast();
  }

  void _switchToNormalStream(String id) {
    presenter.switchToNormalStream(id);
  }

  void _switchToTinyStream(String id) {
    presenter.switchToTinyStream(id);
  }

  void _changeRemoteAudio(int index, bool subscribe) async {
    Loading.show(context);
    _remotes[index].audioStream = await presenter.changeRemoteAudioStatus(_remotes[index].user.id, subscribe);
    setState(() {});
    Loading.dismiss(context);
  }

  void _changeRemoteVideo(int index, bool subscribe) async {
    Loading.show(context);
    _remotes[index].videoStream = await presenter.changeRemoteVideoStatus(_remotes[index].user.id, subscribe);
    setState(() {});
    Loading.dismiss(context);
  }

  Future<bool> _exit() {
    Loading.show(context);
    presenter.exit();
    return Future.value(false);
  }

  @override
  void onConnectionStats(StatusReport report) {
    _report = report;
    _remoteReportSetter.values.forEach((setter) {
      setter(() {});
    });
    _localReportSetter?.call(() {});
  }

  @override
  void onLocalViewCreated(UserView view) {
    setState(() {
      _local = view;
    });
  }

  @override
  void onPublished(RCRTCLiveInfo? info) {
    setState(() {
      _info = info;
    });
  }

  @override
  void onUserJoin(User user) {
    _remotes.removeWhere((element) => element.user.id == user.id);
    UserView view = UserView(user);
    view.mirror = false;
    _remotes.add(view);
    setState(() {});
  }

  @override
  void onUserLeft(String id) {
    _remotes.removeWhere((element) => element.user.id == id);
    _remoteReportSetter.remove(id);
    setState(() {});
  }

  @override
  void onUserAudioStatusChanged(String id, bool publish) {
    var view = _remotes.firstWhereOrNull(
      (element) => element.user.id == id,
    );
    view?.user.audio = publish;
    if (!publish) view?.audioStream = null;
    setState(() {});
  }

  @override
  void onUserVideoStatusChanged(String id, bool publish) {
    var view = _remotes.firstWhereOrNull(
      (element) => element.user.id == id,
    );
    view?.user.video = publish;
    if (!publish) view?.videoStream = null;
    setState(() {});
  }

  @override
  void onExit() {
    Loading.dismiss(context);
    Navigator.pop(context);
  }

  @override
  void onExitWithError(int code) {
    Loading.dismiss(context);
    'Exit with error, code = $code'.toast();
    Navigator.pop(context);
  }

  late Config _config;
  late RCRTCVideoStreamConfig _tinyConfig;
  RCRTCLiveInfo? _info;
  UserView? _local;
  List<UserView> _remotes = [];
  StatusReport? _report;
  StateSetter? _localReportSetter;
  Map<String, StateSetter> _remoteReportSetter = Map();
  List<CDNInfo> _cdnList = [];
}
