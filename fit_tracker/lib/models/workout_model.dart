import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkoutType { strength, cardio, flexibility, sports, other }

enum WorkoutIntensity { light, moderate, intense, extreme }

class Workout {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final bool isCompleted;
  final WorkoutType type;
  final WorkoutIntensity intensity;
  final List<String> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.isCompleted = false,
    this.type = WorkoutType.other,
    this.intensity = WorkoutIntensity.moderate,
    this.exercises = const [],
  });

  factory Workout.fromMap(Map<String, dynamic> data, String id) {
    return Workout(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      type: _parseWorkoutType(data['type']),
      intensity: _parseWorkoutIntensity(data['intensity']),
      exercises: List<String>.from(data['exercises'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'isCompleted': isCompleted,
      'type': type.name,
      'intensity': intensity.name,
      'exercises': exercises,
    };
  }

  static WorkoutType _parseWorkoutType(String? value) {
    return WorkoutType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => WorkoutType.other,
    );
  }

  static WorkoutIntensity _parseWorkoutIntensity(String? value) {
    return WorkoutIntensity.values.firstWhere(
          (e) => e.name == value,
      orElse: () => WorkoutIntensity.moderate,
    );
  }

  String get typeEmoji {
    switch (type) {
      case WorkoutType.strength:
        return '💪';
      case WorkoutType.cardio:
        return '🏃';
      case WorkoutType.flexibility:
        return '🧘';
      case WorkoutType.sports:
        return '⚽';
      case WorkoutType.other:
        return '🏋️';
    }
  }

  String get intensityLabel {
    return intensity.name[0].toUpperCase() + intensity.name.substring(1);
  }
}