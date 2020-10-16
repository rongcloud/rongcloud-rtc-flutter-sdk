package io.rong.flutter.rtclib.agent.stream;

import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;

public class RCFlutterInputStream extends RCFlutterStream {

  public RCFlutterInputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
    super(bMsg, rtcStream);
  }
}
