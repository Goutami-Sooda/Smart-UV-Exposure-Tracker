import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String skinType;
  final String email;
  final double currentUVIndex;
  final Duration lastExposureDuration;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.skinType,
    required this.email,
    required this.currentUVIndex,
    required this.lastExposureDuration,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'age': age,
    'gender': gender,
    'skinType': skinType,
    'email': email,
    'currentUVIndex': currentUVIndex,
    'lastExposureDuration': lastExposureDuration.inSeconds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    name: map['name'],
    age: map['age'],
    gender: map['gender'],
    skinType: map['skinType'],
    email: map['email'],
    currentUVIndex: (map['currentUVIndex'] ?? 0).toDouble(),
    lastExposureDuration: Duration(seconds: map['lastExposureDuration'] ?? 0),
    createdAt: DateTime.parse(map['createdAt']),
  );

  UserModel copyWith({
    String? uid,
    String? name,
    int? age,
    String? gender,
    String? skinType,
    String? email,
    double? currentUVIndex,
    Duration? lastExposureDuration,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      skinType: skinType ?? this.skinType,
      email: email ?? this.email,
      currentUVIndex: currentUVIndex ?? this.currentUVIndex,
      lastExposureDuration: lastExposureDuration ?? this.lastExposureDuration,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
