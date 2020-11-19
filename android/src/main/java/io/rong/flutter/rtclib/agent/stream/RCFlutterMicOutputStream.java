package io.rong.flutter.rtclib.agent.stream;

import androidx.annotation.NonNull;

import cn.rongcloud.rtc.api.stream.RCRTCAudioStreamConfig;
import cn.rongcloud.rtc.api.stream.RCRTCMicOutputStream;
import cn.rongcloud.rtc.base.RCRTCParamsType;
import cn.rongcloud.rtc.base.RCRTCStream;
import cn.rongcloud.rtc.base.RCRTCSyncCallBack;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterMicOutputStream extends RCFlutterAudioOutputStream {

    private static final String TAG = "RCFlutterMicOutputStream";
    private RCRTCMicOutputStream rtcMicOutputStream;

    public RCFlutterMicOutputStream(BinaryMessenger bMsg, RCRTCStream rtcStream) {
        super(bMsg, rtcStream);
        RCFlutterDebugChecker.isTrue(rtcStream instanceof RCRTCMicOutputStream);
        if (rtcStream instanceof RCRTCMicOutputStream) {
            rtcMicOutputStream = (RCRTCMicOutputStream) rtcStream;
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "setMicrophoneDisable":
                setMicrophoneDisable(call, result);
                break;
            case "setAudioConfig":
                setAudioConfig(call, result);
                break;
            case "changeAudioScenario":
                changeAudioScenario(call, result);
                break;
            case "adjustRecordingVolume":
                adjustRecordingVolume(call, result);
                break;
            case "getRecordingVolume":
                getRecordingVolume(result);
                break;
            default:
                super.onMethodCall(call, result);
        }
    }

    private void setMicrophoneDisable(MethodCall call, Result result) {
        boolean disable = (boolean) call.arguments;
        rtcMicOutputStream.setMicrophoneDisable(disable);
        UIThreadHandler.success(result, null);
    }

    private void setAudioConfig(MethodCall call, Result result) {
        Integer type = call.argument("type");
        assert type != null : "setAudioConfig type should not be null!!!!";
        Boolean enableAGCControl = call.argument("enableAGCControl");
        assert enableAGCControl != null : "setAudioConfig enableAGCControl should not be null!!!!";
        Boolean enableAGCLimiter = call.argument("enableAGCLimiter");
        assert enableAGCLimiter != null : "setAudioConfig enableAGCLimiter should not be null!!!!";
        Boolean enableEchoFilter = call.argument("enableEchoFilter");
        assert enableEchoFilter != null : "setAudioConfig enableEchoFilter should not be null!!!!";
        Boolean enableHighPassFilter = call.argument("enableHighPassFilter");
        assert enableHighPassFilter != null : "setAudioConfig enableHighPassFilter should not be null!!!!";
        Boolean enablePreAmplifier = call.argument("enablePreAmplifier");
        assert enablePreAmplifier != null : "setAudioConfig enablePreAmplifier should not be null!!!!";
        Integer agcCompression = call.argument("agcCompression");
        assert agcCompression != null : "setAudioConfig agcCompression should not be null!!!!";
        Integer agcTargetDBOV = call.argument("agcTargetDBOV");
        assert agcTargetDBOV != null : "setAudioConfig agcTargetDBOV should not be null!!!!";
        Integer echoCancel = call.argument("echoCancel");
        assert echoCancel != null : "setAudioConfig echoCancel should not be null!!!!";
        Integer noiseSuppression = call.argument("noiseSuppression");
        assert noiseSuppression != null : "setAudioConfig noiseSuppression should not be null!!!!";
        Integer noiseSuppressionLevel = call.argument("noiseSuppressionLevel");
        assert noiseSuppressionLevel != null : "setAudioConfig noiseSuppressionLevel should not be null!!!!";
        Float preAmplifierLevel = call.argument("preAmplifierLevel");
        assert preAmplifierLevel != null : "setAudioConfig preAmplifierLevel should not be null!!!!";
        RCRTCAudioStreamConfig.Builder builder = RCRTCAudioStreamConfig.Builder.create()
                .enableAGCControl(enableAGCControl)
                .enableAGCLimiter(enableAGCLimiter)
                .enableEchoFilter(enableEchoFilter)
                .enableHighPassFilter(enableHighPassFilter)
                .enablePreAmplifier(enablePreAmplifier)
                .setAGCCompression(agcCompression)
                .setAGCTargetdbov(agcTargetDBOV)
                .setEchoCancel(RCRTCParamsType.AECMode.parseValue(echoCancel))
                .setNoiseSuppression(RCRTCParamsType.NSMode.parseValue(noiseSuppression))
                .setNoiseSuppressionLevel(RCRTCParamsType.NSLevel.parseValue(noiseSuppressionLevel))
                .setPreAmplifierLevel(preAmplifierLevel);
        RCRTCAudioStreamConfig config = null;
        switch (type) {
            case 0:
                config = builder.build();
                break;
            case 1:
                config = builder.buildDefaultMode();
                break;
            case 2:
                config = builder.buildMusicMode();
                break;
        }
        assert config != null : "setAudioConfig config should not be null!!!! type = " + type;
        rtcMicOutputStream.setAudioConfig(config);
        UIThreadHandler.success(result, null);
    }

    private void changeAudioScenario(MethodCall call, Result result) {
        Integer audioScenario = call.argument("audioScenario");
        assert audioScenario != null : "changeAudioScenario audioScenario should not be null!!!!";
        final String id = call.argument("id");
        rtcMicOutputStream.changeAudioScenario(RCRTCParamsType.AudioScenario.valueOf(audioScenario), new RCRTCSyncCallBack() {
            @Override
            public void syncActions() {
                channel.invokeMethod("changeAudioScenarioSyncActions", id);
            }
        });
        UIThreadHandler.success(result, null);
    }

    private void adjustRecordingVolume(MethodCall call, Result result) {
        Integer volume = (Integer) call.arguments;
        assert volume != null : "adjustRecordingVolume volume should not be null!!!!";
        rtcMicOutputStream.adjustRecordingVolume(volume);
        UIThreadHandler.success(result, null);
    }

    private void getRecordingVolume(Result result) {
        int volume = rtcMicOutputStream.getRecordingVolume();
        UIThreadHandler.success(result, volume);
    }

    public boolean getMute() {
        return rtcMicOutputStream.isMute();
    }

    public boolean getState() {
        return rtcMicOutputStream.isMicrophoneDisable();
    }
}
