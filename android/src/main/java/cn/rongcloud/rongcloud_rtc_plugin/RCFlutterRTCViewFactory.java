package cn.rongcloud.rongcloud_rtc_plugin;

import android.content.Context;
import android.view.View;

import java.util.HashMap;
import java.util.Map;

import cn.rongcloud.rtc.engine.view.RongRTCVideoView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class RCFlutterRTCViewFactory extends PlatformViewFactory {

    private BinaryMessenger messenger;
    private Map viewMap;

    private RCFlutterRTCViewFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    private static class SingleHolder {
        static RCFlutterRTCViewFactory instance = new RCFlutterRTCViewFactory();
    }

    public static RCFlutterRTCViewFactory getInstance() {
        return RCFlutterRTCViewFactory.SingleHolder.instance;
    }

    public void initWithMessenger(BinaryMessenger messenger) {
        this.messenger = messenger;
        this.viewMap = new HashMap();
    }


    @Override
    public PlatformView create(Context context, int viewId, Object arg) {
        RCFlutterRTCView view = new RCFlutterRTCView(context,this.messenger,viewId,arg);

        viewMap.put(viewId,view);

        return view;
    }

    public RongRTCVideoView getRenderVideoView(int viewId) {
        RCFlutterRTCView view = (RCFlutterRTCView)viewMap.get(viewId);
        if(view == null) {
            return null;
        }
        return view.getView();
    }

    public void removeRenderVideoView(int viewId) {
        RCFlutterRTCView view = (RCFlutterRTCView)viewMap.get(viewId);
        if(view != null) {
            viewMap.remove(viewId);
        }
    }
}
