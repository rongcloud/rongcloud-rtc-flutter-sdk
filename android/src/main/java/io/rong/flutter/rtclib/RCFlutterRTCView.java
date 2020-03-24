package io.rong.flutter.rtclib;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import java.util.Map;
import cn.rongcloud.rtc.engine.view.RongRTCVideoView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;

public class RCFlutterRTCView implements PlatformView {

    private ViewGroup holderView = null;//占位 view
    private RongRTCVideoView videoView = null;//视频 view
    private String userId = null;
    private Integer widthI = null;
    private Integer heightI = null;

    RCFlutterRTCView(Context context, BinaryMessenger messenger, int viewId, Object arg) {
        Map map = (Map)arg;
        widthI = (Integer) map.get("width");
        heightI = (Integer) map.get("height");
        userId = (String)map.get("userId");

        holderView = new FrameLayout(context);
        ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(dp2px(context,widthI.floatValue()),dp2px(context,heightI.floatValue()));
        holderView.setLayoutParams(lp);

        videoView = new RongRTCVideoView(context);
        holderView.addView(videoView,new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER));

    }

    @Override
    public View getView() {
        return holderView;
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

    public void bindRenderView(RongRTCVideoView view) {
        videoView = view;

        holderView.addView(view,new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER) );
    }

    public void unbindRenderView() {
        holderView.removeView(videoView);
    }

    public void updateUserId(String uid) {
        userId = uid;
    }

    public int dp2px(Context context, float dipValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

}