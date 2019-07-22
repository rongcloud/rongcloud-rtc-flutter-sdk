package cn.rongcloud.rongcloud_rtc_plugin;

import android.content.Context;
import android.view.ViewGroup;
import android.view.ViewParent;
import java.util.Map;
import cn.rongcloud.rtc.engine.view.RongRTCVideoView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;

public class RCFlutterRTCView implements PlatformView {

    private RongRTCVideoView videoView = null;
    private String userId = null;
    private Integer widthI = null;
    private Integer heightI = null;
    private ViewParent viewParent = null;

    RCFlutterRTCView(Context context, BinaryMessenger messenger, int viewId, Object arg) {

        videoView = new RongRTCVideoView(context);

        Map map = (Map)arg;
        widthI = (Integer) map.get("width");
        heightI = (Integer) map.get("height");
        userId = (String)map.get("userId");
        ViewGroup.LayoutParams layoutParams = videoView.getLayoutParams();
        if (layoutParams != null) {
            layoutParams.width = widthI.intValue();
            layoutParams.height = heightI.intValue();
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

    public String getUserId() {
        return userId;
    }

    public RongRTCVideoView getVideoView() {
        return videoView;
    }

    public ViewParent getViewParent() {
        return viewParent;
    }

    public void bindRenderView(RongRTCVideoView view, ViewParent viewParent) {
        videoView = view;
        ViewParent parent = viewParent;
        if(parent instanceof ViewGroup) {
            ViewGroup viewGroup = (ViewGroup)parent;
            viewGroup.addView(view);
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            if (layoutParams != null) {
                layoutParams.width = dp2px(RCFlutterRTCWrapper.getInstance().getContext(),widthI.floatValue());
                layoutParams.height = dp2px(RCFlutterRTCWrapper.getInstance().getContext(),heightI.floatValue());
                view.setLayoutParams(layoutParams);
            }
        }
    }

    public void unbindRenderView() {
        viewParent = videoView.getParent();
        if(viewParent instanceof ViewGroup) {
            ViewGroup viewGroup = (ViewGroup)viewParent;
            viewGroup.removeView(videoView);
        }
    }

    public void updateUserId(String uid) {
        userId = uid;
    }

    public int dp2px(Context context, float dipValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

}