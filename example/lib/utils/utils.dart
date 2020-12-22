import 'dart:math';

class Utils {
  static String generateRoomId() {
    int current = _random.nextInt(1000000);
    return '$current'.padLeft(6, '0');
  }

  static Random _random = Random.secure();
}
