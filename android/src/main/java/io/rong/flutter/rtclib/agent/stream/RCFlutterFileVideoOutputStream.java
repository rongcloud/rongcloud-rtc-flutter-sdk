package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.callback.IRCRTCOnStreamSendListener;
import cn.rongcloud.rtc.api.stream.RCRTCFileVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoOutputStream;
import cn.rongcloud.rtc.base.RCRTCStream;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterFileVideoOutputStream extends RCFlutterVideoOutputStream {
    private static final String TAG = "RCFlutterFileVideoOutputStream";
    private RCRTCFileVideoOutputStream fileOutputStream;

    public RCFlutterFileVideoOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
        super(bMsg, rtcStream);
        RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCFileVideoOutputStream);
        if (rtcStream instanceof RCRTCFileVideoOutputStream) {
            fileOutputStream = (RCRTCFileVideoOutputStream) rtcStream;
            fileOutputStream.setOnSendListener(onStreamSendListener);
        }
    }

    private final IRCRTCOnStreamSendListener onStreamSendListener = new IRCRTCOnStreamSendListener() {
        @Override
        public void onStart(RCRTCVideoOutputStream rcrtcVideoOutputStream) {
            UIThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                    channel.invokeMethod("onStart", null);
                }
            });
        }

        @Override
        public void onComplete(RCRTCVideoOutputStream rcrtcVideoOutputStream) {
            UIThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                    channel.invokeMethod("onComplete", null);
                }
            });
        }

        @Override
        public void onFailed() {
            UIThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                    channel.invokeMethod("onFailed", null);
                }
            });
        }
    };
}
