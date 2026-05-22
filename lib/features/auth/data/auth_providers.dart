// register providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../domain/auth_repository.dart';
import 'auth_repository_impl.dart';

// Create a single permanent instance of our ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Provide the AuthRepository implementation to the rest of the application ("Whenever any screen asks for an AuthRepository, silently hand them the AuthRepositoryImpl instead.")
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);

  // MOCK SETUP: Swap your app to this line for offline testing
  // return MockAuthRepository();

  // We declare the return type as the abstract contract (AuthRepository)
  // But we return the concrete implementation containing the real code!
  return AuthRepositoryImpl(client);  
});
