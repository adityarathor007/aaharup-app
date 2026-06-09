// Application's delivery vehicle to the outside world
// If a 401 error fires, it locks the queue, updates tokens via a dedicated internal Dio client (to prevent infinite loops),
// and replays the original call.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'token_manager.dart';

class ApiClient {
  late final Dio dio;
  final TokenManager _tokenManager = TokenManager();

  // Point this to your local FastAPI server setup
  // Use http://10.0.2.2:8000 for standard Android Emulators, or localhost for iOS Simulators
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String baseUrl = 'http://192.168.1.20:8000/api/v1';

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenManager.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Check if failure is a 401 unauthorized issue
          if (error.response?.statusCode == 401) {
            // final refreshToken = await _tokenManager.getRefreshToken();
            if (error.requestOptions.path.contains('/auth/refresh')) {
              await _tokenManager.clearTokens();
              return handler.next(error);
            }

            final refreshToken = await _tokenManager.getRefreshToken();

            if (refreshToken != null) {
              try {
                debugPrint(
                  "🔄 Core 401 intercepted. Attempting background token rotation...",
                );
                // Request a fresh pair of tokens using a clean isolated Dio instance
                final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
                final response = await refreshDio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccess = response.data['access_token'];
                  final newRefresh = response.data['refresh_token'];

                  debugPrint(
                    "✅ Token rotation successful. Replaying stale request queue...",
                  );

                  await _tokenManager.saveTokens(newAccess, newRefresh);

                  // Update the original request header with the new token
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newAccess';

                  // Clone and replay the original request back into the system pipeline
                  final clonedResponse = await dio.fetch(error.requestOptions);
                  return handler.resolve(clonedResponse);
                }
              } catch (e) {
                debugPrint(
                  "❌ Refresh token rotation failed entirely: $e. Evicting user session.",
                );
                // Refresh token itself expired; wipe token registers so app boot state triggers login routing
                await _tokenManager.clearTokens();

              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
