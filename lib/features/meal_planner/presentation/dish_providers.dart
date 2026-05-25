import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_providers.dart';
import '../data/dish_repository.dart';
// import '../domain/dish_model.dart';

// Provides our structural repository implementation asset
final dishRepositoryProvider = Provider<DishRepository>((ref) {
  return DishRepositoryImpl(ref.watch(apiClientProvider));
});

// Dynamic query input stream modifier parameter hooks
final dishSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCuisineFilterProvider = StateProvider<String>((ref) => 'All');

// Independent Family FutureProvider dedicated to loading specific carousel lanes natively
// final discoveryCarouselRowProvider =
//     FutureProvider.family<List<Dish>, List<String>>((
//       ref,
//       targetedCourses,
//     ) async {
//       final repo = ref.watch(dishRepositoryProvider);
//       final searchInput = ref.watch(dishSearchQueryProvider);
//       final cuisineFilter = ref.watch(selectedCuisineFilterProvider);

//       return repo.fetchDishes(
//         searchQuery: searchInput,
//         course: targetedCourses,
//         cuisine: cuisineFilter,
//       );
//     });
