import 'package:aaharup_app/features/meal_planner/domain/meal_plan_models.dart';

abstract class PlannerRepository {
  Future<DailyMealPlan> fetchDailyMealPlan(DateTime targetDate);
}
