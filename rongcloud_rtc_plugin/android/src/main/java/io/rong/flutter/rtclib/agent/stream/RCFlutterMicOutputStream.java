package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.stream.RCRTCMicOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;

public class RCFlutterMicOutputStream extends RCFlutterAudioOutputStream {

  private static final String TAG = "RCFlutterMicOutputStream";
  private RCRTCMicOutputStream rtcMicOutputStream;

  public RCFlutterMicOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
    super(bMsg, rtcStream);
    RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCMicOutputStream);
    if (rtcStream instanceof RCRTCMicOutputStream) {
      rtcMicOutputStream = (RCRTCMicOutputStream) rtcStream;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    super.onMethodCall(call, result);
    switch (call.method) {
      case "setMicrophoneDisable":
        setMicrophoneDisable(call, result);
        return;
      default:
//        RCFlutterDebugChecker.throwError("Need to add method handler!");
    }
  }

  private void setMicrophoneDisable(MethodCall call, Result result) {
    boolean disable = (boolean) call.arguments;
    rtcMicOutputStream.setMicrophoneDisable(disable);
    result.success(null);
  }

  public boolean getMute() {
    return rtcMicOutputStream.isMute();
  }

  @SuppressWarnings("unused")
  public boolean getState() {
    return rtcMicOutputStream.isMicrophoneDisable();
  }
}
