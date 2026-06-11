import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../domain/ai_suggestion_model.dart';

class AiSearchRepository {
  final ApiClient _apiClient;

  AiSearchRepository(this._apiClient);

  Future<AiSearchResponse> queryAiSuggestions(
    String userMessage,
    String sessionId,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai/search',
        data: {
          'message': userMessage,
          'session_id': sessionId, // ✅ Sent confidently as a strict string every single time!
          'user_preferences': null,
          'filters': null
        },
      );
      // print(response);
      return AiSearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'AI Engine failed processing request',
      );
    }
  }

  Future<void> clearAiSession(String sessionId) async {
    try {
      await _apiClient.dio.delete('/ai/search/session/$sessionId');
    } catch (e) {
      // Fail silently for background session cleanups
    }
  }
}
