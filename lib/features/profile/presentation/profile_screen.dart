import 'package:aaharup_app/features/profile/presentation/profile_provider.dart';
import 'package:aaharup_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/data/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

    bool _isLoading = false;
   String? _errorMessage;

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {


     try {
      await ref
          .read(authStateProvider.notifier)
          .logout();

    } catch (e) {
     setState(() {
        _errorMessage = "Failed to sign out cleanly. Please try again.";
        _isLoading = false;
      });
    }
    finally {
      if (mounted) {
        AppRestartWrapper.restartApp(context);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Summary'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),

              userProfileAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    // 'Failed to load profile parameters',
                    err.toString(),
                    style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                  ),
                ),
                data: (user) {
                  // Determine display username, fallback elegantly if skipped onboarding
                  final displayUsername =
                      (user.username != null && user.username!.isNotEmpty)
                      ? user.username!
                      : 'AaharUp Chef';

                  // Prioritize phone number for Indian audience context, fallback to email
                  final displayIdentifier =
                      user.phoneNumber ?? user.email ?? 'No contact linked';

                  return Column(
                    children: [
                      // User Avatar Graphic Placeholder Frame
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.tealLight,
                        child: const Icon(
                          Icons.person,
                          size: 54,
                          color: AppColors.tealPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Dynamic Account Status Text Labels
                      Text(
                        displayUsername,
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        displayIdentifier,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Explicit placeholder warning badge if they skipped onboarding username profile registration
                      if (user.username!.isEmpty) ...[
                        const SizedBox(height: 12),
                        ActionChip(
                          backgroundColor: Colors.orange.shade50,
                          side: BorderSide(color: Colors.orange.shade200),
                          label: const Text(
                            'Complete Profile Setup',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            context.go(
                              '/onboarding',
                            ); // Let them claim their username easily
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

              const Spacer(), // Pushes the logout button cleanly to the bottom

              // Premium High-Contrast Logout Button Card Panel

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: _isLoading ? Colors.grey.shade100 : Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: _isLoading ? Colors.grey.shade200 : Colors.red.shade100),
                  ),
                ),
                onPressed: _isLoading ? null : () => _showLogoutConfirmation(context,ref),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  // Native dynamic system warning confirmation dialog box builder modal
  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out? Your local offline meal plan cache will remain saved.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog alert menu
              _handleLogout(context, ref); // Fire authentication termination logic sequential chain
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
