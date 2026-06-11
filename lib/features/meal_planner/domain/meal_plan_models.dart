
class ScheduledMeal {
  final int id;
  final String name;
  final double calories;
  final String imageUrl;
  final int prepTimeMinutes;

  ScheduledMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.prepTimeMinutes,
  });

// ADD THIS FACTORY CONSTRUCTOR TO FIX THE ERROR:
  factory ScheduledMeal.fromJson(Map<String, dynamic> json) {
    print(json);
    return ScheduledMeal(
      id: json['id'] as int,
      name: json['name'] ?? 'Unnamed Dish',
      // Safely parse num to double regardless of whether backend returns int or double
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_storage_path'],
      prepTimeMinutes:
          json['cook_time_mins'] ??
          20, // Maps perfectly to our Kaggle backend field
    );
  }
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
