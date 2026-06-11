// concrete data class implementing that interface, translating data payloads directly into your ApiClient network executions.

import 'package:aaharup_app/features/auth/domain/auth_response.dart';
import 'package:aaharup_app/features/profile/presentation/profile_provider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_manager.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager = TokenManager();

  AuthRepositoryImpl(this._apiClient);

  // @override
  // Future<void> register(String email, String password) async {
  //   try {
  //     await _apiClient.dio.post(
  //       '/auth/register',
  //       data: {'email': email, 'password': password},
  //     );
  //   } on DioException catch (e) {
  //     final errorMessage = e.response?.data['detail'] ?? 'Registration failed';
  //     throw Exception(errorMessage);
  //   }
  // }

  // @override
  // Future<void> login(String email, String password) async {
  //   try {
  //     final response = await _apiClient.dio.post(
  //       '/auth/login',
  //       data: {'email': email, 'password': password},
  //     );

  //     final accessToken = response.data['access_token'];
  //     final refreshToken = response.data['refresh_token'];

  //     // Save credentials straight into our local persistent shared preference storage
  //     await _tokenManager.saveTokens(accessToken, refreshToken);
  //   } on DioException catch (e) {
  //     final errorMessage = e.response?.data['detail'] ?? 'Login failed';
  //     throw Exception(errorMessage);
  //   }
  // }

    @override
    Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
        // 1. Post to your updated single universal FastAPI endpoint
        final response = await _apiClient.dio.post(
        '/auth/verify',
        data: {'phone_number': phoneNumber},
        );

        // 2. Wrap the JSON payload data into our clean model instance
        final authResponse = AuthResponse.fromJson(response.data);

        debugPrint("current user's phone number: ${authResponse.phoneNumber}");
        debugPrint("Token saved");

        // 3. Save credentials straight into your persistent storage engine
        await _tokenManager.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
        );

        return authResponse.isOnboarded;
    } on DioException catch (e) {
        final errorMessage =
            e.response?.data['detail'] ?? 'Authentication failed';
        throw Exception(errorMessage);
    }
    }

    @override
    Future<void> submitOnboardingUsername(String username) async {
    try{
        await _apiClient.dio.post(
        '/auth/onboard',
        data: {'username': username},
        );
    } on DioException catch (e) {
        final errorMessage = e.response?.data['detail'] ?? 'Onboarding failed';
        throw Exception(errorMessage);
    }
    }

    @override
    Future<bool> signInWithGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    try{
        final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            // accessToken: googleAuth.accessToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(
            credential,
        );

        final firebaseToken = await userCredential.user!.getIdToken();

        final response = await _apiClient.dio.post(
            '/auth/google',
            data: {'id_token': firebaseToken},
        );

        final authResponse = AuthResponse.fromJson(response.data);

        // 3. Save credentials straight into your persistent storage engine
        await _tokenManager.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        return response.data['is_onboarded'];
    }
    on FirebaseAuthException catch (e) {
        debugPrint(e.message);
        return false;
    } catch (e) {
        debugPrint(e.toString());
        return false;
    }

    }

  @override
  Future<void> logout(Ref ref) async {
    await _tokenManager.clearTokens();
  }
}
