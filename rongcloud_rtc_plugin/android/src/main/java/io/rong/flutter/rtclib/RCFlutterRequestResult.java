package io.rong.flutter.rtclib;

/**
 * @author jch
 * @data 20-9-1
 * @time 下午6:09
 */
public class RCFlutterRequestResult<T> {

  private T data;
  private int code;

  public RCFlutterRequestResult(T data, int code) {
    this.data = data;
    this.code = code;
  }

  public T getData() {
    return data;
  }

  public int getCode() {
    return code;
  }
}
