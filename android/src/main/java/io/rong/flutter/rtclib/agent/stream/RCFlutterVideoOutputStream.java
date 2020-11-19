package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;

import cn.rongcloud.rtc.api.stream.RCRTCVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoStreamConfig;
import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.agent.view.RCFlutterTextureView;
import io.rong.flutter.rtclib.agent.view.RCFlutterTextureViewFactory;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterVideoOutputStream extends RCFlutterOutputStream {

  private static final String TAG = "RCFlutterVideoOutputStream";
  private RCRTCVideoOutputStream videoOutputStream;

  public RCFlutterVideoOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
    super(bMsg, rtcStream);
    RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCVideoOutputStream);
    if (rtcStream instanceof RCRTCVideoOutputStream) {
      videoOutputStream = (RCRTCVideoOutputStream) rtcStream;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    RCFlutterLog.d(TAG, "onMethodCall->" + call.method);
    super.onMethodCall(call, result);
    switch (call.method) {
      case "setVideoConfig":
        setVideoConfig(call, result);
        break;
      case "setTextureView":
        setTextureView(call, result);
        break;
    }
  }

  private void setVideoConfig(MethodCall call, Result result) {
    String jsonStr = (String) call.arguments;
    RCFlutterLog.d(TAG, " setVideoConfig :" + jsonStr);
    RCRTCVideoStreamConfig rcrtcVideoStreamConfig =
        RCRTCVideoStreamConfig.Builder.create()
            .setMaxRate(JSON.parseObject(jsonStr, RCFlutterVideoStreamConfig.class).getMaxRate())
            .setMinRate(JSON.parseObject(jsonStr, RCFlutterVideoStreamConfig.class).getMinRate())
            .setVideoFps(JSON.parseObject(jsonStr, RCFlutterVideoStreamConfig.class).getVideoFps())
            .setVideoResolution(JSON.parseObject(jsonStr, RCFlutterVideoStreamConfig.class).getVideoResolution())
            .build();
    videoOutputStream.setVideoConfig(rcrtcVideoStreamConfig);
    UIThreadHandler.success(result, null);
  }

  protected void setTextureView(MethodCall call, MethodChannel.Result result) {
    int textureId = (int) call.arguments;
    RCFlutterTextureView textureView = RCFlutterTextureViewFactory.getInstance().get(textureId);
    videoOutputStream.setTextureView(textureView.getTextureView());
    UIThreadHandler.success(result, null);
  }
}
