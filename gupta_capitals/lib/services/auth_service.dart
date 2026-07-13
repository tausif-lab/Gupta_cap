import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _roleKey = 'user_role';

  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  String? _token;
  String? _userId;
  String? _userName;
  String? _role;

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get role => _role;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _role == 'admin';

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    _userName = prefs.getString(_userNameKey);
    _role = prefs.getString(_roleKey);
  }

  Future<void> saveSession({
    required String token,
    String? userId,
    String? userName,
    String? role,
  }) async {
    _token = token;
    _userId = userId;
    _userName = userName;
    _role = role;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (userId != null) await prefs.setString(_userIdKey, userId);
    if (userName != null) await prefs.setString(_userNameKey, userName);
    if (role != null) await prefs.setString(_roleKey, role);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_roleKey);
  }

  Future<http.Response> get(String path, {Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = {...headers, ...?extraHeaders};
    return http.get(uri, headers: allHeaders).timeout(const Duration(seconds: 8));
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body, Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = {...headers, ...?extraHeaders};
    return http.post(uri, headers: allHeaders, body: body != null ? jsonEncode(body) : null)
        .timeout(const Duration(seconds: 8));
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body, Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = {...headers, ...?extraHeaders};
    return http.put(uri, headers: allHeaders, body: body != null ? jsonEncode(body) : null)
        .timeout(const Duration(seconds: 8));
  }
}
