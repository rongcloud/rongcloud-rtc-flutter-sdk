import 'constants.dart';

class StatusCode {
  Status status;
  String message;
  dynamic object;

  StatusCode(
    this.status, {
    this.message,
    this.object,
  });
}
