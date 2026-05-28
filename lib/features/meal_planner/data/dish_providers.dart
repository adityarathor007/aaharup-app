import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:aaharup_app/features/meal_planner/domain/dish_repository.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_providers.dart';
import 'dish_repository_impl.dart';
// import '../domain/dish_model.dart';

// 1. Provides our structural repository implementation asset
final dishRepositoryProvider = Provider<DishRepository>((ref) {
  return DishRepositoryImpl(ref.watch(apiClientProvider));
});

// Tracks whether the current view target is "Breakfast", "Lunch", or "Dinner"
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
  }
);

// 3. Dynamic FutureProviderFamily that fetches a specialized list of dishes for a specific sub-carousel
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



// FOR SEARCHING
// 1. Controls whether the screen is currently displaying the search input and grid results
final isSearchActiveProvider = StateProvider<bool>((ref) => false);
final dishSearchQueryProvider = StateProvider<String>((ref) => '');

// 2. Fetches a flat, un-categorized list of dishes matching the search keyword for the 2-column grid
final globalSearchQueryResultProvider = FutureProvider<List<Dish>>((ref) async {
  final repo = ref.watch(dishRepositoryProvider);
  final searchQuery = ref.watch(dishSearchQueryProvider);
  // final cuisineFilter = ref.watch(selectedCuisineFilterProvider);
  // final activeCourseTags = ref.watch(targetCourseFiltersProvider);

  // If the user hasn't typed anything yet but opened search, return empty or a default list
  if (searchQuery.isEmpty) {
    return repo.fetchDishes(limit: 100);
  }
  return repo.fetchDishes(searchQuery: searchQuery);
});
