// concrete data class implementing that interface, translating data payloads directly into your ApiClient network executions.

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_manager.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager = TokenManager();

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<void> register(String email, String password) async {
    try {
      await _apiClient.dio.post(
        '/auth/register',
        data: {'email': email, 'password': password},
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Registration failed';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      // Save credentials straight into our local persistent shared preference storage
      await _tokenManager.saveTokens(accessToken, refreshToken);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Login failed';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }
}
