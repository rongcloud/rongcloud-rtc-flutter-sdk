package io.rong.flutter.rtclib.agent.view;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.stream.RCRTCVideoView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class RCFlutterVideoView implements PlatformView, MethodChannel.MethodCallHandler {

  private RCRTCVideoView videoView;

  public RCFlutterVideoView(Context context) {
    videoView = new RCRTCVideoView(context);
    videoView.setLayoutParams(
        new ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
  }

  @Override
  public View getView() {
    return videoView;
  }

  public RCRTCVideoView getNativeVideoView() {
    return videoView;
  }

  @Override
  public void dispose() {}

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {}
}
