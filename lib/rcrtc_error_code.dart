class RCRTCErrorCode {
  static const int UnknownError = -1;

  static const int OK = 0;

  /// IM concern.
  static const int ALREADY_CONNECTED = 34001;

  /// RTC concern.
  static const int ALREADY_JOINED = 50002;
}

class RCRTCCodeResult<T> {
  int code;
  String? reason;
  T? object;

  RCRTCCodeResult(this.code, [this.object, this.reason]);
}
