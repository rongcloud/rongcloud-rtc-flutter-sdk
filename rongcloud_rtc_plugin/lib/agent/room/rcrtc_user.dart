import 'package:flutter/services.dart';

class RCRTCUser {
  final String id;
  final MethodChannel methodChannel;

  RCRTCUser.fromJson(userJson)
      : id = userJson["id"],
        methodChannel = MethodChannel('rong.flutter.rtclib/User:${userJson['id']}');
}
