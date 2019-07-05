import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class VideoPlayer  {
  static const MethodChannel _channel =
  const MethodChannel('plugins.rongcloud.im/rtc_view_plugin');

  static Widget createPlatformView(String userId) {
    if(TargetPlatform.iOS == defaultTargetPlatform) {
      return UiKitView(
        viewType: 'plugins.rongcloud.im/rtc_view',
        onPlatformViewCreated: (int viewID) {
          
        },
        creationParams: <String,dynamic>{
          "userId":userId,
        },
        creationParamsCodec: new StandardMessageCodec(),
          
      );
    } else if(TargetPlatform.android == defaultTargetPlatform) {
      return AndroidView(
        viewType: 'plugins.rongcloud.im/rtc_view',
        onPlatformViewCreated: (int viewID) {
          
        },
        creationParams: <String,dynamic>{
          "userId":userId,
        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }

    return null;
  }
}