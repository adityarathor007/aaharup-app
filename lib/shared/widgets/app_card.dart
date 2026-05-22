import 'package:aaharup_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(padding: padding ?? AppSpacing.paddingAllMd, child: child),
    );
  }
}
