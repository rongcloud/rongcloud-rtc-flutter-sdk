package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;

import cn.rongcloud.rtc.api.RCRTCMixConfig;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.stream.RCRTCLiveInfo;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterLiveInfo implements MethodChannel.MethodCallHandler {

  private static final String TAG = "RCFlutterLiveInfo";

  private RCRTCLiveInfo info;
  private MethodChannel channel;

  public RCFlutterLiveInfo(BinaryMessenger bMsg, RCRTCLiveInfo info) {
    this.info = info;
    channel = new MethodChannel(bMsg, "rong.flutter.rtclib/LiveInfo:" + info.getLiveUrl());
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    RCFlutterLog.d(TAG, "onMethodCall: " + call.method);
    switch (call.method) {
      case "addPublishStreamUrl":
          addPublishStreamUrl(call, result);
          break;
      case "removePublishStreamUrl":
          removePublishStreamUrl(call, result);
          break;
      case "setMixConfig":
          setMixConfig(call, result);
          break;
    }
  }

  public String getRoomId() {
    return info.getRoomId();
  }

  public String getLiveUrl() {
    return info.getLiveUrl();
  }

  public String getUserId() {
    return info.getUserId();
  }

  public void addPublishStreamUrl(MethodCall call, MethodChannel.Result result) {
    String url = call.arguments();
    info.addPublishStreamUrl(
        url,
        new IRCRTCResultDataCallback<String[]>() {
          @Override
          public void onSuccess(String[] strings) {
            UIThreadHandler.success(result, strings);
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            result.error(String.valueOf(rtcErrorCode.getValue()), rtcErrorCode.getReason(), null);
          }
        });
  }

  public void removePublishStreamUrl(MethodCall call, MethodChannel.Result result) {
    String url = call.arguments();
    info.removePublishStreamUrl(
        url,
        new IRCRTCResultDataCallback<String[]>() {
          @Override
          public void onSuccess(String[] strings) {
            UIThreadHandler.success(result, strings);
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            result.error(String.valueOf(rtcErrorCode.getValue()), rtcErrorCode.getReason(), null);
          }
        });
  }

  public void setMixConfig(MethodCall call, MethodChannel.Result result) {
    String configStr = call.arguments();

    // todo setLayoutMode, setHostVideoStream, setMediaConfig
    RCRTCMixConfig config = JSON.toJavaObject(JSON.parseObject(configStr), RCRTCMixConfig.class);
    info.setMixConfig(
        config,
        new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
            UIThreadHandler.success(result, null);
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            result.error(String.valueOf(rtcErrorCode.getValue()), rtcErrorCode.getReason(), null);
          }
        });
  }
}
