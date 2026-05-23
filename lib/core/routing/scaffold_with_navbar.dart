import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body:
          child, // This is where the active screen (Plan, Recipes, etc.) is rendered
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(
              Icons.calendar_month,
              color: AppColors.tealPrimary,
            ),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(
              Icons.restaurant_menu,
              color: AppColors.tealPrimary,
            ),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag, color: AppColors.tealPrimary),
            label: 'Grocery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: AppColors.tealPrimary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Tells the navbar which tab highlight based on the current URL path
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/recipes')) return 1;
    if (location.startsWith('/grocery')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // Default to 'Plan' page layout
  }

  // Handles moving between routes when clicking tab entries
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/plan');
        break;
      case 1:
        context.go('/recipes');
        break;
      case 2:
        context.go('/grocery');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
