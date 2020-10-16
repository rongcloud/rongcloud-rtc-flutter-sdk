import 'package:flutter/material.dart';

class RCRTCDebugChecker {
  static void throwError(String msg) {
    assert(() {
      throw new FlutterError('assert: ' + msg);
    }());
  }

  static void notNull(var value) {
    assert(() {
      if (value == null) {
        throw new FlutterError('assert: Object is null!');
      }
      return true;
    }());
  }

  static void isTrueWithMessage(bool value, String errorMsg) {
    assert(() {
      if (!value) {
        throw new FlutterError('assert: $errorMsg}');
      }
      return true;
    }());
  }

  static void isTrue(bool value) {
    assert(() {
      if (!value) {
        throw new FlutterError('assert: Object is false!');
      }
      return true;
    }());
  }
}
