package cn.rongcloud.rongcloud_rtc_plugin;

import android.content.Context;
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

    //切换渲染的时候，将 两个 flutter view 的 userId 和 renderView 交换，renderView 需要更改 size
    public void exchangeVideo(int viewId1,int viewId2) {
        //iOS 的做法
        RCFlutterRTCView flutterView1 = (RCFlutterRTCView)viewMap.get(viewId1);
        RCFlutterRTCView flutterView2 = (RCFlutterRTCView)viewMap.get(viewId2);

        //交换 userId
        String tmpUserId = flutterView1.getUserId();
        flutterView1.updateUserId(flutterView2.getUserId());
        flutterView2.updateUserId(tmpUserId);

        //交换 renderView
        RongRTCVideoView renderView1 = flutterView1.getVideoView();
        RongRTCVideoView renderView2 = flutterView2.getVideoView();

        flutterView1.unbindRenderView();
        flutterView2.unbindRenderView();

        flutterView1.bindRenderView(renderView2,flutterView1.getViewParent());
        flutterView2.bindRenderView(renderView1,flutterView2.getViewParent());

    }
}
