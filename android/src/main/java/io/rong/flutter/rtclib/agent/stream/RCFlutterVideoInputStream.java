package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.rong.flutter.rtclib.agent.view.RCFlutterTextureView;
import io.rong.flutter.rtclib.agent.view.RCFlutterTextureViewFactory;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

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
      case "setTextureView":
        setTextureView(call, result);
        break;
    }
  }

  protected void setTextureView(MethodCall call, MethodChannel.Result result) {
    int textureId = (int) call.arguments;
    RCFlutterTextureView textureView = RCFlutterTextureViewFactory.getInstance().get(textureId);
    videoInputStream.setTextureView(textureView.getTextureView());
    UIThreadHandler.success(result, null);
  }

}
