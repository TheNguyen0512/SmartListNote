import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? displayName;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.displayName,
    this.photoUrl,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? displayName,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'displayName': displayName,
      'photoUrl': photoUrl,
    }..removeWhere((key, value) => value == null);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing UserModel from JSON: $e');
      }
      return UserModel(
        id: json['id'] as String,
        email: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }
}