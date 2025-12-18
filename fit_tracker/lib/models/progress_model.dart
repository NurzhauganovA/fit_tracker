import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressEntry {
  final String id;
  final String title;
  final String content;
  final double? weight;
  final double? bodyFat;
  final Map<String, double>? measurements; // chest, waist, hips, etc.
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  ProgressEntry({
    required this.id,
    required this.title,
    required this.content,
    this.weight,
    this.bodyFat,
    this.measurements,
    this.color = 'orange',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ProgressEntry.fromMap(Map<String, dynamic> data, String documentId) {
    return ProgressEntry(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      weight: data['weight']?.toDouble(),
      bodyFat: data['bodyFat']?.toDouble(),
      measurements: data['measurements'] != null
          ? Map<String, double>.from(
        (data['measurements'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toDouble()),
        ),
      )
          : null,
      color: data['color'] ?? 'orange',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'weight': weight,
      'bodyFat': bodyFat,
      'measurements': measurements,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
    };
  }

  ProgressEntry copyWith({
    String? title,
    String? content,
    double? weight,
    double? bodyFat,
    Map<String, double>? measurements,
    String? color,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return ProgressEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      measurements: measurements ?? this.measurements,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
    );
  }
}