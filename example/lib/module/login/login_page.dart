import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/module/login/login_page_presenter.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildWidgets(context),
        ),
      ),
    );
  }

  List<Widget> _buildWidgets(BuildContext context) {
    List<Widget> widgets = List();
    if (!_autoLogin) {
      widgets.add(_buildUserIdInputBox());
      widgets.add(_buildLoginButton(context));
    } else
      widgets.add(_buildLoading());
    if (_version != null) widgets.add(_buildVersion());
    return widgets;
  }

  Widget _buildUserIdInputBox() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: TextField(
        controller: _userNameController,
        keyboardType: TextInputType.name,
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          hintText: 'Input User Name',
          hintStyle: TextStyle(fontSize: 15.0),
          contentPadding: EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.0,
        left: 20.0,
        right: 20.0,
      ),
      child: GestureDetector(
        child: Container(
          width: double.infinity,
          height: 45.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            "登陆",
            style: TextStyle(
              fontSize: 15.0,
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
    return CircularProgressIndicator();
  }

  Widget _buildVersion() {
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Text(
        "服务器版本号:$_version",
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    String name = _userNameController.value.text;
    if (name.length < 6) {
      Toast.show(context, "用户名长度不能少于6个字符.");
      return;
    }
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
    Toast.show(context, info);
  }

  @override
  void onLoginSuccess() {
    Navigator.pushNamedAndRemoveUntil(context, RouterManager.HOME, (route) => false);
  }

  String _version;
  bool _autoLogin;
  TextEditingController _userNameController = TextEditingController();
}
