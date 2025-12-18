import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class WorkoutProvider with ChangeNotifier {
  DatabaseService get _db => DatabaseService(
      uid: FirebaseAuth.instance.currentUser?.uid ?? ''
  );

  Stream<List<Workout>> get workoutsStream => _db.workouts;

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
    await _db.addWorkout(
      name,
      description,
      date,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      type: type,
      intensity: intensity,
      exercises: exercises,
    );

    // Schedule notification for the new workout
    // We create a temporary Workout object just for the notification service
    // In a real app, you might want to return the ID from addWorkout to fetch the real object
    final tempWorkout = Workout(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        date: date,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned
    );
    await NotificationService().scheduleWorkoutReminder(tempWorkout);

    notifyListeners();
  }

  Future<void> toggleWorkout(String workoutId, bool currentStatus) async {
    await _db.toggleWorkoutStatus(workoutId, currentStatus);
    notifyListeners();
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _db.deleteWorkout(workoutId);
    notifyListeners();
  }
}