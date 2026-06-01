import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../presentation/auth_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}


class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _usernameController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose(){
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _usernameController.text.trim();
    if (name.isEmpty || name.length < 3) {
      setState(
        () => _errorMessage = 'Username must be at least 3 characters long.',
      );
      return;
    }

    setState(() => _errorMessage = null);

    await ref.read(authStateProvider.notifier).completeOnboarding(name);

    final authState = ref.read(authStateProvider);
    if (authState.hasError) {
      setState(() {
        _errorMessage = authState.error.toString().replaceAll(
          'Exception: ',
          '',
        );
      });
    } else {
      // Success! GoRouter dynamically routes the user to /plan dashboard
      if (mounted) context.go('/plan');
    }
  }

  @override
  Widget build(BuildContext context){
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // -------------------------------------------------------------------
          // THE OPTIONAL SKIP BUTTON WORKSPACE
          // -------------------------------------------------------------------
          TextButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).skipOnboarding();
              context.go('/plan'); // Unlock entry straight to meal tracking slots
            },
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Welcome to AaharUp!',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 32,
                  color: AppColors.tealPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Let\'s quickly set up your cooking profile identity.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                'Choose a Username',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              TextField(
                controller: _usernameController,
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'e.g., Rahul_Cooks',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w200,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.alternate_email,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: isLoading ? null : _handleSubmit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Let\'s Start Planning',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          )
        )
      )
    );
  }
}
