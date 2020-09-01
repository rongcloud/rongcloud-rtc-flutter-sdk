import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_config.dart';
import 'utils/rc_server_api.dart';
import 'video_chat_page.dart';
import 'widgets/loading_dialog.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _loginUserId = 'login_user_id';
  static const String _loginToken = 'login_token';
  static const String _loginRoomId = 'login_room_id';
  static const String _loginIsLive = 'login_is_live';
  static const String _loginIsDebug = 'login_is_debug';
  static const String _loginISLivePub = "login_is_live_pub";

  TextEditingController userIdEdit = TextEditingController();
  TextEditingController roomIdEdit = TextEditingController();
  bool isLiveMode = false;
  bool _isLivePub = true;
  bool isDebugMode = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      setState(() {
        userIdEdit.text = prefs.getString(_loginUserId) ?? '';
        roomIdEdit.text = prefs.getString(_loginRoomId) ?? '';
        isLiveMode = prefs.getBool(_loginIsLive) ?? false;
        isDebugMode = prefs.getBool(_loginIsDebug) ?? false;
        _isLivePub = prefs.getBool(_loginISLivePub) ?? true;
      });
    });
    RCRTCEngine.getInstance().init(null);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 375, height: 667);
    return Scaffold(
      appBar: AppBar(title: Text(GlobalConfig.appTitle)),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'User Id'),
            controller: userIdEdit,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          TextField(
            decoration: InputDecoration(labelText: 'Room Id'),
            controller: roomIdEdit,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          // Row(
          //   children: <Widget>[
          //     Text('Live Mode:'),
          //     Switch(
          //       value: isLiveMode,
          //       onChanged: (value) {
          //         setState(() => isLiveMode = value);
          //         prefs.setBool(_loginIsLive, value);
          //       },
          //     ),
          //     Spacer(),
          //     Text('Debug Mode:'),
          //     Switch(
          //       value: isDebugMode,
          //       onChanged: (value) {
          //         setState(() => isDebugMode = value);
          //         prefs.setBool(_loginIsDebug, value);
          //       },
          //     ),
          //   ],
          // ),
          isLiveMode
              ? Row(
                  children: <Widget>[
                    Text("Publish Video"),
                    Switch(
                      value: _isLivePub,
                      onChanged: (value) {
                        setState(() => _isLivePub = value);
                        prefs.setBool(_loginISLivePub, value);
                      },
                    )
                  ],
                )
              : Row(),
          SizedBox(
            height: ScreenUtil().setWidth(45),
            width: double.infinity,
            child: RaisedButton(
              onPressed: isLiveMode ? _handleToLivePage() : _handleJoinRTCRoom(),
              child: Text(_makeLoginBtnText()),
            ),
          ),
        ]),
      ),
    );
  }

  String _makeLoginBtnText() {
    String loginBtnText = "Join RTC Room";
    if (isLiveMode) {
      if (_isLivePub)
        loginBtnText = "Publish Live Video";
      else
        loginBtnText = "Observe Live Video";
    } else {
      loginBtnText = "Join RTC Room";
    }
    return loginBtnText;
  }

  _handleJoinRTCRoom() {
    if (userIdEdit.text.trim().length == 0 || roomIdEdit.text.trim().length == 0) {
      return null;
    }
    return () async {
      await _handlePermission();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(text: 'Joining Room ...'),
      );
      if (await RongIMClient.getConnectionStatus() == 0) {
        var joinResult = await RCRTCEngine.getInstance().joinRoom(roomIdEdit.text.trim());
        if (joinResult.code == 0) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoChatPage(isDebugMode)));
        } else {
          Navigator.pop(context);
          _showErrorDialog('Join room failed: code = ${joinResult.code.toString()}');
          return;
        }
      } else {
        String userId = userIdEdit.text.trim();
        String token = prefs.getString(_loginToken);
        if (userId != prefs.getString(_loginUserId)) {
          var tokenResult = await RcServerApi.getToken(userIdEdit.text.trim());
          if (tokenResult.code == 200) {
            token = tokenResult.object;
          } else {
            Navigator.pop(context);
            _showErrorDialog('Get token error: code = ${tokenResult.code.toString()}');
            return;
          }
        }
        RongIMClient.connect(token, (int code, String userId) async {
          if (code != RCRTCErrorCode.OK && code != RCRTCErrorCode.ALREADY_CONNECTED) {
            Navigator.pop(context);
            _showErrorDialog('Connect failed: code = ${code.toString()}');
            return;
          }
          if (code == RCRTCErrorCode.OK) {
            prefs.setString(_loginUserId, userIdEdit.text.trim());
            prefs.setString(_loginRoomId, roomIdEdit.text.trim());
            prefs.setString(_loginToken, token);
          }
          var joinResult = await RCRTCEngine.getInstance().joinRoom(roomIdEdit.text.trim());
          if (joinResult.code == 0) {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoChatPage(isDebugMode)));
          } else {
            Navigator.pop(context);
            _showErrorDialog('Join room failed: code = ${joinResult.code.toString()}');
            return;
          }
        });
      }
    };
  }

  _handleToLivePage() {
    if (userIdEdit.text.trim().length == 0 || roomIdEdit.text.trim().length == 0) {
      return null;
    }
  }

  Future<void> _handlePermission() async {
    [Permission.camera, Permission.microphone, Permission.speech, Permission.storage].toList().request();
  }

  _showErrorDialog(content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
