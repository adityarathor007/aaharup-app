import 'package:aaharup_app/core/theme/app_colors.dart';
import 'package:aaharup_app/core/theme/app_spacing.dart';
import 'package:aaharup_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const AppErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.accentOrange,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Something Went Wrong', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMutedLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.tealPrimary),
              label: Text(
                'Retry',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.tealPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
