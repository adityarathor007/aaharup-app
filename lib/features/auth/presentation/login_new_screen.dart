import 'package:aaharup_app/core/theme/app_text_styles.dart';
import 'package:aaharup_app/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginNewScreen extends ConsumerStatefulWidget {
  const LoginNewScreen({super.key});

  @override
  ConsumerState<LoginNewScreen> createState() => _LoginNewScreenState();
}

class _LoginNewScreenState extends ConsumerState<LoginNewScreen>{
  bool _isLoading = false;

  @override
  Widget build(BuildContext context){
    final double bannerHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
        children: [
            // -------------------------------------------------------------------
            // LAYER 1: BACKDROP IMAGE AND TEAL GRADIENT OVERLAY
            // -------------------------------------------------------------------
            Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(
                    40,
                ), // Smooth capsule curve at base boundary
                ),
                child: Stack(
                fit: StackFit.expand,
                children: [
                    // 🚨 PLACE YOUR BACKGROUND IMAGE HERE:
                    Image.asset(
                    'assets/images/image.png', // Path to your local image
                    fit: BoxFit.cover,
                    ),

                    // Sophisticated brand color overlay blending to make title text pop
                    Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                            const Color(
                            0xFF0D9488,
                            ).withValues(alpha: 0.75), // Deep brand teal tint
                            const Color(
                            0xFF14B8A6,
                            ).withValues(alpha: 0.85), // Vibrant mid teal tint
                        ],
                        ),
                    ),
                    ),
                ],
                ),
            ),
            ),

            // -------------------------------------------------------------------
            // LAYER 2: INTERACTIVE ACTION LAYER CONTENT
            // -------------------------------------------------------------------
            SafeArea(
            child: Column(
                children: [
                // Top Action Row (Skip Button placement matching your layout)
                Padding(
                    padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                    ),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        TextButton(
                        onPressed: () => context.go('/plan'),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            ),
                        ),
                        child: const Text(
                            'Skip',
                            style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                        ),
                    ],
                    ),
                ),

                // Absolute Header Title alignment space
                SizedBox(
                    height: bannerHeight * 0.5,
                    child: Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text(
                            'AaharUp',
                            style: AppTextStyles.h1.copyWith(
                            fontSize: 48,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                            width: 48,
                            height: 3,
                            decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(1.5),
                            ),
                        ),
                        ],
                    ),
                    ),
                ),

                const Spacer(), // Safely scales variance across long/short screen heights
                // Lower White Card workspace detailing slogans and social flows
                Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                        'Smarter meal planning\nwith ghar wali feeling',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            height: 1.3,
                            color: const Color(0xFF0F172A), // Premium Dark Slate
                        ),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionDivider('Log in or sign up'),
                        const SizedBox(height: 24),

                        // Email Sign-In Master Button
                        ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                            0xFF0D9488,
                            ), // Brand Teal
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                        ),
                        onPressed: () {
                            // Action space to navigate down into email/password forms
                        },
                        child: const Text(
                            'Continue with Email',
                            style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionDivider('OR LOGIN WITH'),
                        const SizedBox(height: 24),

                        // Circular Social Integrations Strip Row
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            _buildSocialIconButton(
                            'assets/icons/google.png',
                            () {},
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIconButton(
                            'assets/icons/apple.png',
                            () {},
                            isApple: true,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIconButton(null, () {}, isMore: true),
                        ],
                        ),
                        const SizedBox(height: 32),

                        // Clean Bottom Navigation Action Link Toggle
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                            ),
                            ),
                            GestureDetector(
                            onTap: () => context.go('/register'),
                            child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                color: Color(0xFF0D9488),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                ),
                            ),
                            ),
                        ],
                        ),
                    ],
                    ),
                ),
                ],
            ),
            ),
        ],
        ),
    );
    }

    // Visual layout helper to draw clean textual line dividers
    Widget _buildSectionDivider(String label) {
        return Row(
        children: [
            Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
                label.toUpperCase(),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        ],
        );
    }

    // Builder utility for the pill-shaped social button row elements
    Widget _buildSocialIconButton(String? assetPath, VoidCallback onTap, {bool isApple = false, bool isMore = false}) {
        return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 72,
            height: 52,
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Center(
            child: isMore
                ? const Icon(Icons.more_horiz, color: Colors.grey, size: 24)
                : isApple
                    ? const Icon(Icons.apple, color: Colors.black, size: 24)
                    : Image.asset(assetPath!, width: 22, height: 22), // Google/Custom assets mapping
            ),
        ),
        );
    }
}
