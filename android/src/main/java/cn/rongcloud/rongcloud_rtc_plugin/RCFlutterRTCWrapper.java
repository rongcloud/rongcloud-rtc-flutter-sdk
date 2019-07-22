package cn.rongcloud.rongcloud_rtc_plugin;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import cn.rongcloud.rtc.RTCErrorCode;
import cn.rongcloud.rtc.RongRTCEngine;
import cn.rongcloud.rtc.callback.JoinRoomUICallBack;
import cn.rongcloud.rtc.callback.RongRTCResultUICallBack;
import cn.rongcloud.rtc.engine.view.RongRTCVideoView;
import cn.rongcloud.rtc.events.RongRTCEventsListener;
import cn.rongcloud.rtc.room.RongRTCRoom;
import cn.rongcloud.rtc.stream.MediaType;
import cn.rongcloud.rtc.stream.local.RongRTCCapture;
import cn.rongcloud.rtc.stream.remote.RongRTCAVInputStream;
import cn.rongcloud.rtc.user.RongRTCRemoteUser;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Message;

public class RCFlutterRTCWrapper {

    private MethodChannel methodChannel;
    private Context context;
    private RongRTCRoom rtcRoom;
    private RongRTCCapture capture;
    private Handler mMainHandler = null;

    private RCFlutterRTCWrapper() {
        mMainHandler = new Handler(Looper.getMainLooper());
    }

    private static class SingleHolder {
        static RCFlutterRTCWrapper instance = new RCFlutterRTCWrapper();
    }

    public static RCFlutterRTCWrapper getInstance() {
        return SingleHolder.instance;
    }

    public void saveMethodChannel(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
    }

    public void saveContext(Context context) {
        this.context = context;
    }

    public void onRTCMethodCall(MethodCall call, MethodChannel.Result result) {
        if(call.method.equals(RCFlutterRTCMethodKey.Config)) {
            config(call.arguments);
        }else if(call.method.equals(RCFlutterRTCMethodKey.JoinRTCRoom)) {
            joinRTCRoom(call.arguments,result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.LeaveRTCRoom)) {
            leaveRTCRoom(call.arguments,result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.PublishAVStream)) {
            publishAVStream(result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.UnpublishAVStream)) {
            unpublishAVStream(result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.RenderLocalVideo)) {
            renderLocalVideo(call.arguments);
        }else if(call.method.equals(RCFlutterRTCMethodKey.RenderRemoteVideo)) {
            renderRemoteVideo(call.arguments);
        }else if(call.method.equals(RCFlutterRTCMethodKey.RemovePlatformView)) {
            removePlatformView(call.arguments);
        }else if(call.method.equals(RCFlutterRTCMethodKey.SubscribeAVStream)) {
            subscribeAVStream(call.arguments,result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.UnsubscribeAVStream)) {
            unsubscribeAVStream(call.arguments,result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.GetRemoteUsers)) {
            getRemoteUsers(call.arguments,result);
        }else if(call.method.equals(RCFlutterRTCMethodKey.MuteLocalAudio)) {
            muteLocalAudio(call.arguments);
        }else if(call.method.equals(RCFlutterRTCMethodKey.MuteRemoteAudio)) {
            muteRemoteAudio(call.arguments);
        }else if(call.method.equals(RCFlutterRTCMethodKey.SwitchCamera)) {
            switchCamera();
        }else if(call.method.equals(RCFlutterRTCMethodKey.ExchangeVideo)) {
            exchangeVideo(call.arguments);
        }
        else {
            result.notImplemented();
        }
    }


    private void config(Object arg) {
        final String LOG_TAG = "config " ;
        RCLog.i(LOG_TAG+" start");
        if(arg instanceof Map) {
            Map map = (Map)arg;
            RCFlutterRTCConfig.getInstance().updateParam(map);
        }
    }

    private void joinRTCRoom(Object arg, final MethodChannel.Result result) {
        final String LOG_TAG = "joinRTCRoom " ;
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof String) {
            String roomId = String.valueOf(arg);
            RongRTCEngine.getInstance().joinRoom(roomId, new JoinRoomUICallBack() {
                @Override
                protected void onUiSuccess(RongRTCRoom rongRTCRoom) {
                    rtcRoom = rongRTCRoom;
                    rtcRoom.registerEventsListener(new RTCEventsListener());
                    RCLog.i(LOG_TAG+" success");
                    result.success(0);
                }

                @Override
                protected void onUiFailed(RTCErrorCode rtcErrorCode) {
                    RCLog.e(LOG_TAG+"joinRTCRoom error:"+ rtcErrorCode.getValue());
                    result.success(rtcErrorCode.getValue());
                }
            });
        }
    }

    private void leaveRTCRoom(Object arg, final MethodChannel.Result result) {
        final String LOG_TAG = "leaveRTCRoom " ;
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof String) {
            String roomId = String.valueOf(arg);
            RongRTCEngine.getInstance().quitRoom(roomId, new RongRTCResultUICallBack() {
                @Override
                public void onUiSuccess() {
                    RCLog.i(LOG_TAG+" success ");
                    result.success(0);
                }

                @Override
                public void onUiFailed(RTCErrorCode rtcErrorCode) {
                    RCLog.e(LOG_TAG+" error:"+ rtcErrorCode.getValue());
                    result.success(rtcErrorCode.getValue());
                }
            });
        }
    }

    private void publishAVStream(final MethodChannel.Result result) {
        final String LOG_TAG = "publishAVStream " ;
        RCLog.i(LOG_TAG+" start");
        if(this.rtcRoom == null || this.rtcRoom.getLocalUser() == null) {
            RCLog.e(LOG_TAG+" error:" + RTCErrorCode.RongRTCCodeNotInRoom.getValue());
            result.success(RTCErrorCode.RongRTCCodeNotInRoom.getValue());
            return;
        }
        this.rtcRoom.getLocalUser().publishDefaultAVStream(new RongRTCResultUICallBack() {
            @Override
            public void onUiSuccess() {
                RCLog.i(LOG_TAG+" success");
                result.success(0);
            }

            @Override
            public void onUiFailed(RTCErrorCode rtcErrorCode) {
                RCLog.e(LOG_TAG+" error:"+ rtcErrorCode.getValue());
                result.success(rtcErrorCode.getValue());
            }
        });
    }

    private void unpublishAVStream(final MethodChannel.Result result) {
        final String LOG_TAG = "unpublishAVStream " ;
        RCLog.i(LOG_TAG+" start");
        if(this.rtcRoom == null || this.rtcRoom.getLocalUser() == null) {
            RCLog.e(LOG_TAG+" error " + RTCErrorCode.RongRTCCodeNotInRoom.getValue());
            result.success(RTCErrorCode.RongRTCCodeNotInRoom.getValue());
            return;
        }
        this.rtcRoom.getLocalUser().unPublishDefaultAVStream(new RongRTCResultUICallBack() {
            @Override
            public void onUiSuccess() {
                RCLog.i(LOG_TAG+" success ");
                result.success(0);
            }

            @Override
            public void onUiFailed(RTCErrorCode rtcErrorCode) {
                RCLog.e(LOG_TAG+" error:"+ rtcErrorCode.getValue());
                result.success(rtcErrorCode.getValue());
            }
        });
    }

    private void renderLocalVideo(Object arg) {
        final String LOG_TAG = "renderLocalVideo " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof Map) {
            Map param = (Map)arg;
            int viewId = (Integer) param.get("viewId");
            RongRTCVideoView view = RCFlutterRTCViewFactory.getInstance().getRenderVideoView(viewId);
            //todo
            if(view != null) {
                getCapture().setRTCConfig(RCFlutterRTCConfig.getInstance().getRTCConfig());
                getCapture().setRongRTCVideoView(view);
                getCapture().startCameraCapture();
            }
        }
    }

    private void renderRemoteVideo(Object arg) {
        final String LOG_TAG = "renderRemoteVideo " ;
        RCLog.i(LOG_TAG + "start param "+arg.toString());

        if(arg instanceof Map) {
            if(this.rtcRoom == null || this.rtcRoom.getRemoteUsers() == null) {
                RCLog.i(LOG_TAG +"error not in room or remote users don't exist");
                return;
            }
            Map param = (Map)arg;
            int viewId = (Integer) param.get("viewId");
            String userId = (String)param.get("userId");
            RongRTCVideoView view = RCFlutterRTCViewFactory.getInstance().getRenderVideoView(viewId);
            if(view != null) {
                for(String uId : this.rtcRoom.getRemoteUsers().keySet()) {
                    if(uId.equals(userId)) {
                        renderViewForRemoteUser(view,this.rtcRoom.getRemoteUser(uId));
                    }
                }
            }
        }

    }

    private void renderViewForRemoteUser(RongRTCVideoView view,RongRTCRemoteUser user) {
        String LOG_TAG = "renderViewForRemoteUser " ;
        RCLog.i(LOG_TAG + "start");
        if(user == null || user.getRemoteAVStreams() == null) {
            RCLog.e(LOG_TAG+"remote user is null or doesn't have remote streams");
            return;
        }
        for(RongRTCAVInputStream stream : user.getRemoteAVStreams()) {
            if(stream.getMediaType() == MediaType.VIDEO) {
                stream.setRongRTCVideoView(view);
                return;
            }
        }
    }

    private void removePlatformView(Object arg) {
        String LOG_TAG = "removePlatformView " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof Map) {
            Map param = (Map)arg;
            int viewId = (Integer) param.get("viewId");
            RCFlutterRTCViewFactory.getInstance().removeRenderVideoView(viewId);
        }
    }

    private void subscribeAVStream(Object arg, final MethodChannel.Result result) {
        final String LOG_TAG = "subscribeAVStream " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof String) {
            String userId = String.valueOf(arg);
            if (this.rtcRoom == null) {
                RCLog.e(LOG_TAG + "user not in room :" + userId);
                result.success(RTCErrorCode.RongRTCCodeNotInRoom.getValue());
                return;
            }
            if(this.rtcRoom.getRemoteUser(userId) == null) {
                RCLog.e(LOG_TAG + "user doesn't exist :" + userId);
                result.success(RTCErrorCode.RongRTCCodeInvalidUserId.getValue());
                return;
            }
            RongRTCRemoteUser user = this.rtcRoom.getRemoteUser(userId);
            this.rtcRoom.subscribeAvStream(user.getRemoteAVStreams(), new RongRTCResultUICallBack() {
                @Override
                public void onUiSuccess() {
                    RCLog.i(LOG_TAG + " success ");
                    result.success(0);
                }

                @Override
                public void onUiFailed(RTCErrorCode rtcErrorCode) {
                    RCLog.e(LOG_TAG + " error:"+ rtcErrorCode.getValue());
                    result.success(rtcErrorCode.getValue());
                }
            });
        }
    }

    private void unsubscribeAVStream(Object arg, final MethodChannel.Result result) {
        final String LOG_TAG = "unsubscribeAVStream " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof String) {
            String userId = String.valueOf(arg);
            if (this.rtcRoom == null) {
                RCLog.e(LOG_TAG + "user not in room :" + userId);
                result.success(RTCErrorCode.RongRTCCodeNotInRoom.getValue());
                return;
            }
            if(this.rtcRoom.getRemoteUser(userId) == null) {
                RCLog.e(LOG_TAG + "remote user doesn't exist :" + userId);
                result.success(RTCErrorCode.RongRTCCodeInvalidUserId.getValue());
                return;
            }
            RongRTCRemoteUser user = this.rtcRoom.getRemoteUser(userId);
            this.rtcRoom.unSubscribeAVStream(user.getRemoteAVStreams(), new RongRTCResultUICallBack() {
                @Override
                public void onUiSuccess() {
                    RCLog.i(LOG_TAG + " success ");
                    result.success(0);
                }

                @Override
                public void onUiFailed(RTCErrorCode rtcErrorCode) {
                    RCLog.e(LOG_TAG + " error :"+ rtcErrorCode.getValue());
                    result.success(rtcErrorCode.getValue());
                }
            });
        }
    }

    private void getRemoteUsers(Object arg, MethodChannel.Result result) {
        final String LOG_TAG = "getRemoteUsers " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof String) {
            String roomId = String.valueOf(arg);
            if(this.rtcRoom == null || !this.rtcRoom.getRoomId().equals(roomId) || this.rtcRoom.getRemoteUsers() == null) {
                return;
            }
            List list = new ArrayList();
            for(String uid : this.rtcRoom.getRemoteUsers().keySet()) {
                list.add(uid);
            }
            result.success(list);

        }
    }

    private void muteLocalAudio(Object arg) {
        String LOG_TAG = "muteLocalAudio " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            boolean muted = (boolean)map.get("muted");
            this.capture.muteMicrophone(muted);
        }
    }

    private void muteRemoteAudio(Object arg) {
        String LOG_TAG = "muteRemoteAudio " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            boolean muted = (boolean)map.get("muted");
            String userId = (String)map.get("userId");
            if(this.rtcRoom == null) {
                return;
            }
            RongRTCRemoteUser user = this.rtcRoom.getRemoteUser(userId);
            if(user != null && user.getRemoteAVStreams() != null) {
                for(RongRTCAVInputStream stream : user.getRemoteAVStreams()) {
                    if(stream.getMediaType() == MediaType.AUDIO) {
//                        stream.
                        //todo
                    }
                }
            }
        }
    }

    private void switchCamera() {
        String LOG_TAG = "switchCamera " ;
        RCLog.i(LOG_TAG + "start");
        if(this.capture == null) {
            return;
        }
        this.capture.switchCamera();
    }

    private void exchangeVideo(Object arg) {
        String LOG_TAG = "exchangeVideo " ;
        RCLog.i(LOG_TAG + "start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            int viewId1 = (Integer) map.get("viewId1");
            int viewId2 = (Integer) map.get("viewId2");
            RCFlutterRTCViewFactory.getInstance().exchangeVideo(viewId1,viewId2);
        }
    }

    private class RTCEventsListener implements RongRTCEventsListener {

        @Override
        public void onRemoteUserPublishResource(RongRTCRemoteUser rongRTCRemoteUser, List<RongRTCAVInputStream> list) {
            final String userId = rongRTCRemoteUser.getUserId();
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.RemoteUserPublishStreamsCallBack,map);
                    }
                    String LOG_TAG = "onUserStreamPublished ";
                    RCLog.i(LOG_TAG + "user:"+userId);
                }
            });
        }

        @Override
        public void onRemoteUserUnPublishResource(RongRTCRemoteUser rongRTCRemoteUser, List<RongRTCAVInputStream> list) {
            final String userId = rongRTCRemoteUser.getUserId();
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.RemoteUserUnpublishStreamsCallBack,map);
                    }
                    String LOG_TAG = "onUserStreamUnpublished ";
                    RCLog.i(LOG_TAG + "user:"+userId);

                }
            });
        }

        @Override
        public void onRemoteUserAudioStreamMute(RongRTCRemoteUser rongRTCRemoteUser, RongRTCAVInputStream rongRTCAVInputStream, boolean b) {
            final String userId = rongRTCRemoteUser.getUserId();
            final boolean enable = b;
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        map.put("enable",enable);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.RemoteUserAudioEnabledCallBack,map);
                    }
                    String LOG_TAG = "onUserAudioEnabled ";
                    RCLog.i(LOG_TAG + "user:"+userId);
                }
            });

        }

        @Override
        public void onRemoteUserVideoStreamEnabled(RongRTCRemoteUser rongRTCRemoteUser, RongRTCAVInputStream rongRTCAVInputStream, boolean b) {
            final String userId = rongRTCRemoteUser.getUserId();
            final boolean enable = b;
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        map.put("enable",enable);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.RemoteUserVideoEnabledCallBack,map);
                    }
                    String LOG_TAG = "onUserVideoEnabled ";
                    RCLog.i(LOG_TAG + "user:"+userId);

                }
            });
        }

        @Override
        public void onUserJoined(RongRTCRemoteUser rongRTCRemoteUser) {
            final String userId = rongRTCRemoteUser.getUserId();
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.UserJoinedCallBack,map);
                    }
                    String LOG_TAG = "onUserJoined ";
                    RCLog.i(LOG_TAG + "user:"+userId);
                }
            });
        }

        @Override
        public void onUserLeft(RongRTCRemoteUser rongRTCRemoteUser) {
            final String userId = rongRTCRemoteUser.getUserId();
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.UserLeavedCallBack,map);
                    }
                    String LOG_TAG = "onUserLeaved ";
                    RCLog.i(LOG_TAG + "user:"+userId);
                }
            });

        }

        @Override
        public void onUserOffline(RongRTCRemoteUser rongRTCRemoteUser) {
            final String userId = rongRTCRemoteUser.getUserId();
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if(userId != null) {
                        Map map = new HashMap();
                        map.put("userId",userId);
                        methodChannel.invokeMethod(RCFlutterRTCMethodKey.UserLeavedCallBack,map);
                    }
                    String LOG_TAG = "onUserLeaved ";
                    RCLog.i(LOG_TAG + "user:"+userId);
                }
            });
        }

        @Override
        public void onVideoTrackAdd(String s, String s1) {
        }

        @Override
        public void onFirstFrameDraw(String userId, String tag) {
            if(userId == null || RongIMClient.getInstance().getCurrentUserId() == null) {
                return;
            }
            if(userId.equals(RongIMClient.getInstance().getCurrentUserId())) {
                // do nothing
                // 和 iOS 同步，iOS 不会回调自己的第一关键帧的到达
                return;
            }
            final String fUserId = userId;
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    Map map = new HashMap();
                    map.put("userId",fUserId);
                    methodChannel.invokeMethod(RCFlutterRTCMethodKey.RemoteUserFirstKeyframeCallBack,map);

                    String LOG_TAG = "onUserFirstKeyframeReceived ";
                    RCLog.i(LOG_TAG + "user:"+fUserId);
                }
            });

        }

        @Override
        public void onLeaveRoom() {

        }

        @Override
        public void onReceiveMessage(Message message) {

        }
    }

    private RongRTCCapture getCapture() {
        if(capture == null) {
            capture = RongRTCCapture.getInstance();
            capture.init(context);
        }
        return capture;
    }

    public Context getContext() {
        return context;
    }
}
