package io.rong.flutter.rtclib.agent.view;

import cn.rongcloud.rtc.api.report.StatusBean;

public class RCFlutterStatusBean {

  private StatusBean statusBean;

  public RCFlutterStatusBean(StatusBean statusBean) {
    this.statusBean = statusBean;
  }

  public String getId() {
    return this.statusBean.id;
  }

  public String getUid() {
    return this.statusBean.uid;
  }

  public String getCodecName() {
    return this.statusBean.codecName;
  }

  public String getMediaType() {
    return this.statusBean.mediaType;
  }

  public long getPacketLostRate() {
    return this.statusBean.packetLostRate;
  }

  public boolean isSend() {
    return this.statusBean.isSend;
  }

  //    public long getPackets() {
  //        return this.statusBean.packets;
  //    }
  //
  //    public long getPacketsLost() {
  //        return this.statusBean.packetsLost;
  //    }

  public int getFrameHeight() {
    return this.statusBean.frameHeight;
  }

  public int getFrameWidth() {
    return this.statusBean.frameWidth;
  }

  public int getFrameRate() {
    return this.statusBean.frameRate;
  }

  public long getBitRate() {
    return this.statusBean.bitRate;
  }

  public int getRtt() {
    return this.statusBean.rtt;
  }

  public int getGoogJitterReceived() {
    return this.statusBean.googJitterReceived;
  }

  public int getGoogFirsReceived() {
    return this.statusBean.googFirsReceived;
  }

  public int getGoogRenderDelayMs() {
    return this.statusBean.googRenderDelayMs;
  }

  public String getAudioOutputLevel() {
    return this.statusBean.audioOutputLevel;
  }

  public String getCodecImplementationName() {
    return this.statusBean.codecImplementationName;
  }

  public String getGoogNacksReceived() {
    return this.statusBean.googNacksReceived;
  }

  public String getGoogPlisReceived() {
    return this.statusBean.googPlisReceived;
  }
}
