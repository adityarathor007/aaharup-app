import 'package:aaharup_app/core/network/token_manager.dart';
import 'package:aaharup_app/features/auth/domain/auth_repository.dart';
import 'package:aaharup_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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



  Future<void> logout() async {
    await _repo.logout();

    state = const AsyncData(false);
  }
}
