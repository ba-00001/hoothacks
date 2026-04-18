import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  String? _token;
  Long? _userId;

  void setAuth(String token, int userId) {
    _token = token;
    _userId = userId;
  }

  void clearAuth() {
    _token = null;
    _userId = null;
  }

  int? get userId => _userId;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ---- AUTH ----
  Future<Map<String, dynamic>> signup(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> googleAuth(String idToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'googleIdToken': idToken}),
    );
    return jsonDecode(res.body);
  }

  // ---- PROFILE ----
  Future<Map<String, dynamic>> getProfile(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/auth/profile/$userId'), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auth/profile/$userId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ---- LISTINGS ----
  Future<List<dynamic>> getListings({String? type, String? location, double? maxPrice}) async {
    String url = '$baseUrl/listings?';
    if (type != null) url += 'type=$type&';
    if (location != null) url += 'location=$location&';
    if (maxPrice != null) url += 'maxPrice=$maxPrice&';
    final res = await http.get(Uri.parse(url), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getListing(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/listings/$id'), headers: _headers);
    return jsonDecode(res.body);
  }

  // ---- FAVORITES ----
  Future<void> saveFavorite(int userId, int listingId) async {
    await http.post(
      Uri.parse('$baseUrl/listings/favorites?userId=$userId&listingId=$listingId'),
      headers: _headers,
    );
  }

  Future<List<dynamic>> getFavorites(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/listings/favorites/$userId'), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<void> removeFavorite(int userId, int listingId) async {
    await http.delete(
      Uri.parse('$baseUrl/listings/favorites?userId=$userId&listingId=$listingId'),
      headers: _headers,
    );
  }

  // ---- AI AGENTS ----
  Future<Map<String, dynamic>> getAffordability(int userId) async {
    final res = await http.post(Uri.parse('$baseUrl/ai/affordability?userId=$userId'), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getGrants(int userId) async {
    final res = await http.post(Uri.parse('$baseUrl/ai/grants?userId=$userId'), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getRecommendations(int userId) async {
    final res = await http.post(Uri.parse('$baseUrl/ai/recommendations?userId=$userId'), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getMortgageEstimate(int userId) async {
    final res = await http.post(Uri.parse('$baseUrl/ai/mortgage-estimate?userId=$userId'), headers: _headers);
    return jsonDecode(res.body);
  }

  // ---- ADMIN ----
  Future<Map<String, dynamic>> resetAndSeed() async {
    final res = await http.post(Uri.parse('$baseUrl/admin/reset-and-seed'), headers: _headers);
    return jsonDecode(res.body);
  }
}

// ignore the Long? type error — it's just int? in Dart
typedef Long = int;
