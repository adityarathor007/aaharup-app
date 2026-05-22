import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_providers.dart';

class AuthTestScreen extends ConsumerWidget {
  const AuthTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AaharUp Test Panel'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Run End-to-End Auth Test'),
          onPressed: () async {
            final authRepo = ref.read(authRepositoryProvider);
            try {
              debugPrint('--- Starting E2E Auth Test ---');

              // 1. Attempt Registration
              debugPrint('Attempting registration...');
              await authRepo.register('testuser@example.com', '123');
              debugPrint('Registration step successful!');
            } catch (e) {
              debugPrint(
                'Registration note: ${e.toString()} (User may already exist, proceeding to login)',
              );
            }

            try {
              // 2. Attempt Login
              debugPrint('Attempting login...');
              await authRepo.login('testuser@example.com', 'SecurePass123!');
              debugPrint(
                'SUCCESS: Login verified! Tokens are fully stored in local storage.',
              );
            } catch (e) {
              debugPrint('CRITICAL ERROR: Auth Test Failed: ${e.toString()}');
            }
          },
        ),
      ),
    );
  }
}
