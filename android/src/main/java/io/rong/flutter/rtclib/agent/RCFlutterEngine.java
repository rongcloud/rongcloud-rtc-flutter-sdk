package io.rong.flutter.rtclib.agent;

import android.content.Context;
import android.graphics.SurfaceTexture;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
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
import cn.rongcloud.rtc.api.stream.RCRTCCameraOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCFileVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCMicOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoStreamConfig;
import cn.rongcloud.rtc.base.RCRTCAVStreamType;
import cn.rongcloud.rtc.base.RCRTCParamsType;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;
import io.rong.flutter.rtclib.RCFlutterRequestResult;
import io.rong.flutter.rtclib.agent.room.RCFlutterRemoteUser;
import io.rong.flutter.rtclib.agent.room.RCFlutterRoom;
import io.rong.flutter.rtclib.agent.room.RCFlutterRoomConfig;
import io.rong.flutter.rtclib.agent.stream.RCFlutterAudioInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterCameraOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterFileVideoOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterMicOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoOutputStream;
import io.rong.flutter.rtclib.agent.view.RCFlutterTextureView;
import io.rong.flutter.rtclib.agent.view.RCFlutterTextureViewFactory;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterEngine extends IRCRTCStatusReportListener implements MethodCallHandler, RCRTCLiveCallback {

    private static final String TAG = "RCFlutterEngine";

    private static final String VER = "5.1.4";

    private static final String ASSETS_PREFIX = "file:///android_asset/";
    private BinaryMessenger bMsg;
    private final HashMap<String, RCFlutterRoom> roomMap = new HashMap<>();
    private RCFlutterCameraOutputStream cameraOutputStream;
    private RCFlutterMicOutputStream micOutputStream;
    private RCFlutterAudioEffectManager audioEffectManager;
    // key => (streamId + "_" + type)
    private final Map<String, RCFlutterVideoOutputStream> createdVideoOutputStreams;
    private Context context;
    private MethodChannel channel;
    private FlutterPlugin.FlutterAssets flutterAssets;

    private TextureRegistry textures;

//    private LongSparseArray<FlutterRTCVideoRenderer> renders = new LongSparseArray<>();

    public static String getVersion() {
        return VER;
    }

    private static class SingletonHolder {
        private static final RCFlutterEngine instance = new RCFlutterEngine();
    }

    private RCFlutterEngine() {
        createdVideoOutputStreams = new HashMap<>();
    }

    public static RCFlutterEngine getInstance() {
        return SingletonHolder.instance;
    }

    public void init(Context context, BinaryMessenger msg, FlutterPlugin.FlutterAssets flutterAssets, TextureRegistry textureRegistry) {
        bMsg = msg;
        this.context = context;
        this.flutterAssets = flutterAssets;
        this.textures = textureRegistry;
        channel = new MethodChannel(bMsg, "rong.flutter.rtclib/engine");
        channel.setMethodCallHandler(this);

        RCFlutterAudioMixer.getInstance().init(bMsg, flutterAssets);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "init":
                init(result);
                break;
            case "unInit":
                unInit(result);
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
            case "setMediaServerUrl":
                setMediaServerUrl(call, result);
                break;
            case "enableSpeaker":
                enableSpeaker(call, result);
                break;
            case "registerStatusReportListener":
                registerReportStatusListener(result);
                break;
            case "unRegisterStatusReportListener":
                unRegisterReportStatusListener(result);
                break;
            case "createFileVideoOutputStream":
                createFileVideoOutputStream(call, result);
                break;
            case "createVideoRenderer":
                createVideoRenderer(call, result);
                break;
            case "disposeVideoRenderer":
                disposeVideoRenderer(call, result);
                break;
            case "getAudioEffectManager":
                getAudioEffectManager(result);
                break;
            default:
                result.notImplemented();
        }
    }

    private void init(Result result) {
        RCRTCConfig config = RCRTCConfig.Builder.create().build();
        Log.d(TAG, "init: ");
        RCRTCEngine.getInstance().init(context, config);
        UIThreadHandler.success(result, 0);
    }

    private void unInit(Result result) {
        Log.d(TAG, "unInit: ");

        if (cameraOutputStream != null) {
            cameraOutputStream.release();
            cameraOutputStream = null;
        }
        if (micOutputStream != null) {
            micOutputStream.release();
            micOutputStream = null;
        }
        if (audioEffectManager != null) {
            audioEffectManager.release();
            audioEffectManager = null;
        }

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
        HashMap<String, Integer> map = call.argument("roomConfig");
        RCFlutterRoomConfig config = RCFlutterRoomConfig.from(map);
        RCRTCEngine.getInstance().joinRoom(roomId, config.nativeConfig(), new IRCRTCResultDataCallback<RCRTCRoom>() {
            @Override
            public void onSuccess(RCRTCRoom data) {
                RCFlutterLog.v(TAG, "joinRoom onSuccess");
                RCFlutterRoom room = new RCFlutterRoom(bMsg, data);
                roomMap.put(room.getId(), room);
                RCFlutterRequestResult<RCFlutterRoom> requestResult = new RCFlutterRequestResult<>(room, 0);
                UIThreadHandler.success(result, JSONObject.toJSON(requestResult).toString());
            }

            @Override
            public void onFailed(RTCErrorCode code) {
                RCFlutterLog.v(TAG, "joinRoom onFailed code = " + code);
                RCFlutterRequestResult<String> requestResult = new RCFlutterRequestResult<>(code.getReason(), code.getValue());
                UIThreadHandler.success(result, JSONObject.toJSON(requestResult).toString());
            }
        });
    }

    private void leaveRoom(Result result) {
        Log.d(TAG, "leaveRoom");
        final String roomId = RCRTCEngine.getInstance().getRoom().getRoomId();
        RCRTCEngine.getInstance().leaveRoom(new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
                RCFlutterLog.v(TAG, "leaveRoom onSuccess");
                RCFlutterRoom room = roomMap.remove(roomId);
                if (room != null) {
                    room.release();
                }

                if (cameraOutputStream != null) {
                    cameraOutputStream.release();
                    cameraOutputStream = null;
                }
                if (micOutputStream != null) {
                    micOutputStream.release();
                    micOutputStream = null;
                }
                if (audioEffectManager != null) {
                    audioEffectManager.release();
                    audioEffectManager = null;
                }

                for (RCFlutterVideoOutputStream stream : createdVideoOutputStreams.values()) {
                    stream.release();
                }
                createdVideoOutputStreams.clear();

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

    }

    private void getDefaultVideoStream(Result result) {
        Log.d(TAG, "getDefaultVideoStream: ");
        if (cameraOutputStream == null) {
            (new Thread(() -> {
                RCRTCCameraOutputStream stream = RCRTCEngine.getInstance().getDefaultVideoStream();
                long start = System.currentTimeMillis();
                long current = System.currentTimeMillis();
                while (stream == null && (current - start) < 1000) { // 1秒超时
                    stream = RCRTCEngine.getInstance().getDefaultVideoStream();
                    current = System.currentTimeMillis();
                }
                cameraOutputStream = new RCFlutterCameraOutputStream(bMsg, stream);
                UIThreadHandler.success(result, JSON.toJSONString(cameraOutputStream));
            }
            )).start();
        } else {
            UIThreadHandler.success(result, JSON.toJSONString(cameraOutputStream));
        }
    }

    private void getDefaultAudioStream(Result result) {
        Log.d(TAG, "getDefaultAudioStream: ");
        if (micOutputStream == null) {
            (new Thread(() -> {
                RCRTCMicOutputStream stream = RCRTCEngine.getInstance().getDefaultAudioStream();
                long start = System.currentTimeMillis();
                long current = System.currentTimeMillis();
                while (stream == null && (current - start) < 1000) { // 1秒超时
                    stream = RCRTCEngine.getInstance().getDefaultAudioStream();
                    current = System.currentTimeMillis();
                }
                micOutputStream = new RCFlutterMicOutputStream(bMsg, stream);
                UIThreadHandler.success(result, JSON.toJSONString(micOutputStream));
            }
            )).start();
        } else {
            UIThreadHandler.success(result, JSON.toJSONString(micOutputStream));
        }
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
        RCRTCEngine.getInstance().subscribeLiveStream(url, streamType, this);
        UIThreadHandler.success(result, null);
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
        RCRTCVideoStreamConfig config = RCRTCVideoStreamConfig.Builder.create().
                setMinRate(50).
                setMaxRate(500).
                setVideoFps(RCRTCParamsType.RCRTCVideoFps.Fps_24).
                setVideoResolution(RCRTCParamsType.RCRTCVideoResolution.RESOLUTION_480_640).build();
        String path = ASSETS_PREFIX + flutterAssets.getAssetFilePathByName(fileName);
        RCRTCFileVideoOutputStream stream = RCRTCEngine.getInstance().createFileVideoOutputStream(path, replace, playback, tag, config);
        RCFlutterFileVideoOutputStream flutterStream = new RCFlutterFileVideoOutputStream(bMsg, stream);
        String uid = flutterStream.getStreamId() + "_" + flutterStream.getType();
        createdVideoOutputStreams.put(uid, flutterStream);
        UIThreadHandler.success(result, JSON.toJSONString(flutterStream));
    }

    private void createVideoRenderer(MethodCall call, Result result) {
        TextureRegistry.SurfaceTextureEntry entry = textures.createSurfaceTexture();
        SurfaceTexture surfaceTexture = entry.surfaceTexture();
        RCFlutterTextureView render = new RCFlutterTextureView(surfaceTexture, RCRTCEngine.getInstance().getEglBaseContext(), entry);
        RCFlutterTextureViewFactory.getInstance().put(entry.id(), render);

        EventChannel eventChannel = new EventChannel(bMsg, "rong.flutter.rtclib/VideoTextureView:" + entry.id());
        eventChannel.setStreamHandler(render);
        render.setEventChannel(eventChannel);
        render.setId((int) entry.id());

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("textureId", (int) entry.id());
        UIThreadHandler.success(result, jsonObject.toJSONString());
    }

    private void disposeVideoRenderer(MethodCall call, Result result) {
        int textureId = call.argument("textureId");
        RCFlutterTextureView render = RCFlutterTextureViewFactory.getInstance().get(textureId);
        if (render != null) {
            render.Dispose();
            RCFlutterTextureViewFactory.getInstance().delete(textureId);
        }
        result.success(null);
    }

    private void getAudioEffectManager(Result result) {
        if (audioEffectManager == null)
            audioEffectManager = new RCFlutterAudioEffectManager(bMsg, flutterAssets, RCRTCEngine.getInstance().getAudioEffectManager());
        JSONObject json = new JSONObject();
        json.put("id", audioEffectManager.getId());
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void registerReportStatusListener(Result result) {
        RCRTCEngine.getInstance().registerStatusReportListener(this);
        UIThreadHandler.success(result, null);
    }

    private void unRegisterReportStatusListener(Result result) {
        RCRTCEngine.getInstance().unregisterStatusReportListener();
        UIThreadHandler.success(result, null);
    }

    // todo to be effect.
    public ArrayList<RCFlutterInputStream> getAllInputStreamList() {
        ArrayList<RCFlutterInputStream> streamList = new ArrayList<>();
        ArrayList<RCFlutterRoom> roomList = new ArrayList<>(roomMap.values());
        for (RCFlutterRoom room : roomList) {
            for (RCFlutterRemoteUser remoteUser : room.getRemoteUserList()) {
                streamList.addAll(remoteUser.getStreamList());
            }
            streamList.addAll(room.getStreamList());
        }
        return streamList;
    }

    public RCFlutterVideoOutputStream getFlutterVideoOutputStream(String streamId, int type) {
        return createdVideoOutputStreams.get(makeStreamTypeId(streamId, type));
    }

    private String makeStreamTypeId(String streamId, int type) {
        return streamId + "_" + type;
    }

    @Override
    public void onAudioReceivedLevel(HashMap<String, String> hashMap) {
    }

    @Override
    public void onAudioInputLevel(String level) {
    }

    @Override
    public void onConnectionStats(StatusReport statusReport) {
        String str = JSON.toJSONString(statusReport);
        UIThreadHandler.post(
                () -> channel.invokeMethod("onConnectionStats", str)
        );
    }

    @Override
    public void onSuccess() {
        UIThreadHandler.post(
                () -> channel.invokeMethod("onSuccess", null)
        );
    }

    @Override
    public void onAudioStreamReceived(RCRTCAudioInputStream stream) {
        UIThreadHandler.post(
                () -> channel.invokeMethod("onAudioStreamReceived", JSON.toJSONString(new RCFlutterAudioInputStream(bMsg, stream)))
        );
    }

    @Override
    public void onVideoStreamReceived(RCRTCVideoInputStream stream) {
        UIThreadHandler.post(
                () -> channel.invokeMethod("onVideoStreamReceived", JSON.toJSONString(new RCFlutterVideoInputStream(bMsg, stream)))
        );
    }

    @Override
    public void onFailed(RTCErrorCode errorCode) {
        JSONObject json = new JSONObject();
        json.put("code", errorCode.getValue());
        json.put("message", errorCode.getReason());
        UIThreadHandler.post(
                () -> channel.invokeMethod("onFailed", json.toJSONString())
        );
    }
}
