import 'package:shared_preferences/shared_preferences.dart';

class FcmTokenManager {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save FCM Token to SharedPreferences
  static Future<void> saveFcmToken(String token) async {
    await _prefs?.setString('fcm_token', token);
  }

  // Get FCM Token from SharedPreferences
  static String? getFcmToken() {
    return _prefs?.getString('fcm_token');
  }
}
