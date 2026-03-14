import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Tokenmanager {
  //key token
  static const _tokenKey = 'token';
  static String? _cachedToken;

  //key user
  static const _userKey = 'user';
  static Map<String, dynamic>? _cachedUser;

  //saved token
  static Future<void> savedToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  //get token
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  //delete token
  static Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  //cek token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }

  //saved user data
  static Future<void> savedUser(Map<String, dynamic> user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  //get user data
  static Future<Map<String, dynamic>?> getUser() async {
    if (_cachedUser != null) return _cachedUser;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return null;

    _cachedUser = Map<String, dynamic>.from(jsonDecode(jsonString));
    return _cachedUser;
  }

  //clear user data
  static Future<void> clearUser() async {
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
