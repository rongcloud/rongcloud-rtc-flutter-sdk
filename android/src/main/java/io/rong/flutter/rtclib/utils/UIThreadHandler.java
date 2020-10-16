package io.rong.flutter.rtclib.utils;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel.Result;

public class UIThreadHandler {
  private static Handler mHandler = new Handler(Looper.getMainLooper());

  public static void success(Result result, Object obj) {
    mHandler.post(
        new Runnable() {
          @Override
          public void run() {
            result.success(obj);
          }
        });
  }

  public static void post(Runnable runnable){
    mHandler.post(runnable);
  }

  public static void error(Result result, String errorCode, String errorMessage) {
    mHandler.post(
        new Runnable() {
          @Override
          public void run() {
            result.error(errorCode, errorMessage, null);
          }
        });
  }
}
