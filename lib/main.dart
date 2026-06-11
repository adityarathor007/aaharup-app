import 'package:aaharup_app/core/routing/scaffold_with_navbar.dart';
import 'package:aaharup_app/core/theme/app_theme.dart';
import 'package:aaharup_app/features/ai_search/presentation/discover_screen.dart';
import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:aaharup_app/features/auth/presentation/auth_test_screen.dart';
import 'package:aaharup_app/features/auth/presentation/onboarding_screen.dart';
// import 'package:aaharup_app/features/auth/presentation/login_screen.dart';
import 'package:aaharup_app/features/auth/presentation/register.dart';
import 'package:aaharup_app/features/meal_planner/presentation/add_dish_tab_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/recipe_search_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/dish_image_test_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/planner_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/place_holder_screen.dart';
import 'package:aaharup_app/features/profile/presentation/profile_screen.dart';
import 'package:aaharup_app/features/auth/presentation/login_new_screen.dart';
import 'package:aaharup_app/firebase_options.dart';
import 'package:aaharup_app/shared/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRestartWrapper extends StatefulWidget {
  final Widget child;
  const AppRestartWrapper({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartWrapperState>()?.restart();
  }

  @override
  State<AppRestartWrapper> createState() => _AppRestartWrapperState();
}

class _AppRestartWrapperState extends State<AppRestartWrapper> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      // Changing the structural Key forces Flutter to kill the old ProviderScope
      // and spawn a brand-new one with zero memory pollution!
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: ProviderScope(child: widget.child),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AppRestartWrapper(child: MyApp()));
}

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
final isOnboardedProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref){
    final authState = ref.watch(authStateProvider);
    final isOnboarded = ref.watch(isOnboardedProvider);

    return GoRouter(
        initialLocation: '/login',

        redirect: (context, state) {
            final isLoggedIn = authState.value ?? false;
            // debugPrint("redirect called");
            // debugPrint("auth=${authState.value}");
            final currentLoc = state.matchedLocation;

            // 1. If not logged in, force them back to login barrier
            if (!isLoggedIn) {
                return '/login';
            }

            // 2. If logged in and explicitly trying to hit login/register screens
            if (isLoggedIn && (currentLoc == '/login' || currentLoc == '/register')) {
            // // New users go to onboarding first, existing users go straight to dashboard
            //     return isOnboarded ? '/plan' : '/onboarding';
              return '/plan';
            }

            // Allow all other transitions (like clicking Skip on Onboarding to visit /plan) to pass cleanly
            return null;
        },


        routes:[
            GoRoute(
                path: '/login',
                builder: (context,state) => const LoginNewScreen()
            ),

            GoRoute(
              path: '/onboarding',
              builder: (context, state) => const OnboardingScreen(),
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
                    builder: (context, state) => const DishImageTestScreen(),
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
                    path: '/add-dish',
                    builder: (context, state) => const AddDishTabsScreen(),
                    ),
                ],
            )
            // Note: Future Login or Auth screens will be placed out here,
            // completely separate from the ShellRoute, so they won't show the navbar!
        ]

    );
});

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
