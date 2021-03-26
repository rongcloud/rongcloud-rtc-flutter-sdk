package io.rong.flutter.rtclib.agent.room;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import cn.rongcloud.rtc.api.RCRTCEngine;
import cn.rongcloud.rtc.api.RCRTCLocalUser;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.stream.RCRTCCameraOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCLiveInfo;
import cn.rongcloud.rtc.api.stream.RCRTCMicOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RCRTCStream;
import cn.rongcloud.rtc.base.RCRTCStreamType;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.agent.RCFlutterEngine;
import io.rong.flutter.rtclib.agent.stream.RCFlutterCameraOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterLiveInfo;
import io.rong.flutter.rtclib.agent.stream.RCFlutterMicOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterTempStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoOutputStream;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.ThisClassShouldNotBelongHere;
import io.rong.flutter.rtclib.utils.UIThreadHandler;
import io.rong.imlib.model.MessageContent;

public class RCFlutterLocalUser extends RCFlutterUser {

    private static final String TAG = "RCFlutterLocalUser";

    private static final String METHOD_PUB_DEFAULT = "publishDefaultStreams";
    private static final String METHOD_PUB_LIVE_STREAMS = "publishDefaultLiveStreams";
    private static final String METHOD_PUB_LIVE_STREAM = "publishLiveStream";
    private static final String METHOD_PUB_STREAMS = "publishStreams";
    private static final String METHOD_UN_PUB_DEFAULT = "unPublishDefaultStreams";
    private static final String METHOD_UN_PUB_STREAMS = "unPublishStreams";
    private static final String METHOD_SUB_STREAMS = "subscribeStreams";
    private static final String METHOD_UN_SUB_STREAMS = "unsubscribeStreams";
    private static final String METHOD_GET_STREAMS = "getStreams";
    private static final String METHOD_SET_ATTRIBUTE = "setAttributeValue";
    private static final String METHOD_DEL_ATTRIBUTE = "deleteAttributes";
    private static final String METHOD_GET_ATTRIBUTE = "getAttributes";

    private final BinaryMessenger bMsg;
    private final RCRTCLocalUser rtcLocalUser;

    public RCFlutterLocalUser(BinaryMessenger msg, RCRTCLocalUser localUser) {
        super(msg, localUser);
        bMsg = msg;
        rtcLocalUser = localUser;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        RCFlutterLog.d(TAG, "onMethodCall = " + call.method);
        switch (call.method) {
            case METHOD_PUB_DEFAULT:
                publishDefaultStreams(result);
                break;
            case METHOD_PUB_LIVE_STREAMS:
                publishDefaultLiveStreams(result);
                break;
            case METHOD_PUB_LIVE_STREAM:
                publishLiveStream(call, result);
                break;
            case METHOD_PUB_STREAMS:
                publishStreams(call, result);
                break;
            case METHOD_UN_PUB_DEFAULT:
                unPublishDefaultStreams(result);
                break;
            case METHOD_UN_PUB_STREAMS:
                unPublishStreams(call, result);
                break;
            case METHOD_SUB_STREAMS:
                subscribeStreams(call, result);
                break;
            case METHOD_UN_SUB_STREAMS:
                unsubscribeStreams(call, result);
                break;
            case METHOD_GET_STREAMS:
                getStreams(result);
                break;
            case METHOD_SET_ATTRIBUTE:
                setAttributeValue(call, result);
                break;
            case METHOD_DEL_ATTRIBUTE:
                deleteAttributes(call, result);
                break;
            case METHOD_GET_ATTRIBUTE:
                getAttributes(call, result);
                break;
        }
    }

    public String getId() {
        return rtcLocalUser.getUserId();
    }

    private void publishDefaultStreams(final Result result) {
        rtcLocalUser.publishDefaultStreams(
                new IRCRTCResultCallback() {
                    @Override
                    public void onSuccess() {
                        UIThreadHandler.success(result, 0);
                    }

                    @Override
                    public void onFailed(RTCErrorCode code) {
                        UIThreadHandler.success(result, code.getValue());
                    }
                });
    }

    private void publishDefaultLiveStreams(final Result result) {
        rtcLocalUser.publishDefaultLiveStreams(
                new IRCRTCResultDataCallback<RCRTCLiveInfo>() {
                    @Override
                    public void onSuccess(RCRTCLiveInfo info) {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("code", 0);
                        jsonObject.put("content", JSON.toJSONString(new RCFlutterLiveInfo(bMsg, info)));
                        UIThreadHandler.success(result, jsonObject.toJSONString());
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("code", rtcErrorCode.getValue());
                        jsonObject.put("content", rtcErrorCode.getReason());
                        UIThreadHandler.success(result, jsonObject.toJSONString());
                    }
                });
    }

    private void publishLiveStream(MethodCall call, Result result) {
        List<String> jsonStreams = Collections.singletonList((String) call.arguments);
        List<RCRTCOutputStream> streams = mapRTCOutputStreams(jsonStreams);
        if (!streams.isEmpty()) {
            rtcLocalUser.publishLiveStream(
                    streams.get(0),
                    new IRCRTCResultDataCallback<RCRTCLiveInfo>() {
                        @Override
                        public void onSuccess(RCRTCLiveInfo info) {
                            JSONObject jsonObject = new JSONObject();
                            jsonObject.put("code", 0);
                            jsonObject.put("content", JSON.toJSONString(new RCFlutterLiveInfo(bMsg, info)));
                            UIThreadHandler.success(result, jsonObject.toJSONString());
                        }

                        @Override
                        public void onFailed(RTCErrorCode rtcErrorCode) {
                            JSONObject jsonObject = new JSONObject();
                            jsonObject.put("code", rtcErrorCode.getValue());
                            jsonObject.put("content", rtcErrorCode.getReason());
                            UIThreadHandler.success(result, jsonObject.toJSONString());
                        }
                    });
        } else {
            RCFlutterLog.e(TAG, "arguments:" + call.arguments);
        }
    }

    private void publishStreams(MethodCall call, Result result) {
        List<String> jsonStreams = (List<String>) call.arguments;
        List<RCRTCOutputStream> rtcStreams = mapRTCOutputStreams(jsonStreams);
        rtcLocalUser.publishStreams(
                rtcStreams,
                new IRCRTCResultCallback() {
                    @Override
                    public void onSuccess() {
                        UIThreadHandler.success(result, 0);
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        UIThreadHandler.success(result, rtcErrorCode.getValue());
                    }
                });
    }

    private void unPublishDefaultStreams(Result result) {
        rtcLocalUser.unpublishDefaultStreams(
                new IRCRTCResultCallback() {
                    @Override
                    public void onSuccess() {
                        UIThreadHandler.success(result, 0);
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        UIThreadHandler.success(result, rtcErrorCode.getValue());
                    }
                });
    }

    private void unPublishStreams(MethodCall call, Result result) {
        List<String> jsonStreams = (List<String>) call.arguments;
        List<RCRTCOutputStream> rtcStreams = mapRTCOutputStreams(jsonStreams);
        rtcLocalUser.unpublishStreams(
                rtcStreams,
                new IRCRTCResultCallback() {
                    @Override
                    public void onSuccess() {
                        UIThreadHandler.success(result, 0);
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        UIThreadHandler.success(result, rtcErrorCode.getValue());
                    }
                });
    }

    private List<RCRTCOutputStream> mapRTCOutputStreams(List<String> jsonStreams) {
        RCRTCEngine rtcEngine = RCRTCEngine.getInstance();
        RCRTCCameraOutputStream cameraOutputStream = rtcEngine.getDefaultVideoStream();
        RCRTCMicOutputStream micOutputStream = rtcEngine.getDefaultAudioStream();

        List<RCRTCOutputStream> rtcStreams = new ArrayList<>();
        for (String jsonStream : jsonStreams) {
            JSONObject stream = JSON.parseObject(jsonStream);
            String streamId = stream.getString("streamId");
            int type = stream.getIntValue("type");
            RCRTCMediaType mediaType = RCRTCMediaType.getMediaType(type);

            if (TextUtils.equals(cameraOutputStream.getStreamId(), streamId) && cameraOutputStream.getMediaType() == mediaType) {
                rtcStreams.add(cameraOutputStream);
                continue;
            }

            if (TextUtils.equals(micOutputStream.getStreamId(), streamId) && micOutputStream.getMediaType() == mediaType) {
                rtcStreams.add(micOutputStream);
                continue;
            }

            RCFlutterVideoOutputStream flutterStream = RCFlutterEngine.getInstance().getFlutterVideoOutputStream(streamId, type);
            if (flutterStream != null) {
                rtcStreams.add((RCRTCOutputStream) flutterStream.getRtcStream());
            }
        }
        return rtcStreams;
    }

    private void subscribeStreams(MethodCall call, Result result) {
        String streamListJson = call.argument("streams");
        boolean tiny = call.argument("tiny");
        List<RCFlutterTempStream> tempStreams = JSONArray.parseArray(streamListJson, RCFlutterTempStream.class);
        ArrayList<RCFlutterInputStream> inputStreamList = RCFlutterEngine.getInstance().getAllInputStreamList();
        ArrayList<RCRTCInputStream> targetStreamList = new ArrayList<>();
        for (RCFlutterTempStream tempStream : tempStreams) {
            for (RCFlutterInputStream inputStream : inputStreamList) {
                if (tempStream.getStreamId().equals(inputStream.getStreamId()) && tempStream.getType() == inputStream.getType()) {
                    RCRTCStream stream = inputStream.getRtcStream();
                    if (stream instanceof RCRTCVideoInputStream) {
                        if (tiny) {
                            ((RCRTCVideoInputStream) stream).setStreamType(RCRTCStreamType.TINY);
                        } else {
                            ((RCRTCVideoInputStream) stream).setStreamType(RCRTCStreamType.NORMAL);
                        }
                    }
                    targetStreamList.add((RCRTCInputStream) stream);
                    break;
                }
            }
        }

        if (targetStreamList.size() != tempStreams.size()) { // todo 异步会怎样？
            RCFlutterDebugChecker.throwError("target stream not found!");
            UIThreadHandler.success(result, -1);
        }

        if (targetStreamList.size() != 0) {
            rtcLocalUser.subscribeStreams(
                    targetStreamList,
                    new IRCRTCResultCallback() {
                        @Override
                        public void onSuccess() {
                            UIThreadHandler.success(result, 0);
                        }

                        @Override
                        public void onFailed(RTCErrorCode code) {
                            UIThreadHandler.success(result, code.getValue());
                        }
                    });
        }
    }

    private void unsubscribeStreams(MethodCall call, Result result) {
        String streamListJson = (String) call.arguments;
        List<RCFlutterTempStream> tempStreams = JSONArray.parseArray(streamListJson, RCFlutterTempStream.class);

        ArrayList<RCFlutterInputStream> inputStreamList = RCFlutterEngine.getInstance().getAllInputStreamList();

        ArrayList<RCRTCInputStream> targetStreamList = new ArrayList<>();
        for (RCFlutterTempStream tempStream : tempStreams) {
            for (RCFlutterInputStream inputStream : inputStreamList) {
                if (tempStream.getStreamId().equals(inputStream.getStreamId()) && tempStream.getType() == inputStream.getType()) {
                    targetStreamList.add((RCRTCInputStream) inputStream.getRtcStream());
                    break;
                }
            }
        }

        if (targetStreamList.size() != tempStreams.size()) { // todo 异步会怎样？
            RCFlutterDebugChecker.throwError("target stream not found!");
            UIThreadHandler.success(result, -1);
        }

        if (targetStreamList.size() != 0) {
            rtcLocalUser.unsubscribeStreams(
                    targetStreamList,
                    new IRCRTCResultCallback() {
                        @Override
                        public void onSuccess() {
                            UIThreadHandler.success(result, 0);
                        }

                        @Override
                        public void onFailed(RTCErrorCode code) {
                            UIThreadHandler.success(result, code.getValue());
                        }
                    });
        }
    }

    private void getStreams(Result result) {
        List<RCRTCOutputStream> streams = rtcLocalUser.getStreams();
        List<String> jsonStreams = new ArrayList<>(streams.size());
        for (RCRTCOutputStream stream : streams) {
            RCFlutterOutputStream flutterOutputStream;
            if (stream instanceof RCRTCMicOutputStream) {
                flutterOutputStream = new RCFlutterMicOutputStream(bMsg, stream);
            } else if (stream instanceof RCRTCCameraOutputStream) {
                flutterOutputStream = new RCFlutterCameraOutputStream(bMsg, stream);
            } else {
                RCFlutterLog.e(TAG, "Need to add unknown type : " + stream.getClass());
                continue;
            }
            jsonStreams.add(JSON.toJSONString(flutterOutputStream));
        }
        UIThreadHandler.success(result, jsonStreams);
    }

    private void setAttributeValue(MethodCall call, Result result) {
        String key = call.argument("key");
        String value = call.argument("value");
        String object = call.argument("object");
        String content = call.argument("content");
        assert object != null : "setAttributeValue object should not be null!!!";
        MessageContent message = ThisClassShouldNotBelongHere.getInstance().string2MessageContent(object, content);
        rtcLocalUser.setAttributeValue(key, value, message, new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
                UIThreadHandler.success(result, 0);
            }

            @Override
            public void onFailed(RTCErrorCode errorCode) {
                UIThreadHandler.success(result, errorCode.getValue());
            }
        });
    }

    private void deleteAttributes(MethodCall call, Result result) {
        List<String> keys = JSONArray.parseArray(call.argument("keys"), String.class);
        String object = call.argument("object");
        String content = call.argument("content");
        assert object != null : "deleteAttributes object should not be null!!!";
        MessageContent message = ThisClassShouldNotBelongHere.getInstance().string2MessageContent(object, content);
        rtcLocalUser.deleteAttributes(keys, message, new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
                UIThreadHandler.success(result, 0);
            }

            @Override
            public void onFailed(RTCErrorCode errorCode) {
                UIThreadHandler.success(result, errorCode.getValue());
            }
        });
    }

    private void getAttributes(MethodCall call, Result result) {
        List<String> keys = JSONArray.parseArray(call.argument("keys"), String.class);
        rtcLocalUser.getAttributes(keys, new IRCRTCResultDataCallback<Map<String, String>>() {
            @Override
            public void onSuccess(Map<String, String> data) {
                UIThreadHandler.success(result, data);
            }

            @Override
            public void onFailed(Map<String, String> data, RTCErrorCode errorCode) {
                super.onFailed(data, errorCode);
                UIThreadHandler.success(result, data);
            }

            @Override
            public void onFailed(RTCErrorCode errorCode) {
            }
        });
    }

}
