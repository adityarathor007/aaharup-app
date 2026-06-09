class Dish {
  final int id;
  final String name;
  final String description;
  final String ingredientsRaw;
  final String recipeInstructions;
  final String cuisineType;
  final String courseType;
  final String dietType;
  final int cookTimeMins;
  final String? imageUrl;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fats;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredientsRaw,
    required this.recipeInstructions,
    required this.cuisineType,
    required this.courseType,
    required this.dietType,
    required this.cookTimeMins,
    this.imageUrl,
    this.calories,
    this.protein,
    this.carbs,
    this.fats,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ingredientsRaw: json['ingredients_raw'] ?? '',
      recipeInstructions: json['recipe_instructions'] ?? '',
      cuisineType: json['cuisine_type'] ?? 'Universal',
      courseType: json['course_type'] ?? 'Main Course',
      dietType: json['diet_type'] ?? 'General',
      cookTimeMins: json['cook_time_mins'] ?? 20,
      imageUrl: json['image_storage_path'],
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
    );
  }
}
