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
    // // 1. Wipe security credentials completely off the local disk parameters
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('access_token');
    // await prefs.remove('refresh_token');

    // // 2. Flip authorization tracking state trees to false
    // // This immediately alerts GoRouter's redirect guard!
    // ref.read(authStateProvider.notifier).state = false;

    // // 3. Force route navigation straight back to the login page view
    // if (context.mounted) {
    //   context.go('/login');
    // }


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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Account Status Text Labels
              Text(
                'AaharUp Member',
                style: AppTextStyles.h1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Account verified successfully',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
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
