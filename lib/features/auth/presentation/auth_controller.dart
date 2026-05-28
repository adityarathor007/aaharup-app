import 'package:aaharup_app/core/network/token_manager.dart';
import 'package:aaharup_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repo;
  final TokenManager _tokenManager = TokenManager();

  AuthController(this._repo) : super(const AsyncLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await _tokenManager.getAccessToken();

    state = AsyncData(token != null);
  }

  Future<void> login(String email, String password) async {
    await _repo.login(email, password);

    state = const AsyncData(true);
  }

  Future<void> logout() async {
    await _repo.logout();

    state = const AsyncData(false);
  }
}
