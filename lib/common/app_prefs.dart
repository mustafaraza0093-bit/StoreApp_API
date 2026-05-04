import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app_api/modules/auth/models/user_model.dart';

class AppPrefs {
  static const String _accessToken = 'accessToken';
  static const String _refreshToken = 'refresh_token';
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _user = 'user';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setAccessToken(String value) async {
    await _prefs?.setString(_accessToken, value);
  }

  static String getAccessToken() {
    return _prefs?.getString(_accessToken) ?? '';
  }

  static Future<void> setRefreshToken(String value) async {
    await _prefs?.setString(_refreshToken, value);
  }

  static String getRefreshToken() {
    return _prefs?.getString(_refreshToken) ?? '';
  }

  static Future<void> setUser(UserModel user) async {
    await _prefs?.setString(_user, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final raw = _prefs?.getString(_user);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return UserModel.fromJson(map);
      }
      return UserModel.fromJson(Map<String, dynamic>.from(map as Map));
    } catch (_) {
      return null;
    }
  }

  static Future<void> setFirstTime(bool value) async {
    await _prefs?.setBool(_keyIsFirstTime, value);
  }

  static bool isFirstTime() {
    return _prefs?.getBool(_keyIsFirstTime) ?? true;
  }

  static Future<void> clear() async {
    await _prefs?.remove(_accessToken);
    await _prefs?.remove(_refreshToken);
    await _prefs?.remove(_user);
  }
}
