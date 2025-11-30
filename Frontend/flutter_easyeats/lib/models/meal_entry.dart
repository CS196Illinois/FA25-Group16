import 'food_item.dart';

class MealEntry {
  final int id;
  final int userId;
  final String mealType;
  final String diningHall;
  final DateTime consumedAt;
  final List<FoodItem> foods;
  final NutritionTotals totals;

  MealEntry({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.diningHall,
    required this.consumedAt,
    required this.foods,
    required this.totals,
  });

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'],
      userId: json['user_id'],
      mealType: json['meal_type'] ?? 'Snack',
      diningHall: json['dining_hall'] ?? 'Unknown',
      consumedAt: DateTime.parse(json['consumed_at']),
      foods: (json['foods'] as List)
          .map((f) => FoodItem.fromJson(f))
          .toList(),
      totals: NutritionTotals.fromJson(json['totals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_type': mealType,
      'dining_hall': diningHall,
      'consumed_at': consumedAt.toIso8601String(),
      'foods': foods.map((f) => f.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }
}

class NutritionTotals {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;

  NutritionTotals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
  });

  factory NutritionTotals.fromJson(Map<String, dynamic> json) {
    return NutritionTotals(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'fiber': fiber,
    };
  }

  NutritionTotals operator +(NutritionTotals other) {
    return NutritionTotals(
      calories: calories + other.calories,
      protein: protein + other.protein,
      fat: fat + other.fat,
      carbs: carbs + other.carbs,
      fiber: fiber + other.fiber,
    );
  }
}
