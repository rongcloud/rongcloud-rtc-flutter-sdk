package io.rong.flutter.rtclib.agent.room;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import cn.rongcloud.rtc.api.RCRTCEngine;
import cn.rongcloud.rtc.api.RCRTCLocalUser;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.stream.RCRTCCameraOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCLiveInfo;
import cn.rongcloud.rtc.api.stream.RCRTCMicOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCOutputStream;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.flutter.rtclib.agent.RCFlutterEngine;
import io.rong.flutter.rtclib.agent.stream.RCFlutterCameraOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterInputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterLiveInfo;
import io.rong.flutter.rtclib.agent.stream.RCFlutterMicOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterOutputStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterTempStream;
import io.rong.flutter.rtclib.agent.stream.RCFlutterVideoOutputStream;
import io.rong.flutter.rtclib.utils.RCFlutterDebugChecker;
import io.rong.flutter.rtclib.utils.RCFlutterLog;
import io.rong.flutter.rtclib.utils.UIThreadHandler;

public class RCFlutterLocalUser extends RCFlutterUser {

  private static final String TAG = "RCFlutterLocalUser";

  private static final String METHOD_PUB_DEFAULT = "publishDefaultStreams";
  private static final String METHOD_UNPUB_DEFAULT = "unpublishDefaultStreams";
  private static final String METHOD_PUB_LIVE_STREAMS = "publishLiveStreams";
  private static final String METHOD_PUB_LIVE_STREAM = "publishLiveStream";
  private static final String METHOD_PUB_STREAMS = "publishStreams";
  private static final String METHOD_UNPUB_STREAMS = "unpublishStreams";
  private static final String METHOD_SUB_STREAMS = "subscribeStreams";
  private static final String METHOD_UNSUB_STREAMS = "unSubscribeStreams";
  private static final String METHOD_GET_STREAMS = "getStreams";
  //    private static final String METHOD_SUB_STREAM = "subscribeStreams";

  private final BinaryMessenger bMsg;
  private final RCRTCLocalUser rtcLocalUser;
  private final List<RCFlutterOutputStream> streamList = new ArrayList<>();

  public RCFlutterLocalUser(BinaryMessenger msg, RCRTCLocalUser localUser) {
    super(msg, localUser);
    bMsg = msg;
    rtcLocalUser = localUser;
    List<RCRTCOutputStream> rtcStreams = localUser.getStreams();
    for (RCRTCOutputStream stream : rtcStreams) {
      RCFlutterOutputStream flutterOutputStream;
      if (stream instanceof RCRTCMicOutputStream) {
        flutterOutputStream = new RCFlutterMicOutputStream(bMsg, stream);
      } else if (stream instanceof RCRTCCameraOutputStream) {
        flutterOutputStream = new RCFlutterCameraOutputStream(bMsg, stream);
      } else {
        RCFlutterDebugChecker.throwError("Need to add unknown type!");
        break;
      }
      streamList.add(flutterOutputStream);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    RCFlutterLog.d(TAG, "onMethodCall = " + call.method);
    switch (call.method) {
      case METHOD_PUB_DEFAULT:
        publishDefaultStreams(result);
        break;
      case METHOD_UNPUB_DEFAULT:
        unpublishDefaultStreams(result);
        break;
      case METHOD_PUB_STREAMS:
        publishStreams(call, result);
        break;
      case METHOD_UNPUB_STREAMS:
        unpublishStreams(call, result);
        break;
      case METHOD_SUB_STREAMS:
        subscribeStreams(call, result);
        break;
      case METHOD_PUB_LIVE_STREAMS:
        publishDefaultLiveStreams(result);
        break;
      case METHOD_PUB_LIVE_STREAM:
        publishLiveStream(call, result);
        break;
        //      case METHOD_GET_STREAMS:
        //        getStreams(result);
        //        break;
    }
  }

  public String getId() {
    return rtcLocalUser.getUserId();
  }

  public List<RCFlutterOutputStream> getStreams() {
    return streamList;
  }

  //  public void getStreams(Result result) {
  //    List<RCRTCOutputStream> rtcStreams = rtcLocalUser.getStreams();
  //    List<String> jsonStreams = new ArrayList<>(rtcStreams.size());
  //    streamList.clear();
  //    for (RCRTCOutputStream stream : rtcStreams) {
  //      RCFlutterOutputStream flutterOutputStream;
  //      if (stream instanceof RCRTCMicOutputStream) {
  //        flutterOutputStream = new RCFlutterMicOutputStream(bMsg, stream);
  //      } else if (stream instanceof RCRTCCameraOutputStream) {
  //        flutterOutputStream = new RCFlutterCameraOutputStream(bMsg, stream);
  //      } else if (stream instanceof RCRTCFileVideoOutputStream) {
  //        flutterOutputStream =
  //            new RCFlutterFileVideoOutputStream(bMsg, (RCRTCFileVideoOutputStream) stream);
  //      } else {
  //        RCFlutterDebugChecker.throwError("Need to add unknown type!");
  //        break;
  //      }
  //      streamList.add(flutterOutputStream);
  //      jsonStreams.add(JSON.toJSONString(flutterOutputStream));
  //    }
  //    result.success(jsonStreams);
  //  }

  public void publishDefaultStreams(final Result result) {
    rtcLocalUser.publishDefaultStreams(
        new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
            result.success(0);
          }

          @Override
          public void onFailed(RTCErrorCode code) {
            result.success(code.getValue());
          }
        });
  }

  private void publishDefaultLiveStreams(final Result result) {
    rtcLocalUser.publishDefaultLiveStreams(
        new IRCRTCResultDataCallback<RCRTCLiveInfo>() {

          @Override
          public void onSuccess(RCRTCLiveInfo info) {

            result.success(JSON.toJSONString(new RCFlutterLiveInfo(bMsg, info)));
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            result.error(String.valueOf(rtcErrorCode.getValue()), rtcErrorCode.getReason(), null);
          }
        });
  }

  private void publishLiveStream(MethodCall call, Result result) {
    List<String> jsonStreams = Collections.singletonList((String) call.arguments);
    List<RCRTCOutputStream> streams = mapRTCOutputStreams(jsonStreams);
    if (!streams.isEmpty()) {
      rtcLocalUser.publishLiveStream(
          streams.get(0),
          new IRCRTCResultDataCallback<RCRTCLiveInfo>() {
            @Override
            public void onSuccess(RCRTCLiveInfo rcrtcLiveInfo) {
              RCFlutterLiveInfo rcFlutterLiveInfo = new RCFlutterLiveInfo(bMsg, rcrtcLiveInfo);
              JSONObject jsonObject = new JSONObject();
              jsonObject.put("code", 0);
              jsonObject.put("content", JSON.toJSONString(rcFlutterLiveInfo));
              UIThreadHandler.success(result, jsonObject.toJSONString());
            }

            @Override
            public void onFailed(RTCErrorCode rtcErrorCode) {
              JSONObject jsonObject = new JSONObject();
              jsonObject.put("code", rtcErrorCode.getValue());
              jsonObject.put("content", rtcErrorCode.getReason());
              UIThreadHandler.success(result, jsonObject.toJSONString());
            }
          });
    } else {
      RCFlutterLog.e(TAG, "arguments:" + call.arguments);
    }
  }

  private void unpublishDefaultStreams(Result result) {
    rtcLocalUser.unpublishDefaultStreams(
        new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
            result.success(0);
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            //            String errorCode = String.valueOf(rtcErrorCode.getValue());
            result.success(rtcErrorCode.getValue());
          }
        });
  }

  private void publishStreams(MethodCall call, Result result) {
    List<String> jsonStreams = (List<String>) call.arguments;
    List<RCRTCOutputStream> rtcStreams = mapRTCOutputStreams(jsonStreams);
    rtcLocalUser.publishStreams(
        rtcStreams,
        new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
            result.success(0);
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            result.success(rtcErrorCode.getValue());
          }
        });
  }

  private void unpublishStreams(MethodCall call, Result result) {
    List<String> jsonStreams = (List<String>) call.arguments;
    List<RCRTCOutputStream> rtcStreams = mapRTCOutputStreams(jsonStreams);
    rtcLocalUser.unpublishStreams(
        rtcStreams,
        new IRCRTCResultCallback() {
          @Override
          public void onSuccess() {
            result.success(0);
          }

          @Override
          public void onFailed(RTCErrorCode rtcErrorCode) {
            result.success(rtcErrorCode.getValue());
          }
        });
  }

  private List<RCRTCOutputStream> mapRTCOutputStreams(List<String> jsonStreams) {
    RCRTCEngine rtcEngine = RCRTCEngine.getInstance();
    RCRTCCameraOutputStream cameraOutputStream = rtcEngine.getDefaultVideoStream();
    RCRTCMicOutputStream micOutputStream = rtcEngine.getDefaultAudioStream();

    List<RCRTCOutputStream> rtcStreams = new ArrayList<>();
    for (String jsonStream : jsonStreams) {
      JSONObject stream = JSON.parseObject(jsonStream);
      String streamId = stream.getString("streamId");
      int type = stream.getIntValue("type");
      RCRTCMediaType mediaType = RCRTCMediaType.getMediaType(type);

      if (TextUtils.equals(cameraOutputStream.getStreamId(), streamId)
          && cameraOutputStream.getMediaType() == mediaType) {
        rtcStreams.add(cameraOutputStream);
        continue;
      }

      if (TextUtils.equals(micOutputStream.getStreamId(), streamId)
          && micOutputStream.getMediaType() == mediaType) {
        rtcStreams.add(micOutputStream);
        continue;
      }

      RCFlutterVideoOutputStream flutterStream =
          RCFlutterEngine.getInstance().getFlutterVideoOutputStream(streamId, type);
      if (flutterStream != null) {
        rtcStreams.add((RCRTCOutputStream) flutterStream.getRtcStream());
      }
    }
    return rtcStreams;
  }

  private void subscribeStreams(MethodCall call, Result result) {
    String streamListJson = (String) call.arguments;
    List<RCFlutterTempStream> tempStreams =
        JSONArray.parseArray(streamListJson, RCFlutterTempStream.class);

    ArrayList<RCFlutterInputStream> inputStreamList =
        RCFlutterEngine.getInstance().getAllInputStreamList();

    ArrayList<RCRTCInputStream> targetStreamList = new ArrayList<>();
    for (RCFlutterTempStream tempStream : tempStreams) {
      live:
      for (RCFlutterInputStream inputStream : inputStreamList) {
        if (tempStream.getStreamId().equals(inputStream.getStreamId())
            && tempStream.getType() == inputStream.getType()) {
          targetStreamList.add((RCRTCInputStream) inputStream.getRtcStream());
          break live;
        }
      }
    }

    if (targetStreamList.size() != tempStreams.size()) { // todo 异步会怎样？
      RCFlutterDebugChecker.throwError("target stream not found!");
      result.success(-1);
    }

    if (targetStreamList.size() != 0) {
      rtcLocalUser.subscribeStreams(
          targetStreamList,
          new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
              result.success(0);
            }

            @Override
            public void onFailed(RTCErrorCode code) {
              result.success(code.getValue());
            }
          });
    }
  }
}
