import 'package:cloud_firestore/cloud_firestore.dart';

class RaceRecordModel {
  final String id;
  final String userId;
  final String text;
  final int wpm;
  final int accuracy;
  final int duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerId;

  RaceRecordModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.wpm,
    required this.accuracy,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
  });

  factory RaceRecordModel.fromJson(Map<String, dynamic> json, String id) {
    return RaceRecordModel(
      id: id,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      wpm: json['wpm'] as int,
      accuracy: json['accuracy'] as int,
      duration: json['duration'] as int,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      ownerId: json['owner_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'text': text,
      'wpm': wpm,
      'accuracy': accuracy,
      'duration': duration,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'owner_id': ownerId,
    };
  }

  RaceRecordModel copyWith({
    String? id,
    String? userId,
    String? text,
    int? wpm,
    int? accuracy,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
  }) {
    return RaceRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      wpm: wpm ?? this.wpm,
      accuracy: accuracy ?? this.accuracy,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
