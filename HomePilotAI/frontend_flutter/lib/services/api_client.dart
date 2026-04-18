import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_session.dart';

class ApiClient {
  ApiClient(this.session);

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  final AppSession session;

  Future<Map<String, dynamic>> getObject(String path) async {
    final response = await http.get(_uri(path), headers: _headers());
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await http.get(_uri(path, query), headers: _headers());
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postObject(String path, {Object? body}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> putObject(
    String path, {
    required Object body,
  }) async {
    final response = await http.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
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
      throw Exception(
        message ?? 'Request failed with status ${response.statusCode}',
      );
    }

    return decoded;
  }
}
