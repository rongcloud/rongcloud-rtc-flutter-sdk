package io.rong.flutter.rtclib.agent.view;

import android.content.Context;
import android.view.ViewGroup;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class RCFlutterVideoViewFactory extends PlatformViewFactory {
  private Map<Integer, RCFlutterVideoView> videoViewMap = new HashMap<>();

  private static class SingletonHolder {
    static RCFlutterVideoViewFactory instance = new RCFlutterVideoViewFactory();
  }

  private RCFlutterVideoViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  public static RCFlutterVideoViewFactory getInstance() {
    return SingletonHolder.instance;
  }

  @Override
  public PlatformView create(Context context, int viewId, Object arg) {
    RCFlutterVideoView view = videoViewMap.get(viewId);
    if (view == null) {
      view = new RCFlutterVideoView(context);
      videoViewMap.put(viewId, view);
    } else {
      ViewGroup parent = (ViewGroup) view.getNativeVideoView().getParent();
      if (parent != null) {
        parent.removeView(view.getNativeVideoView());
      }
      view.getNativeVideoView().release();
    }
    return view;
  }

  public RCFlutterVideoView getVideoView(int id) {
    return videoViewMap.get(id);
  }

  public void releaseVideoView(int viewId) {
    RCFlutterVideoView videoView = videoViewMap.get(viewId);
    if (videoView != null) {
      videoView.getNativeVideoView().release();
    }
  }
}
