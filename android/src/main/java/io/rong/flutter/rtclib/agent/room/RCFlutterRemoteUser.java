package io.rong.flutter.rtclib.agent.room;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import cn.rongcloud.rtc.api.RCRTCRemoteUser;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.stream.RCRTCAudioInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.agent.stream.RCFlutterAudioInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoInputStream;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterRemoteUser extends RCFlutterUser {

    private static final String TAG = "RCFlutterRemoteUser";

    private final RCRTCRemoteUser rtcRemoteUser;
    private final List<RCFlutterInputStream> streamList = new ArrayList<>();

    public RCFlutterRemoteUser(BinaryMessenger msg, RCRTCRemoteUser remoteUser) {
        super(msg, remoteUser);
        rtcRemoteUser = remoteUser;
        for (RCRTCInputStream stream : rtcRemoteUser.getStreams()) {
            if (stream.getMediaType() == RCRTCMediaType.VIDEO) {
                streamList.add(new RCFlutterVideoInputStream(msg, (RCRTCVideoInputStream) stream));
            } else if (stream.getMediaType() == RCRTCMediaType.AUDIO) {
                streamList.add(new RCFlutterAudioInputStream(msg, (RCRTCAudioInputStream) stream));
            }
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        RCFlutterLog.d(TAG, "onMethodCall = " + call.method);
        switch (call.method) {
            case "switchToNormalStream":
                switchToNormalStream(result);
                break;
            case "switchToTinyStream":
                switchToTinyStream(result);
                break;
        }
    }

    private void switchToNormalStream(Result result) {
        rtcRemoteUser.switchToNormalStream(
                new IRCRTCResultCallback() {
                    @Override
                    public void onSuccess() {
                        UIThreadHandler.success(result, null);
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        String errorCode = String.valueOf(rtcErrorCode.getValue());
                        UIThreadHandler.error(result, errorCode, rtcErrorCode.getReason());
                    }
                });
    }

    private void switchToTinyStream(Result result) {
        rtcRemoteUser.switchToTinyStream(
                new IRCRTCResultCallback() {
                    @Override
                    public void onSuccess() {
                        UIThreadHandler.success(result, null);
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        String errorCode = String.valueOf(rtcErrorCode.getValue());
                        UIThreadHandler.error(result, errorCode, rtcErrorCode.getReason());
                    }
                });
    }

    public String getId() {
        return rtcRemoteUser.getUserId();
    }

    public List<RCFlutterInputStream> getStreamList() {
        return streamList;
    }

    @Override
    public void release() {
        super.release();
        for (RCFlutterInputStream stream : streamList) {
            stream.release();
        }
        streamList.clear();
    }
}
