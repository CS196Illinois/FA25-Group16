class FoodItem {
  final String name;
  final String? category;
  final String? servingSize;
  final double calories;
  final double protein;
  final double totalFat;
  final double totalCarbohydrate;
  final double? dietaryFiber;
  final double? sugars;
  final double? sodium;

  FoodItem({
    required this.name,
    this.category,
    this.servingSize,
    required this.calories,
    required this.protein,
    required this.totalFat,
    required this.totalCarbohydrate,
    this.dietaryFiber,
    this.sugars,
    this.sodium,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      category: json['category'],
      servingSize: json['serving_size'],
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
      totalCarbohydrate: (json['total_carbohydrate'] ?? 0).toDouble(),
      dietaryFiber: json['dietary_fiber'] != null ? (json['dietary_fiber']).toDouble() : null,
      sugars: json['sugars'] != null ? (json['sugars']).toDouble() : null,
      sodium: json['sodium'] != null ? (json['sodium']).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'serving_size': servingSize,
      'calories': calories,
      'protein': protein,
      'total_fat': totalFat,
      'total_carbohydrate': totalCarbohydrate,
      'dietary_fiber': dietaryFiber,
      'sugars': sugars,
      'sodium': sodium,
    };
  }
}
