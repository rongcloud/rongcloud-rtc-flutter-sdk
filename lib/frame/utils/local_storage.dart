import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences _config;

  static Future init() async {
    if (_config == null){
      _config = await SharedPreferences.getInstance();
    }
  }

  static bool containsKey(String key) => _config.containsKey(key);

  static dynamic get(String key) => _config.get(key);

  static bool getBool(String key) => _config.getBool(key);

  static int getInt(String key) => _config.getInt(key);

  static double getDouble(String key) => _config.getDouble(key);

  static String getString(String key) => _config.getString(key);

  static List<String> getStringList(String key) => _config.getStringList(key);

  static Future<bool> setBool(String key, bool value) => _config.setBool(key, value);

  static Future<bool> setInt(String key, int value) => _config.setInt(key, value);

  static Future<bool> setDouble(String key, double value) => _config.setDouble(key, value);

  static Future<bool> setString(String key, String value) => _config.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) => _config.setStringList(key, value);
}
