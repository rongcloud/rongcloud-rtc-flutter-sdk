// 音频回声消除算法方案
enum RCRTCAECMode {
  AEC_MODE0, // 不使用回声消除
  AEC_MODE1, // 使用AECM
  AEC_MODE2, // 使用AEC
}

// 回声消除级别
enum RCRTCNSLevel {
  NS_LOW, // 低
  NS_MODERATE, // 中
  NS_HIGH, // 高
  NS_VERY_HIGH, // 非常高
}

// 噪声抑制算法方案
enum RCRTCNSMode {
  NS_MODE0, // 不采用降噪处理
  NS_MODE1, // 采用瞬间尖波抑制，不采用噪声抑制
  NS_MODE2, // 采用噪声抑制，不采用瞬间尖波抑制
  NS_MODE3, // 噪声抑制和瞬间建波抑制都会采用
}

// 音频模式
enum RCRTCAudioScenario {
  DEFAULT, // 默认
  MUSIC, // 音乐模式
}

class RCRTCAudioStreamConfig {
  int _type;
  bool enableAGCLimiter;
  int agcTargetDBOV;
  bool enableHighPassFilters;
  double preAmplifierLevel;
  bool enablePreAmplifier;
  bool enableAGCControl;
  bool enableEchoFilter;
  RCRTCAECMode echoCancel;
  RCRTCNSLevel noiseSuppressionLevel;
  RCRTCNSMode noiseSuppression;
  int agcCompression;

  RCRTCAudioStreamConfig.build()
      : _type = 0,
        agcCompression = 9,
        agcTargetDBOV = -3,
        enableHighPassFilters = true,
        noiseSuppression = RCRTCNSMode.NS_MODE0,
        noiseSuppressionLevel = RCRTCNSLevel.NS_MODERATE,
        echoCancel = RCRTCAECMode.AEC_MODE2,
        enableEchoFilter = false,
        enablePreAmplifier = false,
        preAmplifierLevel = 1.0,
        enableAGCControl = true,
        enableAGCLimiter = true;

  RCRTCAudioStreamConfig.buildDefaultMode()
      : _type = 1,
        agcCompression = 9,
        agcTargetDBOV = -3,
        enableHighPassFilters = true,
        noiseSuppression = RCRTCNSMode.NS_MODE0,
        noiseSuppressionLevel = RCRTCNSLevel.NS_MODERATE,
        echoCancel = RCRTCAECMode.AEC_MODE2,
        enableEchoFilter = false,
        enablePreAmplifier = false,
        preAmplifierLevel = 1.0,
        enableAGCControl = true,
        enableAGCLimiter = true;

  RCRTCAudioStreamConfig.buildMusicMode()
      : _type = 2,
        agcCompression = 9,
        agcTargetDBOV = -3,
        enableHighPassFilters = true,
        noiseSuppression = RCRTCNSMode.NS_MODE0,
        noiseSuppressionLevel = RCRTCNSLevel.NS_LOW,
        echoCancel = RCRTCAECMode.AEC_MODE0,
        enableEchoFilter = false,
        enablePreAmplifier = true,
        preAmplifierLevel = 1.0,
        enableAGCControl = false,
        enableAGCLimiter = true;

  RCRTCAudioStreamConfig.buildMusicChatRoomMode()
      : _type = 3,
        agcCompression = 0,
        agcTargetDBOV = 0,
        enableHighPassFilters = true,
        noiseSuppression = RCRTCNSMode.NS_MODE0,
        noiseSuppressionLevel = RCRTCNSLevel.NS_MODERATE,
        echoCancel = RCRTCAECMode.AEC_MODE2,
        enableEchoFilter = false,
        enablePreAmplifier = true,
        preAmplifierLevel = 1.0,
        enableAGCControl = true,
        enableAGCLimiter = true;

  Map<String, dynamic> toJSON() => {
        'type': _type,
        'agcCompression': agcCompression,
        'agcTargetDBOV': agcTargetDBOV,
        'enableHighPassFilters': enableHighPassFilters,
        'noiseSuppression': noiseSuppression.index,
        'noiseSuppressionLevel': noiseSuppressionLevel.index,
        'echoCancel': echoCancel.index,
        'enableEchoFilter': enableEchoFilter,
        'enablePreAmplifier': enablePreAmplifier,
        'preAmplifierLevel': preAmplifierLevel,
        'enableAGCControl': enableAGCControl,
        'enableAGCLimiter': enableAGCLimiter,
      };
}
