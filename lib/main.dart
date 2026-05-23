import 'package:aaharup_app/core/routing/scaffold_with_navbar.dart';
import 'package:aaharup_app/core/theme/app_theme.dart';
import 'package:aaharup_app/features/auth/presentation/auth_test_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/meal_planner_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/place_holder_screen.dart';
import 'package:aaharup_app/shared/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  // Ensure native bindings are active before loading local storage systems later
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // The ProviderScope widget acts as the master engine for all Riverpod code
    const ProviderScope(child: MyApp()),
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();


final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/plan', // Launch directly into the main plan view
  routes: [
    // The ShellRoute injects your navigation bar wrapper around all nested sub-routes
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
            builder: (context, state) => const AuthTestScreen(),
        ),
        GoRoute(
          path: '/plan',
          builder: (context, state) => const MealPlannerScreen(),
        ),
        GoRoute(
          path: '/recipes',
          builder: (context, state) => const RecipesScreen(),
        ),
        GoRoute(
          path: '/grocery',
          builder: (context, state) => const GroceryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Note: Future Login or Auth screens will be placed out here,
    // completely separate from the ShellRoute, so they won't show the navbar!
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentTheme = ref.watch(themeProvider);

    // Notice we use MaterialApp.router instead of ordinary MaterialApp
    return MaterialApp.router(
      title: 'AaharUp Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentTheme,
      // Hand routing control over to GoRouter
      routerConfig: _router,
    );
  }
}
