import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);

      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
          ),
        );
        context.go(
          '/login',
        ); // Take them directly back to sign-in page to capture access tokens
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Registration failed. Ensure fields are unique and formatted correctly.";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("ENtered register page");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 32,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                  Text(
                    'Join AaharUp to schedule healthy meals',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (_errorMessage != null) ...[
                    Container(
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

                  // Username Input Box Frame
                  _buildLabel('Username'),
                  TextField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration(
                      'Enter a unique username',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Phone Number Input Box Frame
                  _buildLabel('Phone Number'),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('e.g. +919876543210'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Email Input Box Frame
                  _buildLabel('Email Address'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('name@example.com'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Password Input Box Frame
                  _buildLabel('Password'),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('••••••••'),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealPrimary,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
