import 'package:aaharup_app/core/network/token_manager.dart';
import 'package:aaharup_app/features/auth/domain/auth_repository.dart';
import 'package:aaharup_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repo;
  final Ref ref;
  final TokenManager _tokenManager = TokenManager();

  AuthController(this.ref,this._repo) : super(const AsyncLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await _tokenManager.getAccessToken();
    state = AsyncData(token != null);
  }

  // Future<void> login(String email, String password) async {
  //   await _repo.login(email, password);

  //   state = const AsyncData(true);
  // }

  Future<void> continueWithPhone(String rawNumber) async {
    state = const AsyncLoading();

    // Normalize string to match Indian standard requirements cleanly
    final fullNumberString = '+91${rawNumber.trim()}';

    state = await AsyncValue.guard(() async {
      // 1. Fire network request via repository layer
      final isOnboarded = await _repo.verifyPhoneNumber(fullNumberString);

      ref.read(isOnboardedProvider.notifier).state = isOnboarded;

      // 3. Return true to confirm session is active
      return true;
    });
  }

  Future<void> continueWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final isOnboarded = await _repo.signInWithGoogle();

      ref.read(isOnboardedProvider.notifier).state = isOnboarded;

      return true;
    });
  }

  Future<void> completeOnboarding(String username) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 1. Submit the username modification payload to FastAPI backend
      await _repo.submitOnboardingUsername(username.trim());

      // 2. Persist the onboarded status locally in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_onboarded', true);

      // 3. Flip state provider to let GoRouter unlock application tabs
      ref.read(isOnboardedProvider.notifier).state = true;

      return true; // Keep session state active
    });
  }

  void skipOnboarding() async {
    // If skipped, we do NOT hit the backend. We just update local memory flags
    // so they can use the app. They can complete their profile username later.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);

    ref.read(isOnboardedProvider.notifier).state = true;
  }



  Future<void> logout() async {
    await _repo.logout(ref);
    state = const AsyncData(false);
  }
}
