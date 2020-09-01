package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.annotation.JSONField;

import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterStream implements MethodCallHandler {

  private static final String TAG = "RCFlutterStream";

  protected final BinaryMessenger messenger;
  protected final MethodChannel channel;

  private final RCRTCStream rtcStream;

  private boolean mute;

  public RCFlutterStream(BinaryMessenger bMsg, RCRTCStream stream) {
    messenger = bMsg;
    rtcStream = stream;
    channel =
        new MethodChannel(
            messenger,
            "rong.flutter.rtclib/Stream:"
                + rtcStream.getStreamId()
                + "_"
                + rtcStream.getMediaType().getValue());
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    RCFlutterLog.d(TAG, "onMethodCall = " + call.method);
    switch (call.method) {
      case "mute":
        mute(call, result);
        break;
      case "isMute":
        isMute(result);
        break;
      case "getResourceState":
        getResourceState(result);
        break;
      default:
//        result.notImplemented();
        break;
    }
  }

  private void mute(MethodCall call, Result result) {
    boolean mute = (boolean) call.arguments;
    rtcStream.mute(mute);
    UIThreadHandler.success(result, 0);
  }

  private void getResourceState(Result result) {
    int stateValue = rtcStream.getResourceState().getValue();
    UIThreadHandler.success(result, stateValue);
  }

  private void isMute(Result result) {
    UIThreadHandler.success(result, rtcStream.isMute());
  }

  @SuppressWarnings("unused")
  public String getStreamId() {
    return rtcStream.getStreamId();
  }

  public int getType() {
    return rtcStream.getMediaType().getValue();
  }

  @SuppressWarnings("unused")
  public boolean isMute() {
    return rtcStream.isMute();
  }

  public String getTag() {
    return rtcStream.getTag();
  }

  @JSONField(serialize = false)
  public RCRTCStream getRtcStream() {
    return rtcStream;
  }
}
