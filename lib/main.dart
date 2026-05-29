import 'package:aaharup_app/core/routing/scaffold_with_navbar.dart';
import 'package:aaharup_app/core/theme/app_theme.dart';
import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:aaharup_app/features/auth/presentation/auth_test_screen.dart';
// import 'package:aaharup_app/features/auth/presentation/login_screen.dart';
import 'package:aaharup_app/features/auth/presentation/register.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/planner_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/place_holder_screen.dart';
import 'package:aaharup_app/features/profile/presentation/profile_screen.dart';
import 'package:aaharup_app/features/auth/presentation/login_new_screen.dart';
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
final isOnboardedProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref){
    final authState = ref.watch(authStateProvider);
    final isOnboarded = ref.watch(isOnboardedProvider);

    return GoRouter(
        initialLocation: '/login',
      //   redirect: (context, state) {
      //     final isLoggedIn = authState.value ?? false;
      //     final currentLoc = state.matchedLocation;

      //     // 1. Create a checklist of routes that do NOT require a user to be logged in
      //     final isAuthRoute = currentLoc == '/login' || currentLoc == '/register';

      //     // 2. If the user is NOT logged in, and trying to go to a secured tab (like /plan)
      //     if (!isLoggedIn && !isAuthRoute) {
      //       return '/login'; // Kick them back to login barrier
      //     }

      //     // 3. If the user IS logged in, prevent them from seeing auth screens again
      //     if (isLoggedIn && isAuthRoute) {
      //       return '/plan'; // Send them straight to the main dashboard workspace
      //     }

      //     // Return null to allow the navigation to proceed normally
      //     return null;
      // },

        redirect: (context, state) {
          final isLoggedIn = authState.value ?? false;
          debugPrint("redirect called");
          debugPrint("auth=${authState.value}");
          final currentLoc = state.matchedLocation;

          // 1. If not logged in, force them back to login barrier
          if (!isLoggedIn) {
            return '/login';
          }

          // 2. If logged in but NOT onboarded (new user), trap them on the onboarding workflow screen
          if (isLoggedIn && !isOnboarded) {
            return '/onboarding';
          }

          // 3. If logged in AND onboarded trying to view login screen, bypass straight to calendar
          if (isLoggedIn && isOnboarded && currentLoc == '/login') {
          // if (isLoggedIn && currentLoc == '/login') {
            return '/plan';
          }

          return null;
        },


        routes:[
            GoRoute(
                path: '/login',
                builder: (context,state) => const LoginNewScreen()
            ),

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
                    GoRoute(
                    path: '/discovery',
                    builder: (context, state) => const DiscoveryFeedWidget(),
                    ),

                    GoRoute(
                      path: '/onboarding',
                      builder: (context, state) =>
                      const OnboardingScreen(), // Injected target route entry point
                    ),
                ],
            )
            // Note: Future Login or Auth screens will be placed out here,
            // completely separate from the ShellRoute, so they won't show the navbar!
        ]

    );
});

// final GoRouter _router = GoRouter(
//   navigatorKey: _rootNavigatorKey,
//   initialLocation: '/login', // Launch directly into the main plan view
//   routes: [
//     // Standalone Fullscreen Login Route - Completely removes the bottom navigation bar wrapper!
//     GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//     // The ShellRoute injects your navigation bar wrapper around all nested sub-routes
//     ShellRoute(
//       navigatorKey: _shellNavigatorKey,
//       builder: (context, state, child) {
//         return ScaffoldWithNavBar(child: child);
//       },
//       routes: [
//         GoRoute(
//           path: '/',
//             builder: (context, state) => const AuthTestScreen(),
//         ),
//         GoRoute(
//           path: '/plan',
//           builder: (context, state) => const MealPlannerScreen(),
//         ),
//         GoRoute(
//           path: '/recipes',
//           builder: (context, state) => const RecipesScreen(),
//         ),
//         GoRoute(
//           path: '/grocery',
//           builder: (context, state) => const GroceryScreen(),
//         ),
//         GoRoute(
//           path: '/profile',
//           builder: (context, state) => const ProfileScreen(),
//         ),
//         GoRoute(
//           path: '/discovery',
//           builder: (context, state) => const DiscoveryFeedWidget(),
//         ),
//       ],
//     ),

//
//   ],
// );

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentTheme = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // Notice we use MaterialApp.router instead of ordinary MaterialApp
    return MaterialApp.router(
      title: 'AaharUp Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentTheme,
      // Hand routing control over to GoRouter
      routerConfig: router,
    );
  }
}
