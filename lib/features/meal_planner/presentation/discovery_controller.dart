import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:aaharup_app/features/meal_planner/presentation/dish_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// 1. Tracks whether the current view target is "Breakfast", "Lunch", or "Dinner"
final activeSlotContextRecipientProvider = StateProvider<String>(
  (ref) => 'Breakfast',
);

// 2. Returns the clean mapped array tags based on the active tracking slot context
final targetCourseFiltersProvider = Provider<List<String>>((ref) {
  final activeSlot = ref
      .watch(activeSlotContextRecipientProvider)
      .toLowerCase();

  if (activeSlot == 'breakfast') {
    return [
      'South Indian Breakfast',
      'Indian Breakfast',
      'North Indian Breakfast',
      'World Breakfast',
      'Brunch',
    ];
  } else if (activeSlot == 'lunch') {
    return [
      'Main Course',
      'Lunch',
      'One Pot Dish',
      'Vegetarian',
      'Non Vegeterian',
      'High Protein Vegetarian',
    ];
  } else {
    // Default Fallback: Dinner allocation groupings
    return [
      'Main Course',
      'Dinner',
      'One Pot Dish',
      'Vegetarian',
      'Non Vegeterian',
      'High Protein Vegetarian',
    ];
  }
});

// 3. Dynamic FutureProviderFamily that fetches a specialized list of dishes for a specific sub-carousel
// Change the family type from String to List<String>
final carouselDishesProvider = FutureProvider.family<List<Dish>, String>((
  ref,
  specificCourse,
) async {
    final repository = ref.watch(dishRepositoryProvider);

    final searchString = ref.watch(dishSearchQueryProvider);

  // Directly fetches matching rows for this specific carousel row from your FastAPI setup
    return repository.fetchDishes(
    searchQuery: searchString,
    course: specificCourse,
    );
});


// 1. Tracks which dish id is currently highlighted/selected in the Netflix carousels
final selectedDishIdProvider = StateProvider<int?>((ref) => null);

// 2. StateNotifier to handle the final scheduling API execution workflow
final mealSchedulingProvider =
    StateNotifierProvider<MealSchedulingNotifier, AsyncValue<void>>((ref) {
        return MealSchedulingNotifier(ref);
});


class MealSchedulingNotifier extends StateNotifier<AsyncValue<void>> {
    final Ref _ref;
    MealSchedulingNotifier(this._ref) : super(const AsyncValue.data(null));

    Future<bool> confirmAndScheduleMeal({
    required DateTime targetDate,
    required String slotType,
    required int dishId,
    }) async {
    state = const AsyncValue.loading();
    try {
        final apiClient = _ref.read(apiClientProvider);
        // print(apiClient);

        // Hit your FastAPI POST /api/v1/planner/schedule route
        await apiClient.dio.post(
        '/planner/schedule',
        data: {
            'target_date': targetDate.toIso8601String().split(
            'T',
            )[0], // Formats exactly to YYYY-MM-DD
            'slot_type': slotType,
            'dish_id': dishId,
        },
        );

        state = const AsyncValue.data(null);
        // print(state);
        return true; // Success flag
    } catch (e, stack) {
        state = AsyncValue.error(e, stack);
        return false;
    }
    }
}
