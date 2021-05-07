package io.rong.flutter.rtclib.agent.room;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.RCRTCUser;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class RCFlutterUser implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL_METHOD = "rong.flutter.rtclib/User:";

  private RCRTCUser user;
  protected MethodChannel methodChannel;

  public RCFlutterUser(BinaryMessenger msg, RCRTCUser user) {
    this.user = user;
    this.methodChannel = new MethodChannel(msg, CHANNEL_METHOD + user.getUserId());
    this.methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {}

  public void release() {
    methodChannel.setMethodCallHandler(null);
  }
}
