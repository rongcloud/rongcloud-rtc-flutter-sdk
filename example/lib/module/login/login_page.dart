import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/module/login/login_page_presenter.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:handy_toast/handy_toast.dart';

import 'colors.dart';
import 'login_page_contract.dart';

class LoginPage extends AbstractView {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends AbstractViewState<Presenter, LoginPage> implements View {
  @override
  Presenter createPresenter() {
    return new LoginPagePresenter();
  }

  @override
  void init(BuildContext context) {
    _autoLogin = DefaultData.user.name.isNotEmpty;

    Toast.defaultStyle = ToastStyle(
      color: Colors.black87,
      radius: 2.dp,
      padding: EdgeInsets.all(12.dp),
      style: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildWidgets(context),
            ),
            _buildVersion(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWidgets(BuildContext context) {
    List<Widget> widgets = List();
    widgets.add(_buildTitle());
    if (!_autoLogin) {
      widgets.add(_buildUserIdLabel());
      widgets.add(_buildUserIdInputBox());
      widgets.add(_buildLoginButton(context));
    } else
      widgets.add(_buildLoading());
    return widgets;
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(
        top: 115.0.dp,
        left: 32.0.dp,
        bottom: 80.0.dp,
      ),
      child: Text(
        '欢迎来到 RC-RTC',
        style: TextStyle(
          fontSize: 26.0.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildUserIdLabel() {
    return Padding(
      padding: EdgeInsets.only(
        left: 32.0.dp,
      ),
      child: Text(
        '用户名',
        style: TextStyle(
          fontSize: 20.0.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildUserIdInputBox() {
    return Padding(
      padding: EdgeInsets.only(
        left: 32.0.dp,
        right: 32.0.dp,
      ),
      child: TextField(
        controller: _userNameController,
        keyboardType: TextInputType.name,
        style: TextStyle(
          fontSize: 15.0.sp,
          color: Colors.white.withOpacity(0.4),
          decoration: TextDecoration.none,
        ),
        decoration: InputDecoration(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          hintText: '不少于 8 位英文字母或数字',
          hintStyle: TextStyle(
            fontSize: 15.0.sp,
            color: Colors.white.withOpacity(0.4),
            decoration: TextDecoration.none,
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 20.0.dp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 60.0.dp,
        left: 32.0.dp,
        right: 32.0.dp,
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
            "登陆",
            style: TextStyle(
              fontSize: 16.0.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        onTap: () => _login(context),
      ),
    );
  }

  Widget _buildLoading() {
    return Row(
      children: [
        Spacer(),
        CircularProgressIndicator(),
        Spacer(),
      ],
    );
  }

  Widget _buildVersion() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 20.0.dp),
      child: Text(
        "RC-RTC V$_version",
        style: TextStyle(
          fontSize: 13.0.sp,
          color: ColorConfig.versionTextColor,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    String name = _userNameController.value.text;
    if (name.length < 4) {
      '用户名长度不能少于4个字符.'.toast(gravity: Gravity.bottom);
      return;
    }
    Loading.show(context);
    DefaultData.setUserName(name);
    presenter?.login(context);
  }

  @override
  void onServerVersionLoaded(BuildContext context, String version) {
    _version = version;
    setState(() {});
    if (_autoLogin) presenter?.login(context);
  }

  @override
  void onLoginError(BuildContext context, String info) {
    Loading.dismiss(context);
    info.toast();
  }

  @override
  void onLoginSuccess(BuildContext context) async {
    await precacheImage('home_page_background'.png.assetImage, context);
    Loading.dismiss(context);
    Navigator.pushNamedAndRemoveUntil(context, RouterManager.HOME, (route) => false);
  }

  String _version = '0.0.1';
  bool _autoLogin;
  TextEditingController _userNameController = TextEditingController();
}
