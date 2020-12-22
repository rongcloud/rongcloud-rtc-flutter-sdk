package io.rong.flutter.rtclib.agent;

import android.util.Log;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSONObject;

import cn.rongcloud.rtc.api.IAudioEffectManager;
import cn.rongcloud.rtc.api.IAudioEffectManager.IStateObserver;
import cn.rongcloud.rtc.api.IAudioEffectManager.ILoadingStateCallback;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterAudioEffectManager implements IStateObserver, ILoadingStateCallback, MethodCallHandler {

    public RCFlutterAudioEffectManager(BinaryMessenger messenger, FlutterAssets assets, IAudioEffectManager manager) {
        this.assets = assets;
        this.manager = manager;
        this.id = this.manager.hashCode();

        channel = new MethodChannel(messenger, "rong.flutter.rtclib/AudioEffectManager:" + this.id);
        channel.setMethodCallHandler(this);

        callback = this;
    }

    public int getId() {
        return id;
    }

    @Override
    public void onEffectFinished(int effectId) {
        JSONObject json = new JSONObject();
        json.put("effectId", effectId);
        String arguments = json.toString();
        UIThreadHandler.post(
                () -> channel.invokeMethod("onEffectFinished", arguments)
        );
    }

    @Override
    public void complete(int error) {
        JSONObject json = new JSONObject();
        json.put("error", error);
        String arguments = json.toString();
        UIThreadHandler.post(
                () -> channel.invokeMethod("complete", arguments)
        );
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "preloadEffect":
                preloadEffect(call, result);
                break;
            case "unloadEffect":
                unloadEffect(call, result);
                break;
            case "playEffect":
                playEffect(call, result);
                break;
            case "pauseEffect":
                pauseEffect(call, result);
                break;
            case "pauseAllEffects":
                pauseAllEffects(result);
                break;
            case "resumeEffect":
                resumeEffect(call, result);
                break;
            case "resumeAllEffects":
                resumeAllEffects(result);
                break;
            case "stopEffect":
                stopEffect(call, result);
                break;
            case "stopAllEffects":
                stopAllEffects(result);
                break;
            case "setEffectsVolume":
                setEffectsVolume(call, result);
                break;
            case "getEffectsVolume":
                getEffectsVolume(result);
                break;
            case "setEffectVolume":
                setEffectVolume(call, result);
                break;
            case "getEffectVolume":
                getEffectVolume(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void preloadEffect(MethodCall call, Result result) {
        String path = call.argument("path");
        String assets = call.argument("assets");
        String file = path != null ? path : getAssetsPath(assets);
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        manager.preloadEffect(file, effectId, error -> {
            JSONObject json = new JSONObject();
            json.put("code", error);
            UIThreadHandler.success(result, json.toJSONString());
        });
    }

    private String getAssetsPath(String assets) {
        return "file:///android_asset/" + this.assets.getAssetFilePathByName(assets);
    }

    private void unloadEffect(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        int code = manager.unloadEffect(effectId);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void playEffect(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        Integer loopCount = call.argument("loopCount");
        assert loopCount != null : "LoopCount can't be null!";
        Integer volume = call.argument("volume");
        assert volume != null : "Volume can't be null!";
        int code = manager.playEffect(effectId, loopCount, volume);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void pauseEffect(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        int code = manager.pauseEffect(effectId);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void pauseAllEffects(Result result) {
        int code = manager.pauseAllEffects();
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void resumeEffect(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        int code = manager.resumeEffect(effectId);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void resumeAllEffects(Result result) {
        int code = manager.resumeAllEffects();
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void stopEffect(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        int code = manager.stopEffect(effectId);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void stopAllEffects(Result result) {
        int code = manager.stopAllEffects();
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void setEffectsVolume(MethodCall call, Result result) {
        Integer volume = call.argument("volume");
        assert volume != null : "Volume can't be null!";
        int code = manager.setEffectsVolume(volume);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void getEffectsVolume(Result result) {
        int volume = manager.getEffectsVolume();
        JSONObject json = new JSONObject();
        json.put("volume", volume);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void setEffectVolume(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        Integer volume = call.argument("volume");
        assert volume != null : "Volume can't be null!";
        int code = manager.setEffectVolume(effectId, volume);
        JSONObject json = new JSONObject();
        json.put("code", code);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private void getEffectVolume(MethodCall call, Result result) {
        Integer effectId = call.argument("effectId");
        assert effectId != null : "Effect id can't be null!";
        int volume = manager.getEffectVolume(effectId);
        JSONObject json = new JSONObject();
        json.put("volume", volume);
        UIThreadHandler.success(result, json.toJSONString());
    }

    private final FlutterAssets assets;

    private final IAudioEffectManager manager;
    private final int id;

    private final MethodChannel channel;

    private final ILoadingStateCallback callback;
}
