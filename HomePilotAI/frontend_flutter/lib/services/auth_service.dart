import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_response.dart';
import 'api_client.dart';
import 'demo_fallbacks.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final json = await _apiClient.postObject(
        '/auth/login',
        body: {'email': normalizedEmail, 'password': password},
      );
      return AuthResponse.fromJson(json);
    } on ApiConnectivityException {
      if (DemoFallbacks.matchesDemoCredentials(
        email: normalizedEmail,
        password: password,
      )) {
        return DemoFallbacks.authResponse();
      }
      throw Exception(
        'HomePilot AI could not reach the backend. Use demo@homepilot.ai / HomePilot123! for offline demo mode, or start the API at ${_apiClient.baseUrl}.',
      );
    }
  }

  Future<AuthResponse> loginWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in was cancelled');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Google did not return an ID token');

    try {
      final json = await _apiClient.postObject(
        '/auth/google',
        body: {'idToken': idToken},
      );
      return AuthResponse.fromJson(json);
    } on ApiConnectivityException {
      throw Exception(
        'Google sign-in requires the backend API. Start the API at ${_apiClient.baseUrl}, or use the demo account.',
      );
    }
  }

  Future<AuthResponse> signup({
    required String email,
    required String password,
  }) async {
    try {
      final json = await _apiClient.postObject(
        '/auth/signup',
        body: {'email': email.trim().toLowerCase(), 'password': password},
      );
      return AuthResponse.fromJson(json);
    } on ApiConnectivityException {
      throw Exception(
        'Sign up requires the backend API. Start the API at ${_apiClient.baseUrl}, or use the demo account from the login screen.',
      );
    }
  }
}
