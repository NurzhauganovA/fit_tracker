import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/meal_model.dart';
import '../services/database_service.dart';

class MealProvider with ChangeNotifier {
  DatabaseService get _db => DatabaseService(
      uid: FirebaseAuth.instance.currentUser?.uid ?? ''
  );

  Stream<List<Meal>> get mealsStream => _db.meals;

  Future<void> addMeal({
    required String name,
    required MealType type,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    required DateTime date,
    String notes = '',
  }) async {
    await _db.addMeal(
      name: name,
      type: type,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      date: date,
      notes: notes,
    );
    notifyListeners();
  }

  Future<void> updateMeal({
    required String id,
    String? name,
    MealType? type,
    int? calories,
    double? protein,
    double? carbs,
    double? fats,
    DateTime? date,
    String? notes,
  }) async {
    await _db.updateMeal(
      id: id,
      name: name,
      type: type,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      date: date,
      notes: notes,
    );
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    await _db.deleteMeal(id);
  }
}