import 'package:aaharup_app/core/theme/app_text_styles.dart';
import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:aaharup_app/features/auth/presentation/login_screen.dart';
import 'package:aaharup_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginNewScreen extends ConsumerStatefulWidget {
  const LoginNewScreen({super.key});

  @override
  ConsumerState<LoginNewScreen> createState() => _LoginNewScreenState();
}

class _LoginNewScreenState extends ConsumerState<LoginNewScreen>{
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

    Future<void> _handlePhoneAuth() async {
        final rawInput = _phoneController.text.trim();
        if (rawInput.isEmpty || rawInput.length < 10) {
            setState(() {
                _errorMessage = 'Please enter a valid 10-digit mobile number.';
            });
            return;
        }

        setState(() {
            _isLoading = true;
            _errorMessage = null;
        });

        try {
        // Prepend India country code cleanly before hitting the network stack
        final fullPhoneNumber = '+91$rawInput';

        // final apiClient = ref.read(apiClientProvider);
        // final response = await apiClient.dio.post('/auth/verify', data: {
        //     'phone_number': fullPhoneNumber,
        // });

        await ref
          .read(authStateProvider.notifier)
          .continueWithPhone(fullPhoneNumber);

        // if (mounted) {
        //     context.go('/plan');
        // }
        } catch (e) {
        setState(() {
            _errorMessage = 'Something went wrong. Please try again.';
        });
        } finally {
        if (mounted) {
            setState(() => _isLoading = false);
        }
        }
    }


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
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    child: Stack(
                    fit: StackFit.expand,
                    children: [
                        // PLACE YOUR BACKGROUND IMAGE HERE:
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
            child: CustomScrollView(
                slivers: [
                // Top Action Row (Skip Button placement matching your layout)
                // SliverToBoxAdapter(
                    // child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8,),
                    //     child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //         TextButton(
                    //         onPressed: () => context.go('/plan'),
                    //         style: TextButton.styleFrom(
                    //             backgroundColor: Colors.black.withValues(alpha: 0.3),
                    //             padding: const EdgeInsets.symmetric(
                    //             horizontal: 16,
                    //             vertical: 8,
                    //             ),
                    //             shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(20),
                    //             ),
                    //         ),
                    //         child: const Text(
                    //             'Skip',
                    //             style: TextStyle(
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.bold,
                    //             ),
                    //         ),
                    //         ),
                    //     ],
                    //     ),
                    // ),
                // ),

                // Absolute Header Title alignment space
                SliverToBoxAdapter(
                    child: SizedBox(
                        height: bannerHeight * 0.7,
                        child: Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Text(
                                'AaharUp',
                                style: AppTextStyles.h1.copyWith(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
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
                ),


                // Lower Interaction Input Panel (Matches image_f34507.jpg structural composition)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                        children: [

                        const SizedBox(height: 12),

                        Text(
                            'Smarter meal planning\nwith ghar wali feeling',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1.copyWith(
                            fontSize: 26,
                            height: 1.3,
                            color: const Color(0xFF0F172A),
                            ),
                        ),

                        const SizedBox(height: 24),
                        // Spacer(),

                        _buildSectionDivider('Log in or sign up'),
                        const SizedBox(height: 20),

                        if (_errorMessage != null) ...[
                            Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                        ],

                        // -----------------------------------------------------
                        // ZOMATO-INSPIRED INLINE MOBILE INPUT FORM ROW BLOCK
                        // -----------------------------------------------------
                        Row(
                            children: [
                            // Static Indian Flag Prefix Indicator Card Widget
                            Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                ),
                                child: Row(
                                children: [
                                    // High-fidelity emoji flag representation for India context mapping
                                    const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                                ],
                                ),
                            ),
                            const SizedBox(width: 12),

                            // Main Flex Phone Field input panel
                            Expanded(
                                child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                ),
                                child: Row(
                                    children: [
                                    const Padding(
                                        padding: EdgeInsets.only(left: 14.0, right: 8.0),
                                        child: Text(
                                        '+91',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                    ),
                                    Expanded(
                                        child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        decoration: const InputDecoration(
                                            hintText: 'Enter Mobile Number',
                                            hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(vertical: 2),
                                        ),
                                        ),
                                    ),
                                    ],
                                ),
                                ),
                            ),
                            ],
                        ),
                        const SizedBox(height: 24),

                        // Form Submission Trigger Button Element
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488), // Fresh Teal primary
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _handlePhoneAuth,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 24),

                        _buildSectionDivider('or'),
                        const SizedBox(height: 24),

                        // Circular Social Integrations Strip Row
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            _buildSocialIconButton('assets/icons/google.png', () async {
                                await ref
                                    .read(authStateProvider.notifier)
                                    .continueWithGoogle();
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIconButton('assets/icons/apple.png', () {}, isApple: true),
                            const SizedBox(width: 16),
                            _buildSocialIconButton(null, () {}, isMore: true),
                            ],
                        ),
                        const Spacer(),
                        ],
                    ),
                    ),
                )
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
