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
  final double bitRateSend;

  /// 接收码率大小，单位是 kbps
  final double bitRateRcv;

  /// 往返延时(ms)
  final int rtt;
//
//  /// 临时存储发送的总数,单位是kb
//  final double bitRateTotalSend;
//
//  /// 临时存储收到的总数,单位是kb
//  final double bitRateTotalRcv;

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
      : this.bitRateRcv = map['bitRateRcv'],
        this.bitRateSend = map['bitRateSend'],
        this.googAvailableReceiveBandwidth = map['googAvailableReceiveBandwidth'],
        this.googAvailableSendBandwidth = map['googAvailableReceiveBandwidth'],
        this.ipAddress = map['ipAddress'],
        this.networkType = map['networkType'],
        this.packetsDiscardedOnSend = map['packetsDiscardedOnSend'],
        this.rtt = map['rtt'] {
    Map<String, dynamic> jsonAudioRcvs = map['statusAudioRcvs'];
    jsonAudioRcvs.forEach((key, value) {
      this.statusAudioRcvs.putIfAbsent(key, () => StatusBean.fromJson(value));
    });

    Map<String, dynamic> jsonAudioSends = map['statusAudioSends'];
    jsonAudioSends.forEach((key, value) {
      this.statusAudioSends.putIfAbsent(key, () => StatusBean.fromJson(value));
    });
    Map<String, dynamic> jsonVideoRcvs = map['statusVideoRcvs'];
    jsonAudioRcvs.forEach((key, value) {
      this.statusVideoRcvs.putIfAbsent(key, () => StatusBean.fromJson(value));
    });
    Map<String, dynamic> jsonVideoSends = map['statusVideoSends'];
    jsonAudioRcvs.forEach((key, value) {
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
  final int packetLostRate;

  /// 发送类型，true为发送
  final int isSend;

  /// 接收/发送的包
  final int packets;

  /// 丢包数量
  final int packetsLost;

  /// 视频高
  final int frameHeight;

  /// 视频宽
  final int frameWidth;

  /// 视频帧率 FPS
  final int frameRate;

  /// 码率大小，单位是 kbps
  final int bitRate;

  /// 接收/发送的字节总数.单位是kb
  final int totalBitRate;

  /// 往返延时(ms)
  final int rtt;

  /// jitter 􏰙􏱁􏱂抖动缓冲接收到的数据
  final int googJitterReceived;

  /// 第一个关键帧是否正常收到
  final int googFirsReceived;

  /// 接收卡顿延时
  final int googRenderDelayMs;

  /// 接收的音频流音量大小
  final String audioOutputLevel;

  /// 编码方式
  final String codecImplementationName;

  /// nack 数量
  final String googNacksReceived;

  /// (Picture Loss Indication) 􏰶􏰷􏱫􏰙 PLI请求
  final String googPlisReceived;
  StatusBean.fromJson(Map<String, dynamic> map)
      : this.rtt = map['rtt'],
        this.id = map['id'],
        this.audioOutputLevel = map['audioOutputLevel'],
        this.bitRate = map['bitRate'],
        this.codecImplementationName = map['codecImplementationName'],
        this.codecName = map['codecName'],
        this.frameHeight = map['frameHeight'],
        this.frameRate = map['frameRate'],
        this.frameWidth = map['frameWidth'],
        this.googFirsReceived = map['googFirsReceived'],
        this.googJitterReceived = map['googJitterReceived'],
        this.googNacksReceived = map['googNacksReceived'],
        this.googPlisReceived = map['googPlisReceived'],
        this.googRenderDelayMs = map['googRenderDelayMs'],
        this.uid = map['uid'],
        this.mediaType = map['mediaType'],
        this.packetLostRate = map['packetLostRate'],
        this.isSend = map['isSend'],
        this.packets = map['packets'],
        this.packetsLost = map['packetsLost'],
        this.totalBitRate = map['totalBitRate'];
}

abstract class IRCRTCStatusReportListener {
  /// 以HashMap形式返回参与者的userID和[audioLevel]，每秒钟刷新一次。
  /// 当 AudioLevel 大于 0 时候，即认为该参与者正在讲话。
  onAudioReceivedLevel(Map<String, String> audioLevel);

  /// 输入端的音频输入等级
  /// [audioLevel] 返回输入端audio level
  onAudioInputLevel(String audioLevel);

  /// 状态信息的输出，每秒输出一次。
  /// [statusReport]
  onConnectionStats(StatusReport statusReport);
}
