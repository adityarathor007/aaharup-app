import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:aaharup_app/features/meal_planner/data/planner_repository_impl.dart';
import 'package:aaharup_app/features/meal_planner/domain/planner_repository.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepositoryImpl(ref.watch(apiClientProvider));
});


// 1. Tracks which dish id is currently highlighted/selected in the Netflix carousels
final selectedDishIdProvider = StateProvider<int?>((ref) => null);

// 2. StateNotifier to handle the final scheduling API execution workflow
final mealSchedulingProvider =
    StateNotifierProvider<MealSchedulingNotifier, AsyncValue<void>>((ref) {
      return MealSchedulingNotifier(ref);
    });
