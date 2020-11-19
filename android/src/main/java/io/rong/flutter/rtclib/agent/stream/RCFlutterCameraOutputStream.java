package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.annotation.JSONField;

import cn.rongcloud.rtc.api.stream.RCRTCCameraOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import cn.rongcloud.rtc.core.CameraVideoCapturer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
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
      case "isCameraFocusSupported":
        isCameraFocusSupported(result);
        break;
      case "isCameraExposurePositionSupported":
        isCameraExposurePositionSupported(result);
        break;
      case "setCameraExposurePositionInPreview":
        setCameraExposurePositionInPreview(call, result);
        break;
      case "setCameraFocusPositionInPreview":
        setCameraFocusPositionInPreview(call, result);
        break;
      case "setCameraCaptureOrientation":
        setCameraCaptureOrientation(call, result);
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

  private void isCameraFocusSupported(Result result) {
    boolean supported = cameraOutputStream.isCameraFocusSupported();
    UIThreadHandler.success(result, supported);
  }

  private void isCameraExposurePositionSupported(Result result) {
    boolean supported = cameraOutputStream.isCameraExposurePositionSupported();
    UIThreadHandler.success(result, supported);
  }

  private void setCameraExposurePositionInPreview(MethodCall call, Result result) {
    Float x = call.argument("x");
    Float y = call.argument("y");
    assert x != null && y != null : "setCameraExposurePositionInPreview x y should not be null!!!!";
    boolean success = cameraOutputStream.setCameraExposurePositionInPreview(x, y);
    UIThreadHandler.success(result, success);
  }

  private void setCameraFocusPositionInPreview(MethodCall call, Result result) {
    Float x = call.argument("x");
    Float y = call.argument("y");
    assert x != null && y != null : "setCameraFocusPositionInPreview x y should not be null!!!!";
    boolean success = cameraOutputStream.setCameraFocusPositionInPreview(x, y);
    UIThreadHandler.success(result, success);
  }

  private void setCameraCaptureOrientation(MethodCall call, Result result){
    Integer orientation = call.argument("orientation");
    assert orientation != null : "setCameraCaptureOrientation orientation should not be null!!!!";
    switch (orientation) {
      case 1:
        cameraOutputStream.setCameraDisplayOrientation(180);
        break;
      case 2:
        cameraOutputStream.setCameraDisplayOrientation(270);
        break;
      case 3:
        cameraOutputStream.setCameraDisplayOrientation(90);
        break;
      default:
        cameraOutputStream.setCameraDisplayOrientation(0);
        break;
    }
    UIThreadHandler.success(result, null);
  }

  @JSONField
  public boolean isFrontCamera() {
    return cameraOutputStream.isFrontCamera();
  }

  @JSONField
  public boolean isPreviewMirror() {
    return cameraOutputStream.isPreviewMirror();
  }

}
