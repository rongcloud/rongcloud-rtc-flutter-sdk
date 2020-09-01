package io.rong.flutter.rtclib.agent.stream;

import cn.rongcloud.rtc.api.stream.RCRTCOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;

public class RCFlutterOutputStream extends RCFlutterStream {

  private static final String TAG = "RCFlutterOutputStream";
  private RCRTCOutputStream outputStream;

  public RCFlutterOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
    super(bMsg, rtcStream);
    RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCOutputStream);
    if (rtcStream instanceof RCRTCOutputStream) {
      outputStream = (RCRTCOutputStream) rtcStream;
    }
  }
}
