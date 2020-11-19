enum MixLayoutMode {
  CUSTOM,
  SUSPENSION,
  ADAPTIVE,
}

enum VideoRenderMode {
  CROP,
  WHOLE,
}

class CustomLayoutList {
  List<CustomLayout> customLayout;

  CustomLayoutList(this.customLayout);

  Map<String, dynamic> toJson() => {
        'video': customLayout.map((e) => e.toJson()).toList(),
      };
}

class MediaConfig {
  AudioConfig audioConfig;
  List<CDNPushUrl> cdn;
  VideoConfig videoConfig;

  Map<String, dynamic> toJson() => {
        'video': videoConfig != null ? videoConfig.toJson() : null,
        'audio': audioConfig != null ? audioConfig.toJson() : null,
        'cdn': cdn != null ? cdn.map((e) => e.toJson()).toList() : null,
      };
}

class AudioConfig {
  int bitrate;

  Map<String, dynamic> toJson() => {
        'bitrate': bitrate,
      };
}

class CDNPushUrl {
  String pushUrl;

  Map<String, dynamic> toJson() => {
        'pushurl': pushUrl,
      };
}

class VideoConfig {
  VideoExtend extend;
  VideoLayout tinyVideoLayout;
  VideoLayout videoLayout;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataJson = new Map();
    dataJson['normal'] = videoLayout != null ? videoLayout.toJson() : null;
    dataJson['tiny'] = tinyVideoLayout != null ? tinyVideoLayout.toJson() : null;
    dataJson['exparams'] = extend != null ? extend.toJson() : null;
    return dataJson;
  }
}

class VideoLayout {
  int bitrate;
  int height;
  int width;
  int fps;

  Map<String, dynamic> toJson() => {
        'bitrate': bitrate,
        'height': height,
        'width': width,
        'fps': fps,
      };
}

class VideoExtend {
  VideoRenderMode renderMode;

  Map<String, dynamic> toJson() => {
        'renderMode': renderMode.index + 1,
      };
}

class CustomLayout {
  String userId;
  String streamId;
  int x;
  int y;
  int width;
  int height;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'stream_id': streamId,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}

class RCRTCMixConfig {
  int version = 1;
  MixLayoutMode mode;

  String hostUserId;
  String hostStreamId;

  MediaConfig mediaConfig;
  CustomLayoutList customLayoutList;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataJson = new Map();
    dataJson['version'] = version;
    dataJson['mode'] = mode.index + 1;
    dataJson['host_user_id'] = hostUserId;
    dataJson['host_stream_id'] = hostStreamId;
    dataJson['output'] = mediaConfig != null ? mediaConfig.toJson() : null;
    dataJson['input'] = customLayoutList != null ? customLayoutList.toJson() : null;
    return dataJson;
  }
}
