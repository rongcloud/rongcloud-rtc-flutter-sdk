import 'dart:ui';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:FlutterRTC/widgets/resolution_selector.dart';
import 'package:flutter/material.dart';
import 'package:handy_toast/handy_toast.dart';

import 'colors.dart';
import 'meeting_config_page_contract.dart';
import 'meeting_config_page_presenter.dart';

class MeetingConfigPage extends AbstractView {
  @override
  _MeetingConfigPageState createState() => _MeetingConfigPageState();
}

class _MeetingConfigPageState extends AbstractViewState<Presenter, MeetingConfigPage> implements View {
  @override
  Presenter createPresenter() {
    return MeetingConfigPagePresenter();
  }

  @override
  void dispose() {
    presenter?.exit();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: 'navigator_back'.png.image.toButton(
              onPressed: () => Navigator.pop(context),
            ),
        title: Text(
          '多人视频会议',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: ColorConfig.backgroundColor,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            _imConnecting
                ? _buildIMConnecting(context)
                : _showIMConnectError
                    ? _buildIMConnectError(context)
                    : _showPermissionGuide
                        ? _buildPermissionGuild(context)
                        : _buildConfigs(context),
            _buildStartButton(context),
          ],
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
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
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildRoomIdInputBox(context),
          Divider(
            height: 1.dp,
            color: ColorConfig.settingsDividerColor,
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _buildCameraSwitcher(context),
          Divider(
            height: 1.dp,
            color: ColorConfig.settingsDividerColor,
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _buildFrontCameraSwitcher(context),
          Divider(
            height: 1.dp,
            color: ColorConfig.settingsDividerColor,
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _buildMicSwitcher(context),
          Divider(
            height: 1.dp,
            color: ColorConfig.settingsDividerColor,
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _buildSpeakerSwitcher(context),
          Divider(
            height: 1.dp,
            color: ColorConfig.settingsDividerColor,
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _buildEnableTinyStreamSwitcher(context),
          Divider(
            height: 1.dp,
            color: ColorConfig.settingsDividerColor,
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _buildResolutionSelector(context),
          Divider(
            height: 20.dp,
          )
        ],
      ),
    );
  }

  Widget _buildRoomIdInputBox(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 18.dp,
        left: 20.dp,
        right: 20.dp,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 48.dp,
            ),
            child: Text(
              '会议号',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _roomIdController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                hintText: '请输入会议号',
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white.withOpacity(0.4),
                  decoration: TextDecoration.none,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.dp,
                ),
              ),
              onChanged: (text) {
                text = text.replaceAll(' ', '');
                if (text.length > 6) text = text.substring(0, 6);
                text = text.replaceAllMapped(RegExp(r'(.{3})'), (match) => '${match[0]} ');
                text = text.trim();
                _roomIdController.text = text;
                _roomIdController.selection = TextSelection.collapsed(
                  offset: text.length,
                  affinity: TextAffinity.upstream,
                );
              },
              onEditingComplete: () => _start(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSwitcher(BuildContext context) {
    return '开启摄像头'.toConfigStyleSwitcher(
      value: _config.camera,
      onTap: () => _changeCameraConfig(!_config.camera),
    );
  }

  void _changeCameraConfig(bool open) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _config.camera = open;
    });
  }

  Widget _buildFrontCameraSwitcher(BuildContext context) {
    return '前置摄像头'.toConfigStyleSwitcher(
      value: _config.frontCamera,
      onTap: () => _changeFrontCameraConfig(!_config.frontCamera),
    );
  }

  void _changeFrontCameraConfig(bool front) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _config.frontCamera = front;
    });
  }

  Widget _buildMicSwitcher(BuildContext context) {
    return '开启麦克风'.toConfigStyleSwitcher(
      value: _config.mic,
      onTap: () => _changeMicConfig(!_config.mic),
    );
  }

  void _changeMicConfig(bool open) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _config.mic = open;
    });
  }

  Widget _buildSpeakerSwitcher(BuildContext context) {
    return '开启扬声器'.toConfigStyleSwitcher(
      value: _config.speaker,
      onTap: () => _changeSpeakerConfig(!_config.speaker),
    );
  }

  void _changeSpeakerConfig(bool open) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _config.speaker = open;
    });
  }

  Widget _buildEnableTinyStreamSwitcher(BuildContext context) {
    return '开启小流'.toConfigStyleSwitcher(
      value: _config.enableTinyStream,
      onTap: () => _changeEnableTinyStreamConfig(!_config.enableTinyStream),
    );
  }

  void _changeEnableTinyStreamConfig(bool enable) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _config.enableTinyStream = enable;
    });
  }

  Widget _buildResolutionSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.dp,
        left: 20.dp,
        right: 20.dp,
      ),
      child: ResolutionSelector(
        title: '初始分辨率',
        resolution: _config.resolution,
        onSelected: (resolution) {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            _config.resolution = resolution;
          });
        },
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(32.dp),
        child: GestureDetector(
          child: Container(
            width: double.infinity,
            height: 52.dp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(26.dp),
            ),
            child: Text(
              "进入${ModeStrings[_mode.index]}",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          onTap: () => _start(context),
        ),
      ),
    );
  }

  void _start(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    String rid = _roomIdController.value.text.replaceAll(' ', '');
    if (rid.isNotEmpty && rid.length < 6) return '会议号不能小于6位'.toast(gravity: Gravity.center, duration: Toast.LONG);
    Loading.show(context);
    presenter?.joinRoom(context, _config, rid);
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
    setState(() {
      _showPermissionGuide = false;
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
  void onJoinRoomSuccess(BuildContext context) {
    Loading.dismiss(context);
    _gotoMeeting();
  }

  void _gotoMeeting() {
    Navigator.pushNamed(context, RouterManager.MEETING, arguments: _config.toJSON());
  }

  @override
  void onJoinRoomError(BuildContext context, String info) {
    'Join Room Error, $info'.toast();
    Loading.dismiss(context);
  }

  bool _imConnecting = true;
  bool _showIMConnectError = false;
  bool _showPermissionGuide = false;
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  TextEditingController _roomIdController = TextEditingController();

  Mode _mode = Mode.Meeting;

  Config _config = Config.config();
}
