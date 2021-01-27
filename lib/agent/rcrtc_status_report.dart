class StatusReport {
  /// 视频发送状态信息
  /// key为StreamId("userId"_"tag")

  final Map<String, StatusBean> statusVideoSends = {};

  /// 音频发送状态信息
  /// key为StreamId("userId"_"tag")

  final Map<String, StatusBean> statusAudioSends = {};

  /// 视频接收状态信息
  /// key为StreamId("userId"_"tag")

  final Map<String, StatusBean> statusVideoRcvs = {};

  /// 音频接收状态信息
  /// key为StreamId("userId"_"tag")

  final Map<String, StatusBean> statusAudioRcvs = {};

  /// 发送码率大小，单位是 kbps
  final String bitRateSend;

  /// 接收码率大小，单位是 kbps
  final String bitRateRcv;

  /// 往返延时(ms)
  final String rtt;

  /// 网络环境
  final String networkType;

  /// 本端IP地址
  final String ipAddress;

  /// 􏲑􏲌􏰁􏰉􏱚􏱛可用接收宽带
  final String googAvailableReceiveBandwidth;

  /// 可用发送宽带
  final String googAvailableSendBandwidth;

  /// 发送端丢包数
  final String packetsDiscardedOnSend;

  StatusReport.fromJson(Map<String, dynamic> map)
      : this.bitRateRcv = "${map['bitRateRcv']}",
        this.bitRateSend = "${map['bitRateSend']}",
        this.googAvailableReceiveBandwidth = "${map['googAvailableReceiveBandwidth']}",
        this.googAvailableSendBandwidth = "${map['googAvailableSendBandwidth']}",
        this.ipAddress = map.containsKey('ipAddress') ? map['ipAddress'] : 'Unknown',
        this.networkType = map['networkType'],
        this.packetsDiscardedOnSend = "${map['packetsDiscardedOnSend']}",
        this.rtt = "${map['rtt']}" {
    Map<String, dynamic> jsonAudioRcvs = map['statusAudioRcvs'];
    jsonAudioRcvs.forEach((key, value) {
      this.statusAudioRcvs.putIfAbsent(key, () => StatusBean.fromJson(value));
    });

    Map<String, dynamic> jsonAudioSends = map['statusAudioSends'];
    jsonAudioSends.forEach((key, value) {
      this.statusAudioSends.putIfAbsent(key, () => StatusBean.fromJson(value));
    });

    Map<String, dynamic> jsonVideoRcvs = map['statusVideoRcvs'];
    jsonVideoRcvs.forEach((key, value) {
      this.statusVideoRcvs.putIfAbsent(key, () => StatusBean.fromJson(value));
    });

    Map<String, dynamic> jsonVideoSends = map['statusVideoSends'];
    jsonVideoSends.forEach((key, value) {
      this.statusVideoSends.putIfAbsent(key, () => StatusBean.fromJson(value));
    });
  }
}

class StatusBean {
  /// MediaStreamId 格式：userId+"_"+tag
  final String id;

  /// 用户的uid
  final String uid;

  /// 音视频编码格式: H264 / Opus
  final String codecName;

  /// 媒体类型:video/audio
  final String mediaType;

  /// 丢包率:取值范围是 0-100
  final String packetLostRate;

  /// 发送类型，true为发送
  // final int isSend; // iOS 没有暂时去掉

  /// 视频高
  final int frameHeight;

  /// 视频宽
  final int frameWidth;

  /// 视频帧率 FPS
  final int frameRate;

  /// 码率大小，单位是 kbps
  final String bitRate;

  /// 往返延时(ms)
  final String rtt;

  /// jitter 􏰙􏱁􏱂抖动缓冲接收到的数据
  final int googJitterReceived;

  /// 第一个关键帧是否正常收到
  // final int googFirsReceived; // iOS没有暂时去掉

  /// 接收卡顿延时
  final int googRenderDelayMs;

  /// 接收的音频流音量大小
  final String audioOutputLevel;

  /// 编码方式
  final String codecImplementationName;

  /// nack 数量
  final String googNacksReceived;

  /// (Picture Loss Indication) 􏰶􏰷􏱫􏰙 PLI请求
  // final String googPlisReceived; // iOS没有暂时去掉

  StatusBean.fromJson(Map<String, dynamic> map)
      : this.rtt = "${map['rtt']}",
        this.id = map['id'],
        this.audioOutputLevel = map.containsKey('audioOutputLevel')
            ? '${map['audioOutputLevel']}'
            : map.containsKey('audioLevel')
                ? '${map['audioLevel']}'
                : '0',
        this.bitRate = "${map['bitRate']}",
        this.codecImplementationName = map['codecImplementationName'],
        this.codecName = map['codecName'],
        this.frameHeight = map['frameHeight'],
        this.frameRate = map['frameRate'],
        this.frameWidth = map['frameWidth'],
        // this.isSend = map['isSend'],
        // this.googFirsReceived = map['googFirsReceived'],
        // this.googPlisReceived = map['googPlisReceived'],
        this.googJitterReceived = map['googJitterReceived'],
        this.googNacksReceived = "${map['googNacksReceived']}",
        this.googRenderDelayMs = map['googRenderDelayMs'],
        this.uid = map['uid'],
        this.mediaType = map['mediaType'],
        this.packetLostRate = "${map['packetLostRate']}";
}

abstract class IRCRTCStatusReportListener {
  /// 状态信息的输出，每秒输出一次。
  /// [statusReport]
  onConnectionStats(StatusReport statusReport);
}
