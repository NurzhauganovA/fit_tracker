import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workout_model.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference get userDoc => _db.collection('users').doc(uid);

  CollectionReference get workoutCollection => userDoc.collection('workouts');
  CollectionReference get mealCollection => userDoc.collection('meals');

  // User Profile
  Future<void> createUserProfile(String email) async {
    try {
      final doc = await userDoc.get();
      if (doc.exists) {
        return;
      }

      await userDoc.set({
        'email': email,
        'name': 'Fitness Enthusiast',
        'age': 0,
        'height': 0,
        'targetWeight': 0,
        'fitnessGoal': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<UserProfile?> get userProfile {
    return userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
    });
  }

  Future<void> updateUserProfile({
    String? name,
    int? age,
    double? height,
    double? targetWeight,
    String? fitnessGoal,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (age != null) updates['age'] = age;
    if (height != null) updates['height'] = height;
    if (targetWeight != null) updates['targetWeight'] = targetWeight;
    if (fitnessGoal != null) updates['fitnessGoal'] = fitnessGoal;

    if (updates.isNotEmpty) {
      await userDoc.set(updates, SetOptions(merge: true));
    }
  }

  // Workouts
  Future<void> addWorkout(
      String name,
      String description,
      DateTime date, {
        int durationMinutes = 30,
        int caloriesBurned = 0,
        WorkoutType type = WorkoutType.other,
        WorkoutIntensity intensity = WorkoutIntensity.moderate,
        List<String> exercises = const [],
      }) async {
    await workoutCollection.add({
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'isCompleted': false,
      'type': type.name,
      'intensity': intensity.name,
      'exercises': exercises,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Workout>> get workouts {
    return workoutCollection.orderBy('date', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Workout.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> toggleWorkoutStatus(String workoutId, bool currentStatus) async {
    await workoutCollection.doc(workoutId).update({'isCompleted': !currentStatus});
  }

  Future<void> updateWorkout({
    required String workoutId,
    String? name,
    String? description,
    DateTime? date,
    int? durationMinutes,
    int? caloriesBurned,
    WorkoutType? type,
    WorkoutIntensity? intensity,
    List<String>? exercises,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (date != null) updates['date'] = Timestamp.fromDate(date);
    if (durationMinutes != null) updates['durationMinutes'] = durationMinutes;
    if (caloriesBurned != null) updates['caloriesBurned'] = caloriesBurned;
    if (type != null) updates['type'] = type.name;
    if (intensity != null) updates['intensity'] = intensity.name;
    if (exercises != null) updates['exercises'] = exercises;

    if (updates.isNotEmpty) {
      await workoutCollection.doc(workoutId).update(updates);
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    await workoutCollection.doc(workoutId).delete();
  }

  // Meals
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
    await mealCollection.add({
      'name': name,
      'type': type.name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Meal>> get meals {
    return mealCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Meal.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
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
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (type != null) updates['type'] = type.name;
    if (calories != null) updates['calories'] = calories;
    if (protein != null) updates['protein'] = protein;
    if (carbs != null) updates['carbs'] = carbs;
    if (fats != null) updates['fats'] = fats;
    if (date != null) updates['date'] = Timestamp.fromDate(date);
    if (notes != null) updates['notes'] = notes;

    if (updates.isNotEmpty) {
      await mealCollection.doc(id).update(updates);
    }
  }

  Future<void> deleteMeal(String id) async {
    await mealCollection.doc(id).delete();
  }
}