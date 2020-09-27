package io.rong.flutter.rtclib.agent.room;

import androidx.annotation.NonNull;
import cn.rongcloud.rtc.api.RCRTCRemoteUser;
import cn.rongcloud.rtc.api.RCRTCRoom;
import cn.rongcloud.rtc.api.callback.IRCRTCRoomEventsListener;
import cn.rongcloud.rtc.api.stream.RCRTCAudioInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.serializer.SerializerFeature;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.agent.stream.RCFlutterAudioInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoInputStream;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;
import java.util.ArrayList;
import java.util.List;

public class RCFlutterRoom implements MethodCallHandler {

  private static final String TAG = "RCFlutterRoom";
  private static final String CHANNEL_TAG = "rong.flutter.rtclib/Room:";

  private final BinaryMessenger bMsg;
  private final MethodChannel channel;
  private final RCRTCRoom rtcRoom;
  private final RCFlutterLocalUser localUser;
  private final List<RCFlutterRemoteUser> remoteUserList = new ArrayList<>();

  public RCFlutterRoom(BinaryMessenger msg, RCRTCRoom room) {
    bMsg = msg;
    channel = new MethodChannel(msg, CHANNEL_TAG + room.getRoomId());
    channel.setMethodCallHandler(this);
    rtcRoom = room;
    localUser = new RCFlutterLocalUser(bMsg, rtcRoom.getLocalUser());
    for (RCRTCRemoteUser remoteUser : rtcRoom.getRemoteUsers()) {
      remoteUserList.add(new RCFlutterRemoteUser(bMsg, remoteUser));
    }
    rtcRoom.registerRoomListener(
        new IRCRTCRoomEventsListener() {
          @Override
          public void onRemoteUserPublishResource(RCRTCRemoteUser rtcRemoteUser, List<RCRTCInputStream> rtcStreamList) {
            RCFlutterLog.d(TAG, "onRemoteUserPublishResource userId = " + rtcRemoteUser.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(rtcRemoteUser);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
              return;
            }
            List<RCFlutterInputStream> streamList = new ArrayList<>();
            for (RCRTCInputStream stream : rtcStreamList) {
              if (stream.getMediaType() == RCRTCMediaType.VIDEO) {
                streamList.add(new RCFlutterVideoInputStream(bMsg, (RCRTCVideoInputStream) stream));
              } else if (stream.getMediaType() == RCRTCMediaType.AUDIO) {
                streamList.add(new RCFlutterAudioInputStream(bMsg, (RCRTCAudioInputStream) stream));
              }
            }
            remoteUser.getStreamList().addAll(streamList);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            jsonObj.put("streamList", streamList);
            String jsonStr = JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onRemoteUserPublishResource", jsonStr);
                  }
                });
          }

          @Override
          public void onRemoteUserMuteAudio(
              RCRTCRemoteUser rtcRemoteUser, RCRTCInputStream rtcStream, boolean enable) {
            RCFlutterLog.d(TAG, "onRemoteUserMuteAudio userId = " + rtcRemoteUser.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(rtcRemoteUser);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
              return;
            }
            RCFlutterInputStream inputStream = toInputStream(remoteUser, rtcStream);
            if (!RCFlutterDebugChecker.notNull(inputStream)) {
              return;
            }
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            jsonObj.put("inputStream", inputStream);
            jsonObj.put("enable", enable);
            String jsonStr =
                JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onRemoteUserMuteAudio", jsonStr);
                  }
                });
          }

          @Override
          public void onRemoteUserMuteVideo(
              RCRTCRemoteUser rtcRemoteUser, RCRTCInputStream rtcStream, boolean enable) {
            RCFlutterLog.d(TAG, "onRemoteUserMuteVideo userId = " + rtcRemoteUser.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(rtcRemoteUser);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
              return;
            }
            RCFlutterInputStream inputStream = toInputStream(remoteUser, rtcStream);
            if (!RCFlutterDebugChecker.notNull(inputStream)) {
              return;
            }
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            jsonObj.put("inputStream", inputStream);
            jsonObj.put("enable", enable);
            String jsonStr =
                JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onRemoteUserMuteVideo", jsonStr);
                  }
                });
          }

          @Override
          public void onRemoteUserUnpublishResource(
              RCRTCRemoteUser rtcRemoteUser, List<RCRTCInputStream> rtcStreamList) {
            RCFlutterLog.d(
                TAG, "onRemoteUserUnpublishResource userId = " + rtcRemoteUser.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(rtcRemoteUser);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
              return;
            }
            List<RCFlutterInputStream> streamList = new ArrayList<>();
            for (RCRTCInputStream rtcStream : rtcStreamList) {
              RCFlutterInputStream inputStream = toInputStream(remoteUser, rtcStream);
              if (!RCFlutterDebugChecker.notNull(inputStream)) {
                return;
              }
              streamList.add(inputStream);
            }
            remoteUser.getStreamList().removeAll(streamList);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            jsonObj.put("streamList", streamList);
            String jsonStr =
                JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onRemoteUserUnpublishResource", jsonStr);
                  }
                });
          }

          @Override
          public void onUserJoined(RCRTCRemoteUser rtcRemoteUser) {
            RCFlutterLog.d(TAG, "onUserJoined userId = " + rtcRemoteUser.getUserId());
            RCFlutterRemoteUser remoteUser = new RCFlutterRemoteUser(bMsg, rtcRemoteUser);
            remoteUserList.add(remoteUser);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            UIThreadHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onUserJoined", jsonObj.toJSONString());
                  }
                });
          }

          @Override
          public void onUserLeft(RCRTCRemoteUser rtcRemoteUser) {
            RCFlutterLog.d(TAG, "onUserLeft userId = " + rtcRemoteUser.getUserId());
            for (RCFlutterRemoteUser remoteUser : remoteUserList) {
              if (remoteUser.getId().equals(rtcRemoteUser.getUserId())) {
                remoteUserList.remove(remoteUser);
                JSONObject jsonObj = new JSONObject();
                jsonObj.put("remoteUser", remoteUser);
                UIThreadHandler.post(
                    new Runnable() {
                      @Override
                      public void run() {
                        channel.invokeMethod("onUserLeft", jsonObj.toJSONString());
                      }
                    });
                return;
              }
            }
            RCFlutterDebugChecker.throwError("targetUser not found!");
          }

          @Override
          public void onUserOffline(RCRTCRemoteUser rtcRemoteUser) {
            RCFlutterLog.d(TAG, "onUserOffline userId = " + rtcRemoteUser.getUserId());
            for (RCFlutterRemoteUser RCFlutterRemoteUser : remoteUserList) {
              if (RCFlutterRemoteUser.getId().equals(rtcRemoteUser.getUserId())) {
                remoteUserList.remove(RCFlutterRemoteUser);
                JSONObject jsonObj = new JSONObject();
                jsonObj.put("remoteUser", RCFlutterRemoteUser);
                UIThreadHandler.post(
                    new Runnable() {
                      @Override
                      public void run() {
                        channel.invokeMethod("onUserOffline", jsonObj.toJSONString());
                      }
                    });
                return;
              }
            }
            RCFlutterDebugChecker.throwError("targetUser not found!");
          }

          @Override
          public void onLeaveRoom(int code) {
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("code", code);
            UIThreadHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onLeaveRoom", jsonObj.toJSONString());
                  }
                });
          }
        });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {}

  public String getId() {
    return rtcRoom.getRoomId();
  }

  public RCFlutterLocalUser getLocalUser() {
    return localUser;
  }

  public List<RCFlutterRemoteUser> getRemoteUserList() {
    return remoteUserList;
  }

  public RCFlutterRemoteUser getRemoteUser(String userId) {
    RCFlutterRemoteUser target = null;
    for (RCFlutterRemoteUser RCFlutterRemoteUser : remoteUserList) {
      if (RCFlutterRemoteUser.getId().equals(userId)) {
        target = RCFlutterRemoteUser;
        break;
      }
    }
    return target;
  }

  private RCFlutterRemoteUser toRemoteUser(RCRTCRemoteUser rtcRemoteUser) {
    RCFlutterRemoteUser targetUser = null;
    for (RCFlutterRemoteUser RCFlutterRemoteUser : remoteUserList) {
      if (RCFlutterRemoteUser.getId().equals(rtcRemoteUser.getUserId())) {
        targetUser = RCFlutterRemoteUser;
        break;
      }
    }
    return targetUser;
  }

  private RCFlutterInputStream toInputStream(
      RCFlutterRemoteUser remoteUser, RCRTCInputStream rtcInputStream) {
    RCFlutterInputStream targetInputStream = null;
    for (RCFlutterInputStream inputStream : remoteUser.getStreamList()) {
      if (inputStream.getStreamId().equals(rtcInputStream.getStreamId())
          && inputStream.getType() == rtcInputStream.getMediaType().getValue()) {
        targetInputStream = inputStream;
        break;
      }
    }
    return targetInputStream;
  }
}
