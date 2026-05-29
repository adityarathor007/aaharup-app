import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('AI Recipe Library', style: AppTextStyles.h2)),
  );
}

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Aggregated Shopping List', style: AppTextStyles.h2),
    ),
  );
}

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     body: Center(
//       child: Text('User Profile & Macro Analytics', style: AppTextStyles.h2),
//     ),
//   );
// }
