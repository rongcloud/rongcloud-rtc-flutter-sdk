package io.rong.flutter.rtclib.utils;

import android.util.Log;

public final class RCFlutterLog {
  private static final String TAG = "rcrtc@";
  private static final int LOG_V = 1;
  private static final int LOG_D = 2;
  private static final int LOG_I = 3;
  private static final int LOG_W = 4;
  private static final int LOG_E = 5;
  private static final int LOG_N = Integer.MAX_VALUE;
  private static int sLogLevel = LOG_V;

  public static void setLevel(int level) {
    sLogLevel = level;
  }

  public static void v(String tag, String message) {
    if (null != message && sLogLevel <= LOG_V) {
      Log.v(TAG + tag, message);
    }
  }

  public static void d(String tag, String message) {
    if (null != message && sLogLevel <= LOG_D) {
      Log.d(TAG + tag, message);
    }
  }

  public static void i(String tag, String message) {
    if (null != message && sLogLevel <= LOG_I) {
      Log.i(TAG + tag, message);
    }
  }

  public static void w(String tag, String message) {
    if (null != message && sLogLevel <= LOG_W) {
      Log.w(TAG + tag, message);
    }
  }

  public static void e(String tag, String message) {
    if (null != message && sLogLevel <= LOG_E) {
      Log.e(TAG + tag, message);
    }
  }
}
