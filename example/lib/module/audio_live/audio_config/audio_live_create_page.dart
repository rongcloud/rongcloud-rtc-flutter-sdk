import 'dart:ui';

import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handy_toast/handy_toast.dart';

import 'audio_live_create_contract.dart';
import 'audio_live_create_presenter.dart';

class AudioLiveCreatePage extends AbstractView {
  @override
  _AudioLiveCreatePage createState() => _AudioLiveCreatePage();
}

class _AudioLiveCreatePage extends AbstractViewState<Presenter, AudioLiveCreatePage> with WidgetsBindingObserver implements View {
  //属性
  Mode _mode = Mode.Audio;

  //是否正在连接
  bool _isConnecting = false;

  //连接失败
  bool _showIMConnectError = false;

  //麦克风权限
  bool _hasMicPermission = false;

  bool _showPermissionGuide = false;

  //上麦需要房主同意
  bool _needHostAllow = true;

  bool _paused = false;

  //房间号
  String _roomId = '';

  //主题
  // String _topic;

  //用户名
  String _userName = DefaultData.user.name;
  TextEditingController _userNameController;
  TextEditingController _roomIdController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userNameController = TextEditingController(text: _userName);
    _roomIdController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !_paused) {
      _paused = true;
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      presenter?.requestMicPermission();
    }
  }

  @override
  Presenter createPresenter() {
    return AudioLiveCreatePresenter();
  }

  void _connectIM() {
    presenter?.connectIM();
    setState(() {
      _isConnecting = true;
    });
  }

  void _start(BuildContext context) {
    if (_roomId == null || _roomId.length <= 0) {
      '请输入房间号'.toast(duration: 2);
      return;
    }
    Loading.show(context);
    presenter?.joinRoom(context, _mode, _roomId);
  }

  @override
  void onIMConnectError() {
    setState(() {
      _isConnecting = false;
      print('IM连接错误');
    });
  }

  @override
  void onIMConnected() {
    presenter?.requestMicPermission();
    setState(() {
      _isConnecting = false;
      print('IM连接成功');
    });
  }

  @override
  void onJoinRoomError(BuildContext context, String info) {
    Loading.dismiss(context);
    info.toast();
  }

  @override
  void onJoinRoomSuccess(BuildContext context) {
    Loading.dismiss(context);
    Navigator.pop(context);
    Navigator.pushNamed(context, RouterManager.AUDIO_LIVE, arguments: {
      'config': _config.toJSON(),
      'needHostAllow': _needHostAllow,
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
  void onMicPermissionGranted() {
    setState(() {
      _hasMicPermission = true;
      _showPermissionGuide = false;
    });
  }

  Widget _buildMicPermissionGuild(BuildContext context) {
    if (_hasMicPermission) {
      return Center(
        child: Text(
          "已有麦克风权限",
          style: TextStyle(
            fontSize: 15.0.sp,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => presenter.requestMicPermission(),
        child: Center(
          child: Text(
            "允许使用麦克风?",
            style: TextStyle(
              fontSize: 15.0.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildIMConnecting(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Padding(padding: EdgeInsets.only(bottom: 10.0.dp)),
          Text(
            '正在连接IM，请稍候',
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

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFF102032),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          brightness: Brightness.dark,
          backgroundColor: Color(0xFFF102032),
          title: Text(
            '音频互动直播',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          leading: 'navigator_back'.toPNGButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                _isConnecting
                    ? _buildIMConnecting(context)
                    : _showIMConnectError
                        ? _buildIMConnectError(context)
                        : _showPermissionGuide
                            ? _buildMicPermissionGuild(context)
                            : _audioRoomForm(context),
              ],
            ),
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            }),
      ),
      onWillPop: () {
        presenter?.exit();
        return Future.value(true);
      },
    );
  }

  Widget _audioRoomForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _customTextField(
            '房间号',
            '房间ID（字母和数字）',
            TextInputType.text,
            _roomIdController,
            (text) {
              _roomId = text;
            },
          ),
          Divider(
            height: 1.dp,
            color: Color(0xFFF1F2F42),
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _customTextField('用户名', '请输入用户名(选填)', TextInputType.text, _userNameController, (text) {
            _userName = text;
          }),
          Divider(
            height: 1.dp,
            color: Color(0xFFF1F2F42),
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          _customSwitch('上麦需要房主同意'),
          Divider(
            height: 1.dp,
            color: Color(0xFFF1F2F42),
            indent: 20.dp,
            endIndent: 20.dp,
          ),
          Spacer(),
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _customTextField(
    String sufixTitle,
    String placeholder,
    TextInputType keyboardType,
    TextEditingController controller,
    void onChange(String text),
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5.dp,
        bottom: 5.dp,
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
              sufixTitle,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              enabled: controller == _roomIdController ? true : false,
              controller: controller,
              onChanged: onChange,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(fontSize: 15.sp, color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.dp),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(18),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customSwitch(String title) {
    return title.toConfigStyleSwitcher(
      value: _needHostAllow,
      onTap: () {
        setState(() {
          _needHostAllow = !_needHostAllow;
        });
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 50.dp,
        left: 30.dp,
        right: 30.dp,
      ),
      child: GestureDetector(
        child: Container(
          width: double.infinity,
          height: 52.0.dp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(26.0.dp),
          ),
          child: Text(
            "创建房间",
            style: TextStyle(
              fontSize: 15.0.sp,
              color: Colors.white,
            ),
          ),
        ),
        onTap: () => _start(context),
      ),
    );
  }

  Config _config = Config.config();
}
