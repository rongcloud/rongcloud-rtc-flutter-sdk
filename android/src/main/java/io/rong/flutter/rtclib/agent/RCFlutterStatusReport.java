package io.rong.flutter.rtclib.agent;

import java.util.HashMap;

import cn.rongcloud.rtc.api.report.StatusBean;
import cn.rongcloud.rtc.api.report.StatusReport;
import io.rong.flutter.rtclib.agent.view.RCFlutterStatusBean;

public class RCFlutterStatusReport {

  public HashMap<String, StatusBean> statusVideoSends = new HashMap();
  public HashMap<String, StatusBean> statusAudioSends = new HashMap();
  public HashMap<String, StatusBean> statusVideoRcvs = new HashMap();
  public HashMap<String, StatusBean> statusAudioRcvs = new HashMap();
  public long bitRateSend;
  public long bitRateRcv;
  public int rtt;
  long bitRateTotalSend;
  long bitRateTotalRcv;
  public String networkType;
  public String ipAddress;
  public String googAvailableReceiveBandwidth;
  public String googAvailableSendBandwidth;
  public String packetsDiscardedOnSend;

  private StatusReport statusReport;

  public RCFlutterStatusReport(StatusReport statusReport) {
    this.statusReport = statusReport;
  }

  public HashMap<String, RCFlutterStatusBean> getStatusVideoSends() {
    HashMap<String, RCFlutterStatusBean> statusBeanHashMap = new HashMap<>();
    for (String key : this.statusReport.statusVideoSends.keySet()) {
      statusBeanHashMap.put(
          key, new RCFlutterStatusBean(this.statusReport.statusVideoSends.get(key)));
    }

    return statusBeanHashMap;
  }

  public HashMap<String, RCFlutterStatusBean> getStatusAudioSends() {
    HashMap<String, RCFlutterStatusBean> statusBeanHashMap = new HashMap<>();
    for (String key : this.statusReport.statusAudioSends.keySet()) {
      statusBeanHashMap.put(
          key, new RCFlutterStatusBean(this.statusReport.statusAudioSends.get(key)));
    }

    return statusBeanHashMap;
  }

  public HashMap<String, RCFlutterStatusBean> getStatusVideoRcvs() {
    HashMap<String, RCFlutterStatusBean> statusBeanHashMap = new HashMap<>();
    for (String key : this.statusReport.statusVideoRcvs.keySet()) {
      statusBeanHashMap.put(
          key, new RCFlutterStatusBean(this.statusReport.statusVideoRcvs.get(key)));
    }

    return statusBeanHashMap;
  }

  public HashMap<String, RCFlutterStatusBean> getStatusAudioRcvs() {
    HashMap<String, RCFlutterStatusBean> statusBeanHashMap = new HashMap<>();
    for (String key : this.statusReport.statusAudioRcvs.keySet()) {
      statusBeanHashMap.put(
          key, new RCFlutterStatusBean(this.statusReport.statusAudioRcvs.get(key)));
    }

    return statusBeanHashMap;
  }

  public long getBitRateSend() {
    return this.statusReport.bitRateSend;
  }

  public long getBitRateRcv() {
    return this.statusReport.bitRateRcv;
  }

  public int getRtt() {
    return this.statusReport.rtt;
  }

  public String getNetworkType() {
    return this.statusReport.networkType;
  }

  public String getIpAddress() {
    return this.statusReport.ipAddress;
  }

  public String getGoogAvailableReceiveBandwidth() {
    return this.statusReport.googAvailableReceiveBandwidth;
  }

  public String getGoogAvailableSendBandwidth() {
    return this.statusReport.googAvailableSendBandwidth;
  }

  public String getPacketsDiscardedOnSend() {
    return this.statusReport.packetsDiscardedOnSend;
  }
}
