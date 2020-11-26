import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:flutter/widgets.dart';

import 'login_page_contract.dart';

class LoginPageModel extends AbstractModel implements Model {
  @override
  void requestCurrentServerVersion(
    BuildContext context,
    void Function(BuildContext context, String version) onLoaded,
  ) {
    Http.get(
      GlobalConfig.host + '/ver',
      null,
      (error, data) {
        onLoaded(context, data);
      },
      (error) {
        onLoaded(context, '0');
      },
      tag,
    );
  }

  @override
  void login(
    BuildContext context,
    void Function() onLoginSuccess,
    void Function(BuildContext context, String info) onLoginError,
  ) {
    Http.post(
      GlobalConfig.host + '/token/${DefaultData.user.id}',
      null,
      (error, data) {
        Login login = Login.fromJson(data);
        DefaultData.user.token = login.token;
        onLoginSuccess();
      },
      (error) {
        onLoginError(context, '登陆失败');
      },
      tag,
    );
  }
}
