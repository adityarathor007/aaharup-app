class ScheduledMeal {
  final int id;
  final String name;
  final double calories;
  final String? imageUrl;
  final int prepTimeMinutes;

  ScheduledMeal({
    required this.id,
    required this.name,
    required this.calories,
    this.imageUrl,
    required this.prepTimeMinutes,
  });
}

class DailyMealPlan {
  final DateTime date;
  final ScheduledMeal? breakfast;
  final ScheduledMeal? lunch;
  final ScheduledMeal? dinner;

  DailyMealPlan({required this.date, this.breakfast, this.lunch, this.dinner});

  // Calculate global daily progress for the progress indicator bar
  double get totalCalories {
    return (breakfast?.calories ?? 0) +
        (lunch?.calories ?? 0) +
        (dinner?.calories ?? 0);
  }
}
