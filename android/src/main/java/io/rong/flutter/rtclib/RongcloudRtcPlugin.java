package io.rong.flutter.rtclib;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** RongcloudRtcPlugin */
public class RongcloudRtcPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.rongcloud.im/rtc_plugin");
    channel.setMethodCallHandler(new RongcloudRtcPlugin());
    RCFlutterRTCWrapper.getInstance().saveMethodChannel(channel);
    RCFlutterRTCWrapper.getInstance().saveContext(registrar.context());
    RCFlutterRTCViewFactory factory = RCFlutterRTCViewFactory.getInstance();
    factory.initWithMessenger(registrar.messenger());
    registrar.platformViewRegistry().registerViewFactory("plugins.rongcloud.im/rtc_view",factory);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    RCFlutterRTCWrapper.getInstance().onRTCMethodCall(call,result);
  }
}
