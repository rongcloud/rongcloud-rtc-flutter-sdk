package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.rong.flutter.rtclib.agent.view.RCFlutterVideoView;
import io.rong.flutter.rtclib.agent.view.RCFlutterVideoViewFactory;

public class RCFlutterVideoInputStream extends RCFlutterInputStream {

  private RCRTCVideoInputStream videoInputStream;

  public RCFlutterVideoInputStream(BinaryMessenger bMsg, RCRTCVideoInputStream stream) {
    super(bMsg, stream);
    videoInputStream = stream;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    super.onMethodCall(call, result);

    switch (call.method) {
      case "setVideoView":
        setVideoView(call, result);
        break;
    }
  }

  protected void setVideoView(MethodCall call, MethodChannel.Result result) {
    int viewId = (int) call.arguments;
    RCFlutterVideoView videoView = RCFlutterVideoViewFactory.getInstance().getVideoView(viewId);
    videoInputStream.setVideoView(videoView.getNativeVideoView());
    result.success(null);
  }
}
