package cn.rongcloud.rongcloud_rtc_plugin;

import android.content.Context;
import android.graphics.Color;
import android.view.ViewGroup;

import java.util.Map;
import cn.rongcloud.rtc.engine.view.RongRTCVideoView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;

public class RCFlutterRTCView implements PlatformView {

    RongRTCVideoView videoView = null;

    RCFlutterRTCView(Context context, BinaryMessenger messenger, int viewId, Object arg) {

        videoView = new RongRTCVideoView(context);

        Map map = (Map)arg;
        Integer wI = (Integer) map.get("width");
        Integer hI = (Integer) map.get("height");
        ViewGroup.LayoutParams layoutParams = videoView.getLayoutParams();
        if (layoutParams != null) {
            layoutParams.height = hI.intValue();
            layoutParams.width = wI.intValue();
            videoView.setLayoutParams(layoutParams);
        }

    }

    @Override
    public RongRTCVideoView getView() {
        return videoView;
    }

    @Override
    public void dispose() {

    }
}