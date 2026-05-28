// Add this implementation inside your RepositoryImpl class:
import 'package:aaharup_app/core/network/api_client.dart';
import 'package:aaharup_app/features/meal_planner/domain/meal_plan_models.dart';
import 'package:aaharup_app/features/meal_planner/domain/planner_repository.dart';

class PlannerRepositoryImpl implements PlannerRepository {

  final ApiClient _apiClient;
  PlannerRepositoryImpl(this._apiClient);

  @override
  Future<DailyMealPlan> fetchDailyMealPlan(DateTime targetDate) async {
    try {
      final dateString = targetDate.toIso8601String().split(
        'T',
      )[0]; // Yields YYYY-MM-DD

      final response = await _apiClient.dio.get(
        '/planner/day',
        queryParameters: {'target_date': dateString},
      );

      if (response.data == null) {
        return DailyMealPlan(date: targetDate);
      }

      final data = response.data;

      return DailyMealPlan(
        date: targetDate,
        breakfast: data['breakfast'] != null
            ? ScheduledMeal.fromJson(data['breakfast'])
            : null,
        lunch: data['lunch'] != null
            ? ScheduledMeal.fromJson(data['lunch'])
            : null,
        dinner: data['dinner'] != null
            ? ScheduledMeal.fromJson(data['dinner'])
            : null,
      );
    } catch (e) {
      throw Exception('Failed to load today\'s scheduled meal allocations.');
    }
  }
}
