enum MessageType {
  normal,
  join,
  left,
  invite,
  link,
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

enum Mode {
  Meeting,
  Live,
  Audio,
}

const List<String> ModeStrings = [
  "会议",
  "直播",
  "通话",
];

const List<String> OrientationStrings = [
  "竖向上",
  "竖向下",
  "横向右",
  "横向左",
];

const List<String> FPSStrings = [
  '10',
  '15',
  '25',
  '30',
];

enum Resolution {
  SD,
  HD,
  FHD,
}

const List<String> ResolutionStrings = [
  '标清',
  '高清',
  '超清',
];

const List<String> EffectStrings = [
  '反派大笑',
  '狗子叫声',
  '胜利号角',
];

const List<String> MusicStrings = [
  '我和我的祖国',
];
