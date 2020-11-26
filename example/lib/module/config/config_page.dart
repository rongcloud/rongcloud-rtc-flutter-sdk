import 'dart:io';
import 'dart:ui';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/module/config/config_page_presenter.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';
import 'config_page_contract.dart';

class ConfigPage extends AbstractView {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends AbstractViewState<Presenter, ConfigPage> with WidgetsBindingObserver implements View {
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
      presenter?.stopPreview();
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      if (_showPermissionGuide) presenter?.requestPermission();
    }
  }

  @override
  Presenter createPresenter() {
    return ConfigPagePresenter();
  }

  @override
  Size designSize() {
    return const Size(375, 667);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: GestureDetector(
            child: Stack(
              children: [
                _preview?.widget ?? Container(width: double.infinity, height: double.infinity, color: Colors.white),
                _imConnecting
                    ? _buildIMConnecting(context)
                    : _showIMConnectError
                        ? _buildIMConnectError(context)
                        : _showPermissionGuide
                            ? _buildPermissionGuild(context)
                            : _buildConfigs(context),
              ],
            ),
            onHorizontalDragStart: (details) {
              _dragOffsetA = details.globalPosition;
            },
            onHorizontalDragUpdate: (details) {
              _dragOffsetB = details.globalPosition;
            },
            onHorizontalDragEnd: (details) {
              double velocity = details.velocity.pixelsPerSecond.distance;
              double offset = _dragOffsetA.dx - _dragOffsetB.dx;
              if (offset < 0) {
                if (Platform.isIOS && velocity > 0) _exit();
              } else {}
            },
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            // onVerticalDragStart: (details) {
            //   _verticalDragOffsetA = details.globalPosition;
            // },
            // onVerticalDragUpdate: (details) {
            //   _verticalDragOffsetB = details.globalPosition;
            // },
            // onVerticalDragEnd: (details) {
            //   double velocity = details.velocity.pixelsPerSecond.distance;
            //   double offset = _verticalDragOffsetA.dy - _verticalDragOffsetB.dy;
            //   if (offset < 0) {
            //     if (velocity > 0) _refreshLiveRoomList();
            //   } else {}
            // },
          ),
        ),
        onWillPop: () {
          presenter?.exit();
          return Future.value(true);
        });
  }

  // Future<void> _refreshLiveRoomList() async {
  //   if (_isLoading) return;
  //   _isLoading = true;
  //   presenter?.loadLiveRoomList(true);
  // }

  // Future<void> _loadLiveRoomList() async {
  //   if (_isLoading) return;
  //   _isLoading = true;
  //   presenter?.loadLiveRoomList();
  // }

  void _exit() {
    presenter?.exit();
    Navigator.pop(context);
  }

  Widget _buildIMConnecting(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Padding(padding: EdgeInsets.only(bottom: 10.0.height)),
          Text(
            "正在连接IM，请稍候",
            style: TextStyle(
              fontSize: 15.0.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIMConnectError(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          "连接IM失败，点击重试。",
          style: TextStyle(
            fontSize: 15.0.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      onTap: () => _connectIM(),
    );
  }

  void _connectIM() {
    presenter?.connectIM();
    setState(() {
      _imConnecting = true;
    });
  }

  Widget _buildPermissionGuild(BuildContext context) {
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
                height: 30.0.height,
              ),
              _buildMicPermissionGuild(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPermissionGuild(BuildContext context) {
    if (_hasCameraPermission)
      return Text(
        "已有摄像机权限",
        style: TextStyle(
          fontSize: 15.0.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    return GestureDetector(
      onTap: () => presenter.requestCameraPermission(),
      child: Text(
        "允许使用摄像机",
        style: TextStyle(
          fontSize: 15.0.sp,
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
          fontSize: 15.0.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    return GestureDetector(
      onTap: () => presenter.requestMicPermission(),
      child: Text(
        "允许使用麦克风",
        style: TextStyle(
          fontSize: 15.0.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildConfigs(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // _buildRoomList(context),
        _buildRoomIdInputBox(context),
        _buildModeSelector(context),
        if (_mode != ConfigMode.Audio) _buildConfigSwitches(context),
        _buildStartButton(context),
      ],
    );
  }

  // Widget _buildRoomList(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //       left: 30.0.width,
  //       right: 30.0.width,
  //       bottom: 50.0.height,
  //     ),
  //     child: Container(
  //       width: double.infinity,
  //       height: 80.0.width,
  //       child: ListView.separated(
  //         scrollDirection: Axis.horizontal,
  //         itemCount: _list?.list?.length ?? 0,
  //         separatorBuilder: (context, index) {
  //           return VerticalDivider(
  //             width: 5.0.width,
  //           );
  //         },
  //         itemBuilder: (context, index) {
  //           return GestureDetector(
  //             child: Container(
  //               width: 80.0.width,
  //               height: 80.0.width,
  //               alignment: Alignment.center,
  //               color: Colors.lightBlue.withAlpha(130),
  //               child: Stack(
  //                 children: [
  //                   Text(
  //                     'Room\n${_list.list[index].id}',
  //                     style: TextStyle(
  //                       fontSize: 15.0.sp,
  //                       color: Colors.white,
  //                       decoration: TextDecoration.none,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             onTap: () => _joinLiveRoom(context, _list.list[index]),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Future<void> _joinLiveRoom(BuildContext context, Room room) async {
  //   Loading.show(context);
  //   presenter?.joinLiveRoom(context, room);
  // }

  Widget _buildRoomIdInputBox(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 30.0.width,
        right: 30.0.width,
        bottom: 20.0.height,
      ),
      child: TextField(
        controller: _roomIdController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 15.0.sp,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0.width),
          ),
          hintText: '指定房间号',
          hintStyle: TextStyle(fontSize: 15.0.sp),
          contentPadding: EdgeInsets.symmetric(
            vertical: 5.0.width,
            horizontal: 12.0.height,
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 30.0.height,
        left: 30.0.width,
        right: 30.0.width,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(5.0.width),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0.width,
                  style: BorderStyle.solid,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20.0.width,
                  bottom: 20.0.width,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.width,
                      ),
                    ),
                    _mode == ConfigMode.Meeting ? _buildSelectedRadio() : _buildUnselectedRadio(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.width,
                        right: 15.0.width,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${ConfigModeString[ConfigMode.Meeting.index]}模式",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            "适用于多人音视频通话场景",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () => _changeMode(ConfigMode.Meeting),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0.height,
            ),
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(5.0.width),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0.width,
                  style: BorderStyle.solid,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20.0.width,
                  bottom: 20.0.width,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.width,
                      ),
                    ),
                    _mode == ConfigMode.Live ? _buildSelectedRadio() : _buildUnselectedRadio(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.width,
                        right: 15.0.width,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${ConfigModeString[ConfigMode.Live.index]}模式",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            "适用于主播连麦及观众场景",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () => _changeMode(ConfigMode.Live),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0.height,
            ),
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(5.0.width),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0.width,
                  style: BorderStyle.solid,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20.0.width,
                  bottom: 20.0.width,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.width,
                      ),
                    ),
                    _mode == ConfigMode.Audio ? _buildSelectedRadio() : _buildUnselectedRadio(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.width,
                        right: 15.0.width,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${ConfigModeString[ConfigMode.Audio.index]}模式",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            "适用于纯音频通话场景",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () => _changeMode(ConfigMode.Audio),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRadio() {
    return Container(
      width: 20.0.width,
      height: 20.0.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0.width),
      ),
    );
  }

  Widget _buildUnselectedRadio() {
    return Container(
      width: 20.0.width,
      height: 20.0.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0.width),
        border: Border.all(
          color: Colors.grey,
          width: 3.0.width,
          style: BorderStyle.solid,
        ),
      ),
    );
  }

  void _changeMode(ConfigMode mode) {
    if (mode != ConfigMode.Audio) {
      _startPreview();
    } else {
      _stopPreview();
      _enableMic();
    }
    setState(() {
      _mode = mode;
    });
  }

  void _startPreview() {
    if (_config.camera) return;
    _config.camera = true;
    presenter?.startPreview();
  }

  void _stopPreview() {
    if (!_config.camera) return;
    _config.camera = false;
    presenter?.stopPreview();
  }

  void _enableMic() {
    if (_config.mic) return;
    _config.mic = true;
  }

  Widget _buildConfigSwitches(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.0.height,
        left: 30.0.width,
        right: 30.0.width,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: _config.mic ? FontAwesomeIcons.microphoneSlash.selected : FontAwesomeIcons.microphone.unselected,
            onTap: () => _changeMuteConfig(),
          ),
          Spacer(),
          GestureDetector(
            child: _config.speaker ? Icons.volume_off.selected : Icons.volume_up.unselected,
            onTap: () => _changeSpeakerConfig(),
          ),
          Spacer(),
          GestureDetector(
            child: _config.camera ? FontAwesomeIcons.videoSlash.selected : FontAwesomeIcons.video.unselected,
            onTap: () => _changeCameraConfig(),
          ),
          Spacer(),
          GestureDetector(
            child: _config.frontCamera ? FontAwesomeIcons.camera.selected : FontAwesomeIcons.camera.unselected,
            onTap: () => _changeFrontCameraConfig(),
          ),
        ],
      ),
    );
  }

  void _changeMuteConfig() {
    setState(() {
      _config.mic = !_config.mic;
    });
  }

  void _changeSpeakerConfig() {
    setState(() {
      _config.speaker = !_config.speaker;
    });
  }

  // TODO 快速点击情况下的稳定性有待验证
  void _changeCameraConfig() {
    _config.camera = !_config.camera;
    _config.camera ? presenter?.startPreview() : presenter?.stopPreview();
    setState(() {});
  }

  void _changeFrontCameraConfig() async {
    if (_config.camera) {
      _config.frontCamera = await presenter?.switchCamera();
      _preview.mirror = _config.frontCamera;
      setState(() {});
    }
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 50.0.height,
        left: 30.0.width,
        right: 30.0.width,
      ),
      child: GestureDetector(
        child: Container(
          width: double.infinity,
          height: 45.0.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5.0.width),
          ),
          child: Text(
            "开始${ConfigModeString[_mode.index]}",
            style: TextStyle(
              fontSize: 15.0.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        onTap: () => _start(context),
      ),
    );
  }

  void _start(BuildContext context) {
    Loading.show(context);
    presenter?.joinRoom(context, _mode, _roomIdController.value.text);
  }

  // @override
  // void onLiveRoomListLoaded(RoomList list) {
  //   _isLoading = false;
  //   setState(() {
  //     _list = list;
  //   });
  // }
  //
  // @override
  // void onLiveRoomListLoadError(String info) {
  //   _isLoading = false;
  // }

  @override
  void onIMConnected() {
    presenter?.requestPermission();
    setState(() {
      _imConnecting = false;
      _showIMConnectError = false;
    });
  }

  @override
  void onIMConnectError() {
    setState(() {
      _imConnecting = false;
      _showIMConnectError = true;
    });
  }

  @override
  void onPermissionGranted() {
    presenter?.startPreview();
    setState(() {
      _showPermissionGuide = false;
    });
  }

  @override
  void onPermissionDenied(bool camera, bool mic) {
    if (camera) presenter?.startPreview();
    setState(() {
      _showPermissionGuide = true;
      _hasCameraPermission = camera;
      _hasMicPermission = mic;
    });
  }

  @override
  void onCameraPermissionGranted() {
    presenter?.startPreview();
    setState(() {
      if (_hasMicPermission) _showPermissionGuide = false;
      _hasCameraPermission = true;
    });
  }

  @override
  void onCameraPermissionDenied() {
    setState(() {
      _hasCameraPermission = false;
      _showPermissionGuide = true;
    });
  }

  @override
  void onMicPermissionGranted() {
    setState(() {
      if (_hasCameraPermission) _showPermissionGuide = false;
      _hasMicPermission = true;
    });
  }

  @override
  void onMicPermissionDenied() {
    setState(() {
      _hasMicPermission = false;
      _showPermissionGuide = true;
    });
  }

  @override
  void onPreviewStarted(VideoStreamWidget view) {
    _preview = view;
    setState(() {});
  }

  @override
  void onPreviewStopped() {
    _preview = null;
    setState(() {});
  }

  @override
  void onJoinRoomSuccess(BuildContext context) {
    Loading.dismiss(context);
    switch (_mode) {
      case ConfigMode.Meeting:
        _gotoMeeting();
        break;
      case ConfigMode.Live:
        _gotoLive();
        break;
      case ConfigMode.Audio:
        _gotoAudio();
        break;
    }
  }

  void _gotoMeeting() {
    Navigator.pop(context);
    Navigator.pushNamed(context, RouterManager.VIDEO_CHAT, arguments: _config.toJSON());
  }

  void _gotoLive() {
    Navigator.pop(context);
    Navigator.pushNamed(context, RouterManager.LIVE_HOST, arguments: _config.toJSON());
  }

  void _gotoAudio() {
    Navigator.pop(context);
    Navigator.pushNamed(context, RouterManager.AUDIO_CHAT);
  }

  @override
  void onJoinRoomError(BuildContext context, String info) {
    Loading.dismiss(context);
    Toast.show(context, "Join Room Error, $info");
  }

  // @override
  // void onJoinLiveRoomSuccess(BuildContext context, Room room) {
  //   Loading.dismiss(context);
  //   _gotoAudience(room.id, room.url);
  // }
  //
  // void _gotoAudience(String roomId, String url) {
  //   Navigator.pushNamed(
  //     context,
  //     RouterManager.LIVE_AUDIENCE,
  //     arguments: {
  //       'roomId': roomId,
  //       'url': url,
  //     },
  //   );
  // }

  // @override
  // void onJoinLiveRoomError(BuildContext context, String info) {
  //   Loading.dismiss(context);
  //   Toast.show(context, "Join Room Error, $info");
  // }

  bool _paused = false;

  bool _imConnecting = true;
  bool _showIMConnectError = false;
  bool _showPermissionGuide = false;
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  VideoStreamWidget _preview;

  Offset _dragOffsetA;
  Offset _dragOffsetB;

  // Offset _verticalDragOffsetA;
  // Offset _verticalDragOffsetB;

  // RoomList _list;
  // bool _isLoading = false;

  TextEditingController _roomIdController = TextEditingController();

  ConfigMode _mode = ConfigMode.Meeting;

  Config _config = Config.config();
}
