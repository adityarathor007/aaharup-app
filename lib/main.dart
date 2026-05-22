import 'package:aaharup_app/core/theme/app_theme.dart';
import 'package:aaharup_app/features/auth/presentation/auth_test_screen.dart';
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

// Minimal placeholder router setup to demonstrate GoRouter logic
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthTestScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Notice we use MaterialApp.router instead of ordinary MaterialApp
    return MaterialApp.router(
      title: 'AaharUp Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Hand routing control over to GoRouter
      routerConfig: _router,
    );
  }
}
