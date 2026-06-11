import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';

class AiSearchResponse {
  final String message;
  final String sessionId;
  final List<AiSuggestion> suggestions; // Holds our composite wrapper objects

  AiSearchResponse({
    required this.message,
    required this.sessionId,
    required this.suggestions,
  });

  factory AiSearchResponse.fromJson(Map<String, dynamic> json) {
    return AiSearchResponse(
      message: json['message'] ?? '',
      sessionId: json['session_id'] ?? '',
      suggestions: (json['suggestions'] as List? ?? [])
          .where((item) => item != null)
          .map((item) => AiSuggestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AiSuggestion {
  final Dish dish; // Clean instance of your existing Dish catalog class
  final String reason; //  The dynamic justification string from the LLM

  AiSuggestion({required this.dish, required this.reason});

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSuggestion(
      // Pass the nested 'dish' JSON sub-map straight into your existing factory constructor!
      dish: Dish.fromJson(json['dish'] ?? {}),
      // Read the reason string right next to it
      reason:
          json['reason'] ??
          'Top personalized recommendation based on your health log criteria.',
    );
  }
}

// class AiSuggestion {
//   final int id;
//   final String name;
//   final String cuisineType;
//   final int cookTimeMins;
//   final String dietType;
//   final String reason;

//   AiSuggestion({
//     required this.id,
//     required this.name,
//     required this.cuisineType,
//     required this.cookTimeMins,
//     required this.dietType,
//     required this.reason,
//   });

//   factory AiSuggestion.fromJson(Map<String, dynamic> json) {
//     return AiSuggestion(
//       id: json['id'],
//       name: json['name'] ?? '',
//       cuisineType: json['cuisine_type'] ?? '',
//       cookTimeMins: json['cook_time_mins'] ?? 0,
//       dietType: json['diet_type'] ?? '',
//       reason: json['reason'] ?? '',
//     );
//   }

//   Dish toDish() {
//     return Dish(
//       id: id,
//       name: name,
//       cuisineType: cuisineType,
//       cookTimeMins: cookTimeMins,
//       dietType: dietType,
//       description: "",
//       // Pass safe defaults for any missing properties your original Dish class needs
//       imageUrl:  null, ingredientsRaw: '', recipeInstructions: '', courseType: '',
//     );
//   }
// }
