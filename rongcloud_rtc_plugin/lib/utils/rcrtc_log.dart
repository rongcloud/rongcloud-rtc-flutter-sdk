import 'dart:developer';

class RCRTCLog {
  static const String TAG = "rcrtc@";
  static const int LOG_NONE = 100;
  static const int LOG_ERROR = 5;
  static const int LOG_WARN = 4;
  static const int LOG_INFO = 3;
  static const int LOG_DEBUG = 2;
  static const int LOG_VERBOSE = 1;
  static int sLogLevel = LOG_VERBOSE;

  static void setLevel(int level) {
    sLogLevel = level;
  }

  static void v(String tag, String message) {
    if (null != message && sLogLevel <= LOG_VERBOSE) log('V/' + TAG + tag + ': ' + message);
  }

  static void d(String tag, String message) {
    if (null != message && sLogLevel <= LOG_DEBUG) log('D/' + TAG + tag + ': ' + message);
  }

  static void i(String tag, String message) {
    if (null != message && sLogLevel <= LOG_INFO) log('I/' + TAG + tag + ': ' + message);
  }

  static void w(String tag, String message) {
    if (null != message && sLogLevel <= LOG_WARN) log('W/' + TAG + tag + ': ' + message);
  }

  static void e(String tag, String message) {
    if (null != message && sLogLevel <= LOG_ERROR) log('E/' + TAG + tag + ': ' + message);
  }
}
