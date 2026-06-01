import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile_model.dart';
import '../../auth/data/auth_providers.dart'; // Adjust path based on your structure

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  final response = await apiClient.dio.get('/auth/me');
  return UserProfile.fromJson(response.data);
});
