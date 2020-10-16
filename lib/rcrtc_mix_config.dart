enum MixLayoutMode { ADAPTIVE, CUSTOM, SUSPENSION }

enum VideoRenderMode { CROPO, WHOLE }

class CustomLayoutList {
  List<CustomLayout> customLayout;

  Map<String, dynamic> toJson() => {
        'customLayout': customLayout,
      };
}

class MediaConfig {
  AudioConfig audioConfig;
  List<CDNPushUrl> cdn;
  VideoConfig videoConfig;

  Map<String, dynamic> toJson() => {'audioConfig': audioConfig, 'cdn': cdn, 'videoConfig': videoConfig};
}

class AudioConfig {
  int bitrate;

  Map<String, dynamic> toJson() => {'bitrate': bitrate};
}

class CDNPushUrl {
  String pushUrl;

  Map<String, dynamic> toJson() => {'pushUrl': pushUrl};
}

class VideoConfig {
  VideoExtend extend;
  VideoLayout tinyVideoLayout;
  VideoLayout videoLayout;

  Map<String, dynamic> toJson() => {
        'extend': extend.toJson(),
        'tinyVideoLayout': tinyVideoLayout,
        'videoLayout': videoLayout,
      };
}

class VideoLayout {
  int bitrate;
  int height;
  int width;
  int fps;

  Map<String, dynamic> toJson() => {'bitrate': bitrate, 'height': height, 'width': width, 'fps': fps};
}

class VideoExtend {
  int renderMode;

  Map<String, dynamic> toJson() => {'renderMode': renderMode};
}

class CustomLayout {
  String userId;
  String streamId; //todo json stream_id
  int x;
  int y;
  int width;
  int height;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'streamId': streamId,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}

class RCRTCMixConfig {
  int version = 1;
  int mode;

  String hostUserId;
  String hostStreamId;

  MediaConfig mediaConfig;
  CustomLayoutList customLayoutList;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'mode': mode,
      'hostUserId': hostUserId,
      'host_stream_id': hostStreamId,
      'mediaConfig': mediaConfig,
      'customLayoutList': customLayoutList
    };
  }
}
