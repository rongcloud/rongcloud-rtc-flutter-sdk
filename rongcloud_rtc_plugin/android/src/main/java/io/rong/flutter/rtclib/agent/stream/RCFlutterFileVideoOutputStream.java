package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.stream.RCRTCFileVideoOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;

public class RCFlutterFileVideoOutputStream extends RCFlutterVideoOutputStream {
    private static final String TAG = "RCFlutterFileVideoOutputStream";
    private RCRTCFileVideoOutputStream fileOutputStream;

    public RCFlutterFileVideoOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
        super(bMsg, rtcStream);
        RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCFileVideoOutputStream);
        if (rtcStream instanceof RCRTCFileVideoOutputStream) {
            fileOutputStream = (RCRTCFileVideoOutputStream) rtcStream;
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        RCFlutterLog.d(TAG, "onMethodCall->" + call.method);
        super.onMethodCall(call, result);
        if ("setOnSendListener".equals(call.method)) {
            setOnSendListener(call, result);
        }
    }

    private void setOnSendListener(MethodCall call, Result result) {
        // TODO 未完成
    }
}
