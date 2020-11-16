enum LiveType {
  normal,
  single,
  group,
}

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

enum ChatType {
  VideoChat,
  LiveChat,
  AudioChat,
}
