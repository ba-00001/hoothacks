import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response.dart';
import '../models/user_profile.dart';

class AppSession extends ChangeNotifier {
  static const _tokenKey = 'homepilot_token';
  static const _userKey = 'homepilot_user';

  String? _token;
  UserProfile? _user;

  String? get token => _token;
  UserProfile? get user => _user;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final storedUser = prefs.getString(_userKey);
    _user = storedUser == null ? null : UserProfile.fromStorage(storedUser);
    notifyListeners();
  }

  Future<void> setSession(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    _token = response.token;
    _user = response.user;
    await prefs.setString(_tokenKey, response.token);
    await prefs.setString(_userKey, response.user.toStorage());
    notifyListeners();
  }

  Future<void> updateUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    _user = user;
    await prefs.setString(_userKey, user.toStorage());
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _token = null;
    _user = null;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
