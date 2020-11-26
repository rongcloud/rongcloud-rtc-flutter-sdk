enum MessageType {
  normal,
  request_list,
  invite,
  kick,
  error,
}

enum MessageError {
  no_permission,
  unsubscribe_error,
  join_error,
}

enum Status {
  ok,
  error,
}

enum PermissionStatus {
  granted,
  camera_denied,
  mic_denied,
  both_denied,
  unknown,
}

enum ConfigMode {
  Meeting,
  Live,
  Audio,
}

const List<String> ConfigModeString = [
  "会议",
  "直播",
  "通话",
];

const List<String> CameraCaptureOrientationStrings = [
  "Portrait",
  "PortraitUpsideDown",
  "LandscapeRight",
  "LandscapeLeft",
];

const List<String> Resolutions = [
  "144x176",
  "144x256",
  "180x320",
  "240x240",
  "240x320",
  "360x480",
  "360x640",
  "480x480",
  "480x640",
  "480x720",
  "720x1280",
];
