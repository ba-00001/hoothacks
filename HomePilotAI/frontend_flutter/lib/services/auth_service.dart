import '../models/auth_response.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postObject(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(json);
  }

  Future<AuthResponse> signup({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postObject(
      '/auth/signup',
      body: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(json);
  }
}
