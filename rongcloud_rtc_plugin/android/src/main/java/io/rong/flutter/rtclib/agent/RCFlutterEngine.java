package io.rong.flutter.rtclib.agent;

import android.content.Context;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import cn.rongcloud.rtc.api.RCRTCConfig;
import cn.rongcloud.rtc.api.RCRTCEngine;
import cn.rongcloud.rtc.api.RCRTCRoom;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCStatusReportListener;
import cn.rongcloud.rtc.api.callback.RCRTCLiveCallback;
import cn.rongcloud.rtc.api.report.StatusReport;
import cn.rongcloud.rtc.api.stream.RCRTCAudioInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCFileVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoStreamConfig;
import cn.rongcloud.rtc.base.RCRTCAVStreamType;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RCRTCParamsType;
import cn.rongcloud.rtc.base.RCRTCRoomType;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.common.RLog;
import io.rong.flutter.rtclib.RCFlutterRequestResult;
import io.rong.flutter.rtclib.agent.room.RCFlutterRemoteUser;
import io.rong.flutter.rtclib.agent.room.RCFlutterRoom;
import io.rong.flutter.rtclib.agent.room.RCFlutterRoomType;
import io.rong.flutter.rtclib.agent.stream.RCFlutterCameraOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterFileVideoOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterMicOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoOutputStream;
import io.rong.flutter.rtclib.agent.view.RCFlutterVideoViewFactory;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterEngine extends IRCRTCStatusReportListener implements MethodCallHandler {

    private static final String TAG = "RCFlutterEngine";

    private static final String ASSETS_PREFIX = "file:///android_asset/";
    private BinaryMessenger bMsg;
    private HashMap<String, RCFlutterRoom> roomMap = new HashMap<>();
    private RCFlutterCameraOutputStream cameraOutputStream;
    private RCFlutterMicOutputStream micOutputStream;
    // key => (streamId + "_" + type)
    private Map<String, RCFlutterVideoOutputStream> createdVideoOutputStreams;
    private Context context;
    private MethodChannel channel;
    private FlutterPlugin.FlutterAssets flutterAssets;

    private static class SingletonHolder {

        private static final RCFlutterEngine instance = new RCFlutterEngine();
    }

    private RCFlutterEngine() {
        createdVideoOutputStreams = new HashMap<>();
    }

    public static RCFlutterEngine getInstance() {
        return SingletonHolder.instance;
    }

    public void init(
            Context context, BinaryMessenger msg, FlutterPlugin.FlutterAssets flutterAssets) {
        bMsg = msg;
        this.context = context;
        this.flutterAssets = flutterAssets;
        channel = new MethodChannel(bMsg, "rong.flutter.rtclib/engine");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "init":
                init(call, result);
                break;
            case "unInit":
                unInit(call, result);
                break;
            case "joinRoom":
                joinRoom(call, result);
                break;
            case "leaveRoom":
                leaveRoom(result);
                break;
            case "getDefaultVideoStream":
                getDefaultVideoStream(result);
                break;
            case "getDefaultAudioStream":
                getDefaultAudioStream(result);
                break;
            case "createVideoOutputStream":
                createVideoOutputStream(call, result);
                break;
            case "subscribeLiveStream":
                subscribeLiveStream(call, result);
                break;
            case "unsubscribeLiveStream":
                unsubscribeLiveStream(call, result);
                break;
            case "mediaServerUrl":
                setMediaServerUrl(call, result);
                break;
            case "enableSpeaker":
                enableSpeaker(call, result);
                break;
            case "registerStatusReportListener":
                registerReportStatusListener();
                break;
            case "unRegisterStatusReportListener":
                unRegisterReportStatusListener();
                break;
            case "releaseVideoView":
                releaseVideoView(call, result);
                break;
            case "createFileVideoOutputStream":
                createFileVideoOutputStream(call, result);
                break;
            default:
                result.notImplemented();
        }
    }

    private void init(MethodCall call, Result result) {
        RCRTCConfig config = RCRTCConfig.Builder.create().build();
        RLog.d(TAG, "init: ");
        RCRTCEngine.getInstance().init(context, config);
        UIThreadHandler.success(result, 0);
    }

    private void unInit(MethodCall call, Result result) {
        RLog.d(TAG, "unInit: ");
        RCRTCEngine.getInstance().unInit();
        UIThreadHandler.success(result, 0);
    }

    private void enableSpeaker(MethodCall call, Result result) {
        boolean enableSpeaker = (boolean) call.arguments;
        RCRTCEngine.getInstance().enableSpeaker(enableSpeaker);
        UIThreadHandler.success(result, 0);
    }

    private void joinRoom(MethodCall call, Result result) {
        String roomId = call.argument("roomId");
        HashMap<String, Integer> roomConfigMap = call.argument("roomConfig");
        RCRTCRoomType roomType = RCFlutterRoomType.from(roomConfigMap).nativeRoomType();
        RCRTCEngine.getInstance().joinRoom(
                roomId,
                roomType,
                new IRCRTCResultDataCallback<RCRTCRoom>() {
                    @Override
                    public void onSuccess(RCRTCRoom rtcRoom) {
                        RCFlutterLog.v(TAG, "joinRoom onSuccess");
                        RCFlutterRoom room = new RCFlutterRoom(bMsg, rtcRoom);
                        roomMap.put(room.getId(), room);
                        RCFlutterRequestResult<RCFlutterRoom> requestResult = new RCFlutterRequestResult<>(room, 0);
                        UIThreadHandler.success(result, JSONObject.toJSON(requestResult).toString());
                    }

                    @Override
                    public void onFailed(RTCErrorCode code) {
                        RCFlutterLog.v(TAG, "joinRoom onFailed code = " + code);
                        RCFlutterRequestResult<String> requestResult = new RCFlutterRequestResult<>(code.getReason(), code.getValue());
                        UIThreadHandler.success(result, JSONObject.toJSON(requestResult.toString()));
                    }
                });
    }

    private void leaveRoom(Result result) {
        RLog.d(TAG, "leaveRoom");
        RCRTCEngine.getInstance().leaveRoom(new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
                RCRTCEngine.getInstance().unInit();
                RCFlutterLog.v(TAG, "leaveRoom onSuccess");
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("code", 0);
                UIThreadHandler.success(result, jsonObject.toJSONString());
            }

            @Override
            public void onFailed(RTCErrorCode rtcErrorCode) {
                RCFlutterLog.v(TAG, "leaveRoom onFailed");
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("code", rtcErrorCode.getValue());
                UIThreadHandler.success(result, jsonObject.toJSONString());
            }
        });

        cameraOutputStream = null;
        micOutputStream = null;
    }

    private void getDefaultVideoStream(Result result) {
        RLog.d(TAG, "getDefaultVideoStream: ");
        if (cameraOutputStream == null)
            cameraOutputStream = new RCFlutterCameraOutputStream(bMsg, RCRTCEngine.getInstance().getDefaultVideoStream());
        UIThreadHandler.success(result, JSON.toJSONString(cameraOutputStream));
    }

    private void getDefaultAudioStream(Result result) {
        RLog.d(TAG, "getDefaultAudioStream: ");
        if (micOutputStream == null)
            micOutputStream = new RCFlutterMicOutputStream(bMsg, RCRTCEngine.getInstance().getDefaultAudioStream());
        UIThreadHandler.success(result, JSON.toJSONString(micOutputStream));
    }

    private void createVideoOutputStream(MethodCall call, Result result) {
        String tag = (String) call.arguments;
        RCRTCVideoOutputStream stream = RCRTCEngine.getInstance().createVideoStream(tag, null);
        RCFlutterVideoOutputStream flutterStream = new RCFlutterVideoOutputStream(bMsg, stream);
        String uid = flutterStream.getStreamId() + "_" + flutterStream.getType();
        createdVideoOutputStreams.put(uid, flutterStream);
        UIThreadHandler.success(result, JSON.toJSONString(flutterStream));
    }

    private void subscribeLiveStream(MethodCall call, Result result) {
        String url = call.argument("url");
        int type = call.argument("type");
        RCRTCAVStreamType streamType = Objects.requireNonNull(RCRTCAVStreamType.class.getEnumConstants())[type];
        RCRTCEngine.getInstance().subscribeLiveStream(url, streamType, new RCRTCLiveCallback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onVideoStreamReceived(RCRTCVideoInputStream rcrtcVideoInputStream) {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("callback", "success");
                jsonObject.put("stream", JSON.toJSONString(new RCFlutterVideoInputStream(bMsg, rcrtcVideoInputStream)));
                UIThreadHandler.success(result, jsonObject.toJSONString());
            }

            @Override
            public void onAudioStreamReceived(RCRTCAudioInputStream rcrtcAudioInputStream) {

            }

            @Override
            public void onFailed(RTCErrorCode rtcErrorCode) {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("callback", "failed");
                jsonObject.put("code", rtcErrorCode.getValue());
                jsonObject.put("message", rtcErrorCode.getReason());
                UIThreadHandler.success(result, jsonObject.toJSONString());
            }
        });
    }

    private void unsubscribeLiveStream(MethodCall call, Result result) {
        String url = (String) call.arguments;
        RCRTCEngine.getInstance().unsubscribeLiveStream(url, new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
                JSONObject json = new JSONObject();
                json.put("code", 0);
                UIThreadHandler.success(result, json.toJSONString());
            }

            @Override
            public void onFailed(RTCErrorCode rtcErrorCode) {
                JSONObject json = new JSONObject();
                json.put("code", rtcErrorCode.getValue());
                UIThreadHandler.success(result, json.toJSONString());
            }
        });
    }

    private void setMediaServerUrl(MethodCall call, Result result) {
        String serverUrl = (String) call.arguments;
        RCRTCEngine.getInstance().setMediaServerUrl(serverUrl);
        UIThreadHandler.success(result, null);
    }

    private void createFileVideoOutputStream(MethodCall call, Result result) {
        String fileName = call.argument("path");
        String tag = call.argument("tag");
        boolean replace = call.argument("replace");
        boolean playback = call.argument("playback");
        RCRTCVideoStreamConfig config =
                RCRTCVideoStreamConfig.Builder.create().
                        setMinRate(50).
                        setMaxRate(500).
                        setVideoFps(RCRTCParamsType.RCRTCVideoFps.Fps_24).
                        setVideoResolution(RCRTCParamsType.RCRTCVideoResolution.RESOLUTION_480_640).build();
        String path = ASSETS_PREFIX + flutterAssets.getAssetFilePathByName(fileName);
        RCRTCFileVideoOutputStream stream =
                RCRTCEngine.getInstance().createFileVideoOutputStream(path, replace, playback, tag, config);
        RCFlutterFileVideoOutputStream flutterStream = new RCFlutterFileVideoOutputStream(bMsg, stream);
        String uid = flutterStream.getStreamId() + "_" + flutterStream.getType();
        createdVideoOutputStreams.put(uid, flutterStream);
        UIThreadHandler.success(result, JSON.toJSONString(flutterStream));
    }

    private void registerReportStatusListener() {
        RCRTCEngine.getInstance().registerStatusReportListener(this);
    }

    private void unRegisterReportStatusListener() {
        RCRTCEngine.getInstance().unregisterStatusReportListener();
    }

    // todo to be effect.
    public ArrayList<RCFlutterInputStream> getAllInputStreamList() {
        ArrayList<RCFlutterInputStream> streamList = new ArrayList<>();
        ArrayList<RCFlutterRoom> roomList = new ArrayList<>(roomMap.values());
        for (RCFlutterRoom room : roomList) {
            for (RCFlutterRemoteUser remoteUser : room.getRemoteUserList()) {
                streamList.addAll(remoteUser.getStreamList());
            }
        }
        return streamList;
    }

    public RCFlutterVideoOutputStream getFlutterVideoOutputStream(String streamid, int type) {
        return createdVideoOutputStreams.get(makeStreamTypeId(streamid, type));
    }

    private String makeStreamTypeId(String streamId, int type) {
        return streamId + "_" + type;
    }

    private void releaseVideoView(MethodCall call, Result result) {
        RLog.d(TAG, "releaseVideoView: ");
        int viewId = (int) call.arguments;
        RCFlutterVideoViewFactory.getInstance().releaseVideoView(viewId);
        UIThreadHandler.success(result, null);
    }

    @Override
    public void onAudioReceivedLevel(HashMap<String, String> hashMap) {
        UIThreadHandler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod("onAudioReceivedLevel", hashMap);
                    }
                });
    }

    @Override
    public void onAudioInputLevel(String level) {
        UIThreadHandler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod("onAudioInputLevel", level);
                    }
                });
    }

    @Override
    public void onConnectionStats(StatusReport statusReport) {
        String str = JSON.toJSONString(statusReport);
        UIThreadHandler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod("onConnectionStats", str);
                    }
                });
    }
}
