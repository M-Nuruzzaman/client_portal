import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseSettings {
  SharedPreferences? _prefs;

  Future<void> initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveSetting(String key, bool value) async {
    await initPrefs();
    await _prefs!.setBool(key, value);
  }

  bool getSetting(String key, {bool defaultValue = false}) {
    if (_prefs == null) {
      throw Exception("SharedPreferences not initialized. Call initPrefs() first.");
    }
    return _prefs!.getBool(key) ?? defaultValue;
  }
}
