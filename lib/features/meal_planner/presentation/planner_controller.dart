// Created a dynamic state architecture that computes the week's dates relative to whatever day the user clicks.
import 'package:aaharup_app/features/meal_planner/domain/meal_plan_models.dart';
import 'package:aaharup_app/features/meal_planner/data/dish_providers.dart';
import 'package:aaharup_app/features/meal_planner/data/planner_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Selected Date State Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 2. Computed Provider to generate the active 7 days based on selected week window
final currentWeekDaysProvider = Provider<List<DateTime>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);

    // Find Monday of the currently targeted week
    final int currentWeekday = selectedDate.weekday;
    final DateTime monday = selectedDate.subtract(
        Duration(days: currentWeekday - 1),
    );

  return List.generate(7, (index) => monday.add(Duration(days: index)));
});


// 3. Simple Mock data provider to feed the UI before API hooks are wired
// final dailyMealPlanProvider = Provider.family<DailyMealPlan, DateTime>((ref,date,) {
//   // Simple check to match the Stitch demo look (March 20, 2024 / current date mock)
//   final isSampleDay = date.day == 20 || date.day == DateTime.now().day;

//   return DailyMealPlan(
//     date: date,
//     breakfast: isSampleDay
//         ? ScheduledMeal(
//             id: 1,
//             name: 'Avocado Toast',
//             calories: 450,
//             prepTimeMinutes: 12,
//           )
//         : null,
//     lunch: null,
//     dinner: null,
//   );
// });

// Replace your old dailyMealPlanProvider with this live network stream:
final dailyMealPlanProvider = FutureProvider<DailyMealPlan>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(
    plannerRepositoryProvider,
  ); // Points to your api client wrapper

  return repository.fetchDailyMealPlan(selectedDate);
});
