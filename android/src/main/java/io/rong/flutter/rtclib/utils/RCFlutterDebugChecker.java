package io.rong.flutter.rtclib.utils;

import io.flutter.BuildConfig;

public class RCFlutterDebugChecker {

  public static void throwError(String msg) {
    if (BuildConfig.DEBUG) {
      throw new AssertionError(msg);
    }
  }

  public static boolean notNull(Object obj) {
    if (BuildConfig.DEBUG && obj == null) {
      throw new AssertionError("Assert null failed!");
    }
    return obj != null;
  }

  public static void isTrue(boolean obj) {
    if (BuildConfig.DEBUG && !obj) {
      throw new AssertionError("Assert null failed!");
    }
  }
}
