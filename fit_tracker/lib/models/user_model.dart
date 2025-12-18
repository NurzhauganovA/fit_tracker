class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double height; // in cm
  final double targetWeight; // in kg
  final String fitnessGoal; // lose weight, gain muscle, maintain, etc.
  final String? photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.age = 0,
    this.height = 0,
    this.targetWeight = 0,
    this.fitnessGoal = '',
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? 'User',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      height: (data['height'] ?? 0).toDouble(),
      targetWeight: (data['targetWeight'] ?? 0).toDouble(),
      fitnessGoal: data['fitnessGoal'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'targetWeight': targetWeight,
      'fitnessGoal': fitnessGoal,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    double? height,
    double? targetWeight,
    String? fitnessGoal,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}