package io.rong.flutter.rtclib.agent.stream;

import cn.rongcloud.rtc.api.stream.RCRTCAudioOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;

public class RCFlutterAudioOutputStream extends RCFlutterOutputStream {
  private static final String TAG = "RCFlutterAudioOutputStream";
  private RCRTCAudioOutputStream audioOutputStream;

  public RCFlutterAudioOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
    super(bMsg, rtcStream);
    RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCAudioOutputStream);
    if (rtcStream instanceof RCRTCAudioOutputStream) {
      audioOutputStream = (RCRTCAudioOutputStream) rtcStream;
    }
  }
}
