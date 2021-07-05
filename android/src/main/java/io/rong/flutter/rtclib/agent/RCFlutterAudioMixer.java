package io.rong.flutter.rtclib.agent;

import androidx.annotation.NonNull;

import java.util.Objects;

import cn.rongcloud.rtc.api.RCRTCAudioMixer;
import cn.rongcloud.rtc.api.callback.RCRTCAudioMixingStateChangeListener;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterAudioMixer extends RCRTCAudioMixingStateChangeListener implements MethodChannel.MethodCallHandler {

    private RCFlutterAudioMixer() {
    }

    private static class SingletonHolder {
        private static final RCFlutterAudioMixer instance = new RCFlutterAudioMixer();
    }

    public static RCFlutterAudioMixer getInstance() {
        return RCFlutterAudioMixer.SingletonHolder.instance;
    }

    protected void init(BinaryMessenger messenger, FlutterAssets assets) {
        this.assets = assets;
        channel = new MethodChannel(messenger, "rong.flutter.rtclib/AudioMixer");
        channel.setMethodCallHandler(this);
        RCRTCAudioMixer.getInstance().setAudioMixingStateChangeListener(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "startMix":
                startMix(call, result);
                break;
//            case "setPlayback":
//                setPlayback(call, result);
//                break;
            case "setMixingVolume":
                setMixingVolume(call, result);
                break;
            case "getMixingVolume":
                getMixingVolume(result);
                break;
            case "setPlaybackVolume":
                setPlaybackVolume(call, result);
                break;
            case "getPlaybackVolume":
                getPlaybackVolume(result);
                break;
            case "setVolume":
                setVolume(call, result);
                break;
            case "getDurationMillis":
                getDurationMillis(call, result);
                break;
            case "getCurrentPosition":
                getCurrentPosition(result);
                break;
            case "seekTo":
                seekTo(call, result);
                break;
            case "pause":
                pause(result);
                break;
            case "resume":
                resume(result);
                break;
            case "stop":
                stop(result);
                break;
        }
    }

    private void startMix(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        String assets = call.argument("assets");
        Integer mode = call.argument("mode");
        assert mode != null : "RCFlutterAudioMixer startMix [mode] should not be null!!!!";
        Boolean playback = call.argument("playback");
        assert playback != null : "RCFlutterAudioMixer startMix [playback] should not be null!!!!";
        Integer loopCount = call.argument("loopCount");
        assert loopCount != null : "RCFlutterAudioMixer startMix [loopCount] should not be null!!!!";
        String file = path != null ? path : getAssetsPath(assets);
        boolean success = RCRTCAudioMixer.getInstance().startMix(file, Objects.requireNonNull(RCRTCAudioMixer.Mode.class.getEnumConstants())[mode], playback, loopCount);
        UIThreadHandler.success(result, success);
    }

    private String getAssetsPath(String assets) {
        return "file:///android_asset/" + this.assets.getAssetFilePathByName(assets);
    }

//    private void setPlayback(MethodCall call, MethodChannel.Result result) {
//        Boolean playback = call.argument("playback");
//        assert playback != null : "RCFlutterAudioMixer setPlayback [playback] should not be null!!!!";
//        RCRTCAudioMixer.getInstance().setPlayback(playback);
//        UIThreadHandler.success(result, null);
//    }

    private void setMixingVolume(MethodCall call, MethodChannel.Result result) {
        Integer volume = call.argument("volume");
        assert volume != null : "RCFlutterAudioMixer setMixingVolume [volume] should not be null!!!!";
        RCRTCAudioMixer.getInstance().setMixingVolume(volume);
        UIThreadHandler.success(result, null);
    }

    private void getMixingVolume(MethodChannel.Result result) {
        int volume = RCRTCAudioMixer.getInstance().getMixingVolume();
        UIThreadHandler.success(result, volume);
    }

    private void setPlaybackVolume(MethodCall call, MethodChannel.Result result) {
        Integer volume = call.argument("volume");
        assert volume != null : "RCFlutterAudioMixer setPlaybackVolume [volume] should not be null!!!!";
        RCRTCAudioMixer.getInstance().setPlaybackVolume(volume);
        UIThreadHandler.success(result, null);
    }

    private void getPlaybackVolume(MethodChannel.Result result) {
        int volume = RCRTCAudioMixer.getInstance().getPlaybackVolume();
        UIThreadHandler.success(result, volume);
    }

    private void setVolume(MethodCall call, MethodChannel.Result result) {
        Integer volume = call.argument("volume");
        assert volume != null : "RCFlutterAudioMixer setVolume [volume] should not be null!!!!";
        RCRTCAudioMixer.getInstance().setVolume(volume);
        UIThreadHandler.success(result, null);
    }

    private void getDurationMillis(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        assert path != null : "RCFlutterAudioMixer getDurationMillis [path] should not be null!!!!";
        int duration = RCRTCAudioMixer.getInstance().getDurationMillis(path);
        UIThreadHandler.success(result, duration);
    }

    private void getCurrentPosition(MethodChannel.Result result) {
        float position = RCRTCAudioMixer.getInstance().getCurrentPosition();
        UIThreadHandler.success(result, position);
    }

    private void seekTo(MethodCall call, MethodChannel.Result result) {
        Float position = call.argument("position");
        assert position != null : "RCFlutterAudioMixer seekTo [position] should not be null!!!!";
        RCRTCAudioMixer.getInstance().seekTo(position);
        UIThreadHandler.success(result, null);
    }

    private void pause(MethodChannel.Result result) {
        RCRTCAudioMixer.getInstance().pause();
        UIThreadHandler.success(result, null);
    }

    private void resume(MethodChannel.Result result) {
        RCRTCAudioMixer.getInstance().resume();
        UIThreadHandler.success(result, null);
    }

    private void stop(MethodChannel.Result result) {
        RCRTCAudioMixer.getInstance().stop();
        UIThreadHandler.success(result, null);
    }

    @Override
    public void onStateChanged(RCRTCAudioMixer.MixingState state, RCRTCAudioMixer.MixingStateReason reason) {
        if (state == RCRTCAudioMixer.MixingState.STOPPED && reason == RCRTCAudioMixer.MixingStateReason.ALL_LOOPS_COMPLETED) {
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onMixEnd", null)
            );
        }
    }

    @Override
    public void onReportPlayingProgress(float v) {
    }

    private FlutterAssets assets;
    private MethodChannel channel;
}
