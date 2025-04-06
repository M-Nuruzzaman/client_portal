import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Save user data
  static Future<void> saveUserData(String email, String mobileNumber) async {
    await _preferences?.setString('email', email);
    await _preferences?.setString('mobileNumber', mobileNumber);
  }

  /// Retrieve email
  static String? getEmail() {
    return _preferences?.getString('email');
  }

  /// Retrieve mobile number
  static String? getMobileNumber() {
    return _preferences?.getString('mobileNumber');
  }

  /// Clear user data (e.g., on logout)
  static Future<void> clearUserData() async {
    await _preferences?.remove('email');
    await _preferences?.remove('mobileNumber');
  }
}
