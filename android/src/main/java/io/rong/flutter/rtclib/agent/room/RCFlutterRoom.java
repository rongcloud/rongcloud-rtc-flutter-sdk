package io.rong.flutter.rtclib.agent.room;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.serializer.SerializerFeature;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.rongcloud.rtc.api.RCRTCRemoteUser;
import cn.rongcloud.rtc.api.RCRTCRoom;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCRoomEventsListener;
import cn.rongcloud.rtc.api.stream.RCRTCAudioInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RTCErrorCode;
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
import io.rong.flutter.rtclib.utils.ThisClassShouldNotBelongHere;
import io.rong.flutter.rtclib.utils.UIThreadHandler;
import io.rong.imlib.IRongCoreCallback;
import io.rong.imlib.IRongCoreEnum;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;

public class RCFlutterRoom implements MethodCallHandler {

  private static final String TAG = "RCFlutterRoom";
  private static final String CHANNEL_TAG = "rong.flutter.rtclib/Room:";

  private final BinaryMessenger bMsg;
  private final MethodChannel channel;
  private final RCRTCRoom rtcRoom;
  private final RCFlutterLocalUser localUser;
  private final List<RCFlutterRemoteUser> remoteUserList = new ArrayList<>();
  private final List<RCFlutterInputStream> streamList = new ArrayList<>();

  public RCFlutterRoom(BinaryMessenger msg, RCRTCRoom room) {
    bMsg = msg;
    channel = new MethodChannel(msg, CHANNEL_TAG + room.getRoomId());
    channel.setMethodCallHandler(this);
    rtcRoom = room;
    localUser = new RCFlutterLocalUser(bMsg, rtcRoom.getLocalUser());
    for (RCRTCRemoteUser remoteUser : rtcRoom.getRemoteUsers()) {
      remoteUserList.add(new RCFlutterRemoteUser(bMsg, remoteUser));
    }
    rtcRoom.registerRoomListener(new IRCRTCRoomEventsListener() {
        @Override
        public void onRemoteUserPublishResource(RCRTCRemoteUser user, List<RCRTCInputStream> streams) {
            RCFlutterLog.d(TAG, "onRemoteUserPublishResource userId = " + user.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(user);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
                return;
            }
            List<RCFlutterInputStream> streamList = new ArrayList<>();
            for (RCRTCInputStream stream : streams) {
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
                    () -> channel.invokeMethod("onRemoteUserPublishResource", jsonStr)
            );
        }

        @Override
        public void onRemoteUserUnpublishResource(RCRTCRemoteUser user, List<RCRTCInputStream> streams) {
            RCFlutterLog.d(TAG, "onRemoteUserUnpublishResource userId = " + user.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(user);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
                return;
            }
            List<RCFlutterInputStream> streamList = new ArrayList<>();
            for (RCRTCInputStream rtcStream : streams) {
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
            String jsonStr = JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onRemoteUserUnPublishResource", jsonStr)
            );
        }

        @Override
        public void onPublishLiveStreams(List<RCRTCInputStream> streams) {
            RCFlutterLog.d(TAG, "onPublishLiveStreams");
            List<RCFlutterInputStream> streamList = new ArrayList<>();
            for (RCRTCInputStream stream : streams) {
                RCFlutterInputStream inputStream = addStream(stream);
                streamList.add(inputStream);
            }
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("streamList", streamList);
            String jsonStr = JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onRemoteUserPublishLiveResource", jsonStr)
            );
        }

        @Override
        public void onUnpublishLiveStreams(List<RCRTCInputStream> streams) {
            RCFlutterLog.d(TAG, "onUnpublishLiveStreams");
            List<RCFlutterInputStream> streamList = getStreams(streams);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("streamList", streamList);
            String jsonStr = JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onRemoteUserUnPublishLiveResource", jsonStr)
            );
        }

        @Override
        public void onRemoteUserMuteAudio(RCRTCRemoteUser user, RCRTCInputStream stream, boolean mute) {
            RCFlutterLog.d(TAG, "onRemoteUserMuteAudio userId = " + user.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(user);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
                return;
            }
            RCFlutterInputStream inputStream = toInputStream(remoteUser, stream);
            if (!RCFlutterDebugChecker.notNull(inputStream)) {
                return;
            }
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            jsonObj.put("inputStream", inputStream);
            jsonObj.put("enable", !mute);
            String jsonStr = JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onRemoteUserMuteAudio", jsonStr)
            );
        }

        @Override
        public void onRemoteUserMuteVideo(RCRTCRemoteUser user, RCRTCInputStream stream, boolean mute) {
            RCFlutterLog.d(TAG, "onRemoteUserMuteVideo userId = " + user.getUserId());
            RCFlutterRemoteUser remoteUser = toRemoteUser(user);
            if (!RCFlutterDebugChecker.notNull(remoteUser)) {
                return;
            }
            RCFlutterInputStream inputStream = toInputStream(remoteUser, stream);
            if (!RCFlutterDebugChecker.notNull(inputStream)) {
                return;
            }
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            jsonObj.put("inputStream", inputStream);
            jsonObj.put("enable", !mute);
            String jsonStr = JSON.toJSONString(jsonObj, SerializerFeature.DisableCircularReferenceDetect);
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onRemoteUserMuteVideo", jsonStr)
            );
        }

        @Override
        public void onUserJoined(RCRTCRemoteUser user) {
            RCFlutterLog.d(TAG, "onUserJoined userId = " + user.getUserId());
            RCFlutterRemoteUser remoteUser = new RCFlutterRemoteUser(bMsg, user);
            remoteUserList.add(remoteUser);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("remoteUser", remoteUser);
            UIThreadHandler.post(
                    () -> channel.invokeMethod("onUserJoined", jsonObj.toJSONString())
            );
        }

        @Override
        public void onUserLeft(RCRTCRemoteUser user) {
            RCFlutterLog.d(TAG, "onUserLeft userId = " + user.getUserId());
            for (RCFlutterRemoteUser remoteUser : remoteUserList) {
                if (remoteUser.getId().equals(user.getUserId())) {
                    remoteUserList.remove(remoteUser);
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("remoteUser", remoteUser);
                    UIThreadHandler.post(
                            () -> channel.invokeMethod("onUserLeft", jsonObj.toJSONString())
                    );
                    return;
                }
            }
            RCFlutterDebugChecker.throwError("targetUser not found!");
        }

        @Override
        public void onUserOffline(RCRTCRemoteUser user) {
            RCFlutterLog.d(TAG, "onUserOffline userId = " + user.getUserId());
            for (RCFlutterRemoteUser RCFlutterRemoteUser : remoteUserList) {
                if (RCFlutterRemoteUser.getId().equals(user.getUserId())) {
                    remoteUserList.remove(RCFlutterRemoteUser);
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("remoteUser", RCFlutterRemoteUser);
                    UIThreadHandler.post(
                            () -> channel.invokeMethod("onUserOffline", jsonObj.toJSONString())
                    );
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
                    () -> channel.invokeMethod("onLeaveRoom", jsonObj.toJSONString())
            );
        }
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
      RCFlutterLog.d(TAG, "onMethodCall = " + call.method);
      switch (call.method) {
          case "setRoomAttributeValue":
              setRoomAttributeValue(call, result);
              break;
          case "deleteRoomAttributes":
              deleteRoomAttributes(call, result);
              break;
          case "getRoomAttributes":
              getRoomAttributes(call, result);
              break;
          case "sendMessage":
              sendMessage(call, result);
              break;
          case "getLiveStreams":
              getLiveStreams(result);
              break;
      }
  }

  private void setRoomAttributeValue(MethodCall call, Result result) {
      String key = call.argument("key");
      String value = call.argument("value");
      String object = call.argument("object");
      String content = call.argument("content");
      assert object != null : "setRoomAttributeValue object should not be null!!!";
      MessageContent message = ThisClassShouldNotBelongHere.getInstance().string2MessageContent(object, content);
      rtcRoom.setRoomAttributeValue(value, key, message, new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
              UIThreadHandler.success(result, 0);
          }

          @Override
          public void onFailed(RTCErrorCode errorCode) {
              UIThreadHandler.success(result, errorCode.getValue());
          }
      });
  }

  private void deleteRoomAttributes(MethodCall call, Result result) {
      List<String> keys = JSONArray.parseArray(call.argument("keys"), String.class);
      String object = call.argument("object");
      String content = call.argument("content");
      assert object != null : "deleteRoomAttributes object should not be null!!!";
      MessageContent message = ThisClassShouldNotBelongHere.getInstance().string2MessageContent(object, content);
      rtcRoom.deleteRoomAttributes(keys, message, new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
              UIThreadHandler.success(result, 0);
          }

          @Override
          public void onFailed(RTCErrorCode errorCode) {
              UIThreadHandler.success(result, errorCode.getValue());
          }
      });
  }

  private void getRoomAttributes(MethodCall call, Result result) {
      List<String> keys = JSONArray.parseArray(call.argument("keys"), String.class);
      rtcRoom.getRoomAttributes(keys, new IRCRTCResultDataCallback<Map<String, String>>() {
          @Override
          public void onSuccess(Map<String, String> data) {
              UIThreadHandler.success(result, data);
          }

          @Override
          public void onFailed(Map<String, String> data, RTCErrorCode errorCode) {
              super.onFailed(data, errorCode);
              UIThreadHandler.success(result, data);
          }

          @Override
          public void onFailed(RTCErrorCode errorCode) {
          }
      });
  }

  private void sendMessage(MethodCall call, Result result) {
      String object = call.argument("object");
      String content = call.argument("content");
      assert object != null : "sendMessage object should not be null!!!";
      MessageContent message = ThisClassShouldNotBelongHere.getInstance().string2MessageContent(object, content);
      rtcRoom.sendMessage(message, new IRongCoreCallback.ISendMessageCallback() {
          @Override
          public void onAttached(Message message) {

          }

          @Override
          public void onSuccess(Message message) {
              Map<String, Integer> data = new HashMap<>();
              data.put("id", message.getMessageId());
              data.put("code", 0);
              UIThreadHandler.success(result, data);
          }

          @Override
          public void onError(Message message, IRongCoreEnum.CoreErrorCode code) {
              Map<String, Integer> data = new HashMap<>();
              data.put("id", message.getMessageId());
              data.put("code", code.getValue());
              UIThreadHandler.success(result, data);
          }
      });
  }

  private void getLiveStreams(Result result) {
      List<RCRTCInputStream> streams = rtcRoom.getLiveStreams();
      List<String> jsonStreams = new ArrayList<>(streams.size());
      for (RCRTCInputStream stream : streams) {
          RCFlutterInputStream inputStream = addStream(stream);
          jsonStreams.add(JSON.toJSONString(inputStream));
      }
      UIThreadHandler.success(result, jsonStreams);
  }

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

  private RCFlutterInputStream toInputStream(RCFlutterRemoteUser remoteUser, RCRTCInputStream rtcInputStream) {
    RCFlutterInputStream targetInputStream = null;
    for (RCFlutterInputStream inputStream : remoteUser.getStreamList()) {
      if (inputStream.getStreamId().equals(rtcInputStream.getStreamId()) &&
              inputStream.getType() == rtcInputStream.getMediaType().getValue()) {
        targetInputStream = inputStream;
        break;
      }
    }
    return targetInputStream;
  }

  private RCFlutterInputStream addStream(RCRTCInputStream is) {
      List<RCFlutterInputStream> temp = new ArrayList<>();
      for (RCFlutterInputStream stream : streamList) {
          if (stream.getStreamId().equals(is.getStreamId()) && stream.getType() == is.getMediaType().getValue())
              temp.add(stream);
      }
      streamList.removeAll(temp);
      RCFlutterInputStream stream = null;
      if (is.getMediaType() == RCRTCMediaType.VIDEO) {
          stream = new RCFlutterVideoInputStream(bMsg, (RCRTCVideoInputStream) is);
      } else if (is.getMediaType() == RCRTCMediaType.AUDIO) {
          stream = new RCFlutterAudioInputStream(bMsg, (RCRTCAudioInputStream) is);
      }
      if (stream != null) streamList.add(stream);
      return stream;
  }

  private List<RCFlutterInputStream> getStreams(List<RCRTCInputStream> streams) {
      List<RCFlutterInputStream> result = new ArrayList<>();
      for (RCFlutterInputStream stream : streamList) {
          for (RCRTCInputStream is : streams) {
              if (stream.getStreamId().equals(is.getStreamId()) && stream.getType() == is.getMediaType().getValue()) {
                  result.add(stream);
                  break;
              }
          }
      }
      return result;
  }

  public List<RCFlutterInputStream> getStreamList() {
      return streamList;
  }
}
