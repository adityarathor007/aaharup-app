import 'package:aaharup_app/features/meal_planner/domain/dish_repository.dart';
import '../../../../core/network/api_client.dart';
import '../domain/dish_model.dart';


class DishRepositoryImpl implements DishRepository {
  final ApiClient _apiClient;
  DishRepositoryImpl(this._apiClient);

  @override
  Future<List<Dish>> fetchDishes({
    String? searchQuery,
    String? course,
    String? cuisine,
    int? limit,
  }) async {
    try {
      // Setup dynamic structural query parameters matching FastAPI parameters map
      final Map<String, dynamic> queryParams = {};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (cuisine != null && cuisine != 'All') {
        queryParams['cuisine'] = cuisine;
      }

      if (course != null && course != 'All') {
        queryParams['course'] = course;
      }

      if (limit != null) {
        queryParams['limit'] = limit; // Passes your explicit row restriction value straight to FastAPI
      }

      final response = await _apiClient.dio.get(
        '/dishes',
        queryParameters: queryParams,
      );

      final List items = response.data['items'];
      return items.map((e) => Dish.fromJson(e)).toList();
    } catch (e) {
      throw Exception(
        'Failed to synchronize multi-carousel listing arrays from backend server.',
      );
    }
  }
}
