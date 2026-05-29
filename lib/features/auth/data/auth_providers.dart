// register providers
import 'package:aaharup_app/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../domain/auth_repository.dart';
import 'auth_repository_impl.dart';

// Create a single permanent instance of our ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Provide the AuthRepository implementation to the rest of the application ("Whenever any screen asks for an AuthRepository, silently hand them the AuthRepositoryImpl instead.")
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);

  // MOCK SETUP: Swap your app to this line for offline testingfinal isOnboardedProvider = StateProvider<bool>((ref) => false);

  // return MockAuthRepository();

  // We declare the return type as the abstract contract (AuthRepository)
  // But we return the concrete implementation containing the real code!
  return AuthRepositoryImpl(client);
});

// Tracks whether an active, unexpired access token sits in the local storage disk
final authStateProvider= StateNotifierProvider<AuthController, AsyncValue<bool>>((ref) {
  return AuthController(ref,ref.read(authRepositoryProvider));
});
