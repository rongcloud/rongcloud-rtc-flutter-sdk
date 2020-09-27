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
