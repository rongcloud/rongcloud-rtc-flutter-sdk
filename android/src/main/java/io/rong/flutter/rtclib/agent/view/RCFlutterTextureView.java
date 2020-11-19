package io.rong.flutter.rtclib.agent.view;

import android.graphics.SurfaceTexture;

import cn.rongcloud.rtc.api.stream.RCRTCTextureView;
import cn.rongcloud.rtc.core.EglBase;
import cn.rongcloud.rtc.core.RendererCommon;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import io.rong.flutter.rtclib.utils.AnyThreadSink;
import io.rong.flutter.rtclib.utils.ConstraintsMap;

public class RCFlutterTextureView implements EventChannel.StreamHandler {

    private TextureRegistry.SurfaceTextureEntry entry;
    private int id = -1;

    public void Dispose() {
        //destroy
        if (textureView != null) {
            textureView.release();
        }
        if (eventChannel != null)
            eventChannel.setStreamHandler(null);

        eventSink = null;
        entry.release();
    }

    /**
     * The {@code RendererEvents} which listens to rendering events reported by
     * {@link #textureView}.
     */
    private RendererCommon.RendererEvents rendererEvents;

    private void listenRendererEvents() {
        rendererEvents = new RendererCommon.RendererEvents() {
            private int _rotation = -1;
            private int _width = 0, _height = 0;

            @Override
            public void onFirstFrameRendered() {
                if (eventSink != null) {
                    ConstraintsMap params = new ConstraintsMap();
                    params.putString("event", "didFirstFrameRendered");
                    params.putInt("id", id);
                    eventSink.success(params.toMap());
                }
            }

            @Override
            public void onFrameResolutionChanged(
                    int videoWidth, int videoHeight,
                    int rotation) {
                if (eventSink != null) {
                    if (_width != videoWidth || _height != videoHeight) {
                        ConstraintsMap params = new ConstraintsMap();
                        params.putString("event", "didTextureChangeVideoSize");
                        params.putInt("id", id);
                        params.putInt("rotation", rotation);
                        params.putInt("width", videoWidth);
                        params.putInt("height", videoHeight);
                        _width = videoWidth;
                        _height = videoHeight;
                        eventSink.success(params.toMap());
                    }

                    if (_rotation != rotation) {
                        ConstraintsMap params = new ConstraintsMap();
                        params.putString("event", "didTextureChangeRotation");
                        params.putInt("id", id);
                        params.putInt("rotation", rotation);
                        _rotation = rotation;
                        eventSink.success(params.toMap());
                    }
                }
            }

            @Override
            public void onCreateEglFailed(Exception e) {

            }
        };
    }

    private RCRTCTextureView textureView;

    EventChannel eventChannel;
    EventChannel.EventSink eventSink;

    public RCFlutterTextureView(SurfaceTexture texture, final EglBase.Context sharedContext, TextureRegistry.SurfaceTextureEntry entry) {
        this.textureView = new RCRTCTextureView("");
        listenRendererEvents();
        textureView.init(sharedContext, rendererEvents);
        textureView.surfaceCreated(texture);
        this.eventSink = null;
        this.entry = entry;
    }

    public RCRTCTextureView getTextureView() {
        return textureView;
    }

    public void setEventChannel(EventChannel eventChannel) {
        this.eventChannel = eventChannel;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
        eventSink = new AnyThreadSink(sink);
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
    }

}
