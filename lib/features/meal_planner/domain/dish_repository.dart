import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';

abstract class DishRepository {
  Future<List<Dish>> fetchDishes({
    String? searchQuery,
    String? course,
    String? cuisine,
    int? limit,
  });
}
