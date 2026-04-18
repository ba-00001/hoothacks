import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'app_session.dart';

class ApiRequestException implements Exception {
  const ApiRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiConnectivityException implements Exception {
  const ApiConnectivityException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this.session);

  static final String _baseUrl =
      const String.fromEnvironment('API_BASE_URL', defaultValue: '').isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : _defaultBaseUrl();

  final AppSession session;

  String get baseUrl => _baseUrl;

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8080';
      case TargetPlatform.fuchsia:
        return 'http://localhost:8080';
    }
  }

  Future<Map<String, dynamic>> getObject(String path) async {
    final response = await _send(
      () => http.get(_uri(path), headers: _headers()),
      path,
    );
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send(
      () => http.get(_uri(path, query), headers: _headers()),
      path,
    );
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postObject(String path, {Object? body}) async {
    final response = await _send(
      () => http.post(
        _uri(path),
        headers: _headers(),
        body: body == null ? null : jsonEncode(body),
      ),
      path,
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> putObject(
    String path, {
    required Object body,
  }) async {
    final response = await _send(
      () => http.put(_uri(path), headers: _headers(), body: jsonEncode(body)),
      path,
    );
    return _decodeObject(response);
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (session.token != null) 'Authorization': 'Bearer ${session.token}',
    };
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
    String path,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw ApiConnectivityException(
        'HomePilot AI could not reach the backend at $_baseUrl$path in time.',
      );
    } on http.ClientException {
      throw ApiConnectivityException(
        'HomePilot AI could not reach the backend at $_baseUrl.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final dynamic decoded = _decode(response);
    return decoded as Map<String, dynamic>;
  }

  List<dynamic> _decodeList(http.Response response) {
    final dynamic decoded = _decode(response);
    return decoded as List<dynamic>;
  }

  dynamic _decode(http.Response response) {
    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      throw ApiRequestException(
        message ?? 'Request failed with status ${response.statusCode}',
      );
    }

    return decoded;
  }
}
