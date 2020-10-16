package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.annotation.JSONField;

import cn.rongcloud.rtc.api.stream.RCRTCCameraOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import cn.rongcloud.rtc.core.CameraVideoCapturer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.agent.view.RCFlutterVideoView;
import io.rong.flutter.rtclib.agent.view.RCFlutterVideoViewFactory;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterCameraOutputStream extends RCFlutterVideoOutputStream {
  private static final String TAG = "RCFlutterCameraOutputStream";
  private RCRTCCameraOutputStream cameraOutputStream;

  public RCFlutterCameraOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
    super(bMsg, rtcStream);
    RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCCameraOutputStream);
    if (rtcStream instanceof RCRTCCameraOutputStream) {
      cameraOutputStream = (RCRTCCameraOutputStream) rtcStream;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    RCFlutterLog.d(TAG, "onMethodCall->" + call.method);
    super.onMethodCall(call, result);
    switch (call.method) {
      case "startCamera":
        startCamera(result);
        break;
      case "stopCamera":
        stopCamera(result);
        break;
      case "switchCamera":
        switchCamera(result);
        break;
      case "enableTinyStream":
        enableTinyStream(call, result);
        break;
    }
  }

  private void startCamera(Result result) {
    cameraOutputStream.startCamera(null);
    UIThreadHandler.success(result, 0);
  }

  private void stopCamera(Result result) {
    cameraOutputStream.stopCamera();
    UIThreadHandler.success(result, 0);
  }

  private void switchCamera(Result result) {
    cameraOutputStream.switchCamera(
        new CameraVideoCapturer.CameraSwitchHandler() {
          @Override
          public void onCameraSwitchDone(boolean b) {
            UIThreadHandler.success(result, cameraOutputStream.isFrontCamera());
          }

          @Override
          public void onCameraSwitchError(String s) {
            UIThreadHandler.success(result, cameraOutputStream.isFrontCamera());
          }
        });
  }

  private void enableTinyStream(MethodCall call, Result result) {
    boolean enabled = (boolean) call.arguments;
    cameraOutputStream.enableTinyStream(enabled);
    UIThreadHandler.success(result, null);
  }

  @JSONField
  public boolean isFrontCamera() {
    return cameraOutputStream.isFrontCamera();
  }

  private void setPreviewMirror(MethodCall call, Result result){
    boolean enabled = (boolean) call.arguments;
    //TODO 临时解决 cameraOutputStream.setPreviewMirror(enabled) 不生效的问题
//    cameraOutputStream.setPreviewMirror(enabled);
    RCFlutterVideoViewFactory.getInstance()
            .getVideoView(viewId)
            .getNativeVideoView()
            .setMirror(enabled);
    UIThreadHandler.success(result, enabled);
  }

  @JSONField
  public boolean isPreviewMirror() {
    return cameraOutputStream.isPreviewMirror();
  }

}
