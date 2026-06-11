import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthRepository {
  // Future<void> register(String email, String password);
  // Future<void> login(String email, String password);
  Future<bool> verifyPhoneNumber(String phoneNumber);
  Future<bool>signInWithGoogle();
  Future<void> submitOnboardingUsername(String username);
  Future<void> logout(Ref ref);
}
