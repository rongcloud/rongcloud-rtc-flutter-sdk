package io.rong.flutter.rtclib.agent.stream;

import cn.rongcloud.rtc.api.stream.RCRTCAudioInputStream;
import io.flutter.plugin.common.BinaryMessenger;

public class RCFlutterAudioInputStream extends RCFlutterInputStream {

  private RCRTCAudioInputStream audioInputStream;

  public RCFlutterAudioInputStream(BinaryMessenger bMsg, RCRTCAudioInputStream stream) {
    super(bMsg, stream);
    audioInputStream = stream;
  }
}
