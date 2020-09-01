import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../global_config.dart';

class RcServerApi {
  static Future<RCRTCCodeResult<String>> getToken(String userId) async {
    var url = 'http://api-cn.ronghub.com/user/getToken.json';
    Map<String, String> headers = Map();
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    headers['App-Key'] = GlobalConfig.appKey;
    headers['Nonce'] = Random().nextInt(10000).toString();
    headers['Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    headers['Signature'] = sha1
        .convert(Utf8Encoder().convert(GlobalConfig.appSecret + headers['Nonce'] + headers['Timestamp']).toList())
        .toString();
    http.Response resp = await http.post(url, headers: headers, body: 'userId=' + userId);
    Map<String, dynamic> respJson = json.decode(resp.body);
    return RCRTCCodeResult(respJson['code'], respJson['token']);
  }
}
