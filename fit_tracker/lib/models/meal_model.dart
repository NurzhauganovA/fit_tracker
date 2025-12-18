import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final String id;
  final String name;
  final MealType type;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime date;
  final String notes;

  Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
    this.notes = '',
  });

  factory Meal.fromMap(Map<String, dynamic> data, String id) {
    return Meal(
      id: id,
      name: data['name'] ?? '',
      type: _parseMealType(data['type']),
      calories: data['calories'] ?? 0,
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fats: (data['fats'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }

  static MealType _parseMealType(String? value) {
    return MealType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => MealType.snack,
    );
  }

  String get typeEmoji {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '🍽️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }

  String get typeLabel {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }
}