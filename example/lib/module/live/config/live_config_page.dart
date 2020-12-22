import 'dart:io';
import 'dart:ui';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/resolution_selector.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:rongcloud_rtc_plugin/agent/stream/rcrtc_video_stream_config.dart';

import 'colors.dart';
import 'live_config_page_contract.dart';
import 'live_config_page_presenter.dart';

class LiveConfigPage extends AbstractView {
  @override
  _LiveConfigPageState createState() => _LiveConfigPageState();
}

class _LiveConfigPageState extends AbstractViewState<Presenter, LiveConfigPage> with WidgetsBindingObserver implements View {
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
    return LiveConfigPagePresenter();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: GestureDetector(
          child: Stack(
            children: [
              _preview?.widget ??
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: ColorConfig.previewBackgroundColor,
                  ),
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
        ),
      ),
      onWillPop: () {
        _exit();
        return Future.value(false);
      },
    );
  }

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
          Padding(padding: EdgeInsets.only(bottom: 10.dp)),
          Text(
            '正在连接IM，请稍候',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
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
            fontSize: 15.sp,
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
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCameraPermissionGuild(context),
              Container(
                height: 30.dp,
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
          fontSize: 15.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    return GestureDetector(
      onTap: () => presenter.requestCameraPermission(),
      child: Text(
        "允许使用摄像机",
        style: TextStyle(
          fontSize: 15.sp,
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
          fontSize: 15.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    return GestureDetector(
      onTap: () => presenter.requestMicPermission(),
      child: Text(
        "允许使用麦克风",
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildConfigs(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(
              top: 38.dp,
              right: 12.dp,
            ),
            child: 'module_close'.png.image.toButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: 102.dp,
            ),
            child: _buildRoomInfoArea(context),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 44.dp,
            ),
            child: Container(
              height: 52.dp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 20.dp),
                    child: 'live_config_switch_camera'.png.image.toButton(
                          onPressed: () => _changeFrontCameraConfig(),
                        ),
                  ),
                  _buildStartButton(context),
                  Padding(
                    padding: EdgeInsets.only(left: 20.dp),
                    child: 'live_config_setting'.png.image.toButton(
                          onPressed: () => _showSettingsPage(context),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomInfoArea(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.dp),
          color: Colors.black.withOpacity(0.24),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(12.dp),
              child: SizedBox(
                width: 80.dp,
                height: 80.dp,
                child: DefaultData.user.cover.fullImage,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 12.dp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DefaultData.user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    TextField(
                      controller: _roomIdController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '房间ID（字母和数字）',
                        hintStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
                          decoration: TextDecoration.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(18),
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
                      ],
                      onEditingComplete: () => _start(context),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeFrontCameraConfig() async {
    if (_config.camera) {
      _config.frontCamera = await presenter?.switchCamera();
      _preview.mirror = _config.frontCamera;
      setState(() {});
    }
  }

  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 188.dp,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorConfig.startButtonColor,
          borderRadius: BorderRadius.circular(26.dp),
        ),
        child: Text(
          "开始${ModeStrings[_mode.index]}",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      onTap: () => _start(context),
    );
  }

  void _start(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    String rid = _roomIdController.value.text;
    if (rid.length < 4) return '房间ID长度不能小于四个字符'.toast(gravity: Gravity.center, duration: Toast.LONG);
    Loading.show(context);
    presenter?.joinRoom(context, _mode, _roomIdController.value.text);
  }

  void _showSettingsPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: ColorConfig.settingsPageBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.dp),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setter) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '设置',
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
                  constraints: BoxConstraints(
                    maxHeight: 300.dp,
                  ),
                  padding: EdgeInsets.only(
                    left: 20.dp,
                    right: 20.dp,
                    bottom: 20.dp,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSpeakerSwitcher(context, setter),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.dp),
                          child: Divider(
                            height: 1.dp,
                            color: ColorConfig.settingsPageDividerColor,
                          ),
                        ),
                        _buildFPSSetter(context, setter),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.dp),
                          child: Divider(
                            height: 1.dp,
                            color: ColorConfig.settingsPageDividerColor,
                          ),
                        ),
                        _buildResolutionSelector(context, setter),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSpeakerSwitcher(BuildContext context, StateSetter setter) {
    return '开启扬声器'.toConfigStyleSwitcher(
      value: _config.speaker,
      padding: false,
      onTap: () => _changeSpeakerConfig(setter),
    );
  }

  void _changeSpeakerConfig(StateSetter setter) {
    setter(() {
      _config.speaker = !_config.speaker;
    });
  }

  Widget _buildFPSSetter(BuildContext context, StateSetter setter) {
    return '帧率'.toConfigStyleSetter(
      value: FPSStrings[_config.fps.index],
      onTap: () {
        _showFPSSelectorPage(context, _config.fps.index).then((value) {
          setter(() {
            _config.fps = RCRTCFps.values[value];
          });
        });
      },
    );
  }

  Future<dynamic> _showFPSSelectorPage(BuildContext context, int index) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: ColorConfig.settingsPageBackgroundColor,
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
                    '选择帧率',
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
                            onPressed: () => Navigator.pop(context, index),
                          ),
                    ),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 300.dp,
                ),
                padding: EdgeInsets.only(
                  left: 20.dp,
                  right: 20.dp,
                  bottom: 20.dp,
                ),
                child: ListView.separated(
                  itemCount: FPSStrings.length,
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.dp),
                      child: Divider(
                        height: 1.dp,
                        color: ColorConfig.settingsPageDividerColor,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    return FPSStrings[index].toConfigStyleSetter(
                      value: '',
                      onTap: () => Navigator.pop(context, index),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildResolutionSelector(BuildContext context, StateSetter setter) {
    return ResolutionSelector(
      title: '分辨率',
      resolution: _config.resolution,
      onSelected: (resolution) {
        setter(() {
          _config.resolution = resolution;
        });
      },
    );
  }

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
    _gotoLive();
  }

  void _gotoLive() {
    Navigator.pop(context);
    Navigator.pushNamed(context, RouterManager.LIVE_HOST, arguments: _config.toJSON());
  }

  @override
  void onJoinRoomError(BuildContext context, String info) {
    Loading.dismiss(context);
    info.toast(gravity: Gravity.center);
  }

  bool _paused = false;

  bool _imConnecting = true;
  bool _showIMConnectError = false;
  bool _showPermissionGuide = false;
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  VideoStreamWidget _preview;

  Offset _dragOffsetA;
  Offset _dragOffsetB;

  TextEditingController _roomIdController = TextEditingController();

  Mode _mode = Mode.Live;

  Config _config = Config.config();
}
